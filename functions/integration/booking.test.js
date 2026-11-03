const { test, before, after } = require("node:test");
const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const {
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  collection,
  query,
  where,
  serverTimestamp,
} = require("firebase/firestore");
let env, db, command;
const auth = (uid) => ({ uid, token: { email_verified: true } });
const p = { name: "Test", email: "test@example.com", group: "guest" };
const op = (n) => `integration-operation-${n}`;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST)
    throw new Error("Run with Firestore emulator.");
  process.env.GCLOUD_PROJECT = "demo-eventhub";
  env = await initializeTestEnvironment({
    projectId: "demo-eventhub",
    firestore: { rules: readFileSync(join(__dirname, "../../firebase/firestore.rules"), "utf8") },
  });
  command = require("../src/index").bookingCommand;
  db = require("firebase-admin/firestore").getFirestore();
});
after(async () => {
  await env?.cleanup();
});
async function seed(id = "event") {
  const { Timestamp } = require("firebase-admin/firestore");
  await db
    .doc(`events/${id}`)
    .set({
      title: "Test event",
      visibility: "public",
      status: "published",
      registrationMode: "required",
      startsAt: Timestamp.fromMillis(Date.now() + 3600000),
      endsAt: Timestamp.fromMillis(Date.now() + 7200000),
      deadline: Timestamp.fromMillis(Date.now() + 1800000),
      capacity: 1,
      activeCount: 0,
    });
}
const execute = (uid, data) => command.run({ auth: auth(uid), data });
test("real transactions prevent oversubscription and replay same operation", async () => {
  await seed("capacity");
  const payload = {
    action: "register",
    eventId: "capacity",
    participant: p,
    operationId: op("one"),
  };
  const [a, b] = await Promise.all([
    execute("alice", payload),
    execute("bob", { ...payload, operationId: op("two") }),
  ]);
  assert.equal([a, b].filter((x) => x.status === "confirmed").length, 1);
  assert.equal([a, b].filter((x) => x.code === "event-full").length, 1);
  assert.equal((await db.doc("events/capacity").get()).data().activeCount, 1);
  const uid = a.status === "confirmed" ? "alice" : "bob";
  const original =
    a.status === "confirmed" ? payload : { ...payload, operationId: op("two") };
  assert.deepEqual(
    await execute(uid, original),
    a.status === "confirmed" ? a : b,
  );
  assert.equal((await db.doc("events/capacity").get()).data().activeCount, 1);
  await assert.rejects(
    execute(uid, { ...original, participant: { ...p, name: "changed" } }),
    (e) => e.code === "already-exists",
  );
});
test("cancel/re-register isolates generations and preserves first check-in time", async () => {
  const { hash } = require("../src/booking");
  await seed("flow");
  const r = await execute("flow-user", {
    action: "register",
    eventId: "flow",
    participant: p,
    operationId: op("flow-register"),
  });
  await execute("flow-user", {
    action: "cancel",
    eventId: "flow",
    generation: 1,
    operationId: op("flow-cancel"),
  });
  const next = await execute("flow-user", {
    action: "register",
    eventId: "flow",
    participant: p,
    operationId: op("flow-again"),
  });
  assert.equal(next.generation, 2);
  const stale = await execute("flow-user", {
    action: "cancel",
    eventId: "flow",
    generation: 1,
    operationId: op("flow-stale"),
  });
  assert.equal(stale.code, "stale-generation");
  await db.doc("checkinSessions/flow").set({ open: true });
  await db
    .doc(`qrCredentials/${hash("test-token")}`)
    .set({ enabled: true, eventId: "flow" });
  const a = await execute("flow-user", {
    action: "checkin",
    eventId: "flow",
    generation: 2,
    qrToken: "test-token",
    operationId: op("checkin1"),
  });
  await db.doc("checkinSessions/flow").set({ open: false });
  const b = await execute("flow-user", {
    action: "checkin",
    eventId: "flow",
    generation: 2,
    qrToken: "test-token",
    operationId: op("checkin2"),
  });
  assert.equal(a.checkInAtMs, b.checkInAtMs);
  assert.equal(
    (
      await db
        .doc(`registrations/${r.registrationId}/history/${op("checkin1")}`)
        .get()
    ).exists,
    true,
  );
});
test("rules restrict private records, unverified/anonymous access and all booking writes", async () => {
  await seed("rules");
  const result = await execute("owner", {
    action: "register",
    eventId: "rules",
    participant: p,
    operationId: op("rules"),
  });
  const owner = env
      .authenticatedContext("owner", { email_verified: true })
      .firestore(),
    other = env
      .authenticatedContext("other", { email_verified: true })
      .firestore();
  await assertSucceeds(
    getDoc(doc(owner, `registrations/${result.registrationId}`)),
  );
  await assertSucceeds(getDoc(doc(owner, "events/not-found")));
  await assertSucceeds(getDoc(doc(owner, "registrations/not-found")));
  await assertFails(
    getDoc(doc(other, `registrations/${result.registrationId}`)),
  );
  await assertFails(
    setDoc(doc(owner, "registrations/forged"), {
      uid: "owner",
      status: "active",
    }),
  );
  await assertFails(updateDoc(doc(owner, "events/rules"), { activeCount: 0 }));
  await assertFails(
    getDoc(doc(env.unauthenticatedContext().firestore(), "events/rules")),
  );
  await assertFails(
    getDoc(
      doc(
        env
          .authenticatedContext("unverified", { email_verified: false })
          .firestore(),
        "events/rules",
      ),
    ),
  );
  await assertSucceeds(
    getDocs(
      query(collection(owner, "events"), where("visibility", "==", "public")),
    ),
  );
  await assertFails(getDocs(collection(owner, "registrations")));
  await assertSucceeds(
    getDocs(
      query(collection(owner, "registrations"), where("uid", "==", "owner")),
    ),
  );
  const notice = doc(owner, `users/owner/notifications/${op("rules")}`);
  await assertSucceeds(updateDoc(notice, { readAt: serverTimestamp() }));
  await assertFails(updateDoc(notice, { title: "forged" }));
  await assertFails(getDoc(doc(owner, "qrCredentials/private-token")));
});
