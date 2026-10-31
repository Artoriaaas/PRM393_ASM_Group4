"use strict";
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const {
  Rejection,
  hash,
  registrationId,
  validateCommand,
  decide,
} = require("./booking");
initializeApp();
setGlobalOptions({ region: "asia-southeast1", maxInstances: 5 });
const db = getFirestore();
function uidOf(request) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  if (request.auth.token.email_verified !== true)
    throw new HttpsError("permission-denied", "Verify email first.");
  return request.auth.uid;
}
function parsed(doc) {
  if (!doc.exists) return null;
  const data = doc.data();
  for (const [key, value] of Object.entries(data))
    if (value instanceof Timestamp) {
      data[`${key}Ms`] = value.toMillis();
      delete data[key];
    }
  return { ...data, id: doc.id };
}
function stored(data) {
  const out = { ...data };
  delete out.id;
  for (const [key, value] of Object.entries(out))
    if (key.endsWith("Ms")) {
      delete out[key];
      out[key.slice(0, -2)] =
        value === null ? null : Timestamp.fromMillis(value);
    }
  return out;
}
exports.bookingCommand = onCall(async (request) => {
  const uid = uidOf(request);
  let c;
  try {
    c = validateCommand(request.data || {});
  } catch (e) {
    if (e instanceof Rejection)
      throw new HttpsError("invalid-argument", e.code);
    throw e;
  }
  const rid = registrationId(uid, c.eventId);
  const operation = db.doc(
    `operations/${hash(JSON.stringify([uid, c.operationId]))}`,
  );
  const eref = db.doc(`events/${c.eventId}`),
    rref = db.doc(`registrations/${rid}`);
  const requestHash = hash(JSON.stringify(c));
  return db.runTransaction(async (tx) => {
    const previous = await tx.get(operation);
    if (previous.exists) {
      if (previous.data().requestHash !== requestHash)
        throw new HttpsError("already-exists", "operation-conflict");
      return previous.data().result;
    }
    const [edoc, rdoc] = await tx.getAll(eref, rref);
    let session, credential;
    if (c.action === "checkin") {
      const [sdoc, qdoc] = await tx.getAll(
        db.doc(`checkinSessions/${c.eventId}`),
        db.doc(`qrCredentials/${hash(c.qrToken)}`),
      );
      session = parsed(sdoc);
      credential = parsed(qdoc);
    }
    const now = Date.now();
    let decision;
    try {
      decision = decide({
        command: c,
        event: parsed(edoc),
        registration: parsed(rdoc),
        session,
        credential,
        now,
      });
    } catch (e) {
      if (!(e instanceof Rejection)) throw e;
      decision = { result: { status: "rejected", code: e.code } };
    }
    const result = {
      ...decision.result,
      registrationId: rid,
      eventId: c.eventId,
    };
    if (decision.registration) {
      tx.set(rref, {
        ...stored(decision.registration),
        uid,
        eventId: c.eventId,
      });
      tx.set(rref.collection("history").doc(c.operationId), {
        action: c.action,
        generation: decision.registration.generation,
        at: Timestamp.fromMillis(now),
        snapshot: stored(decision.registration),
      });
      const notice = db.doc(`users/${uid}/notifications/${c.operationId}`);
      tx.set(notice, {
        type: c.action,
        eventId: c.eventId,
        registrationId: rid,
        title:
          c.action === "register"
            ? "Đăng ký đã xác nhận"
            : c.action === "cancel"
              ? "Đã hủy đăng ký"
              : "Đã điểm danh",
        body: edoc.data().title,
        createdAt: Timestamp.fromMillis(now),
        readAt: null,
      });
    }
    if (decision.count !== undefined)
      tx.update(eref, { activeCount: decision.count });
    tx.create(operation, {
      uid,
      requestHash,
      result,
      createdAt: Timestamp.fromMillis(now),
    });
    return result;
  });
});
exports.bookingStatus = onCall(async (request) => {
  const uid = uidOf(request),
    op = request.data?.operationId;
  if (typeof op !== "string" || !/^[\w-]{16,120}$/.test(op))
    throw new HttpsError("invalid-argument", "invalid-operation");
  const doc = await db
    .doc(`operations/${hash(JSON.stringify([uid, op]))}`)
    .get();
  // Not found is NOT proof that an earlier in-flight request failed.
  return doc.exists ? doc.data().result : { status: "unknown" };
});
