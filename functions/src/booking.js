"use strict";
const { createHash } = require("node:crypto");
class Rejection extends Error {
  constructor(code) {
    super(code);
    this.code = code;
  }
}
const reject = (code) => {
  throw new Rejection(code);
};
function text(value, max = 160) {
  return typeof value === "string" && value.trim().length <= max
    ? value.trim()
    : "";
}
function participant(input = {}) {
  if (input === null || typeof input !== "object" || Array.isArray(input))
    reject("invalid-participant");
  const p = {
    name: text(input.name, 100),
    email: text(input.email, 254),
    group:
      input.group === "student"
        ? "student"
        : input.group === "guest"
          ? "guest"
          : "",
    cohort: text(input.cohort, 30),
    organization: text(input.organization, 160),
    phone: text(input.phone, 30),
  };
  if (
    !p.name ||
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(p.email) ||
    !p.group ||
    (p.group === "student" && !p.cohort)
  )
    reject("invalid-participant");
  if (p.group === "guest") p.cohort = "";
  else p.organization = "";
  return p;
}
const hash = (value) => createHash("sha256").update(value).digest("hex");
const registrationId = (uid, eventId) => hash(JSON.stringify([uid, eventId]));
function validateCommand(raw) {
  if (raw === null || typeof raw !== "object" || Array.isArray(raw))
    reject("invalid-command");
  const action = raw.action,
    eventId = text(raw.eventId, 120),
    operationId = text(raw.operationId, 120);
  if (
    !["register", "cancel", "checkin"].includes(action) ||
    !/^[\w-]+$/.test(eventId) ||
    !/^[\w-]{16,120}$/.test(operationId)
  )
    reject("invalid-command");
  const c = { action, eventId, operationId };
  if (action === "register") c.participant = participant(raw.participant);
  else {
    if (!Number.isInteger(raw.generation) || raw.generation < 1)
      reject("invalid-generation");
    c.generation = raw.generation;
  }
  if (action === "checkin") {
    c.qrToken = text(raw.qrToken, 512);
    if (!c.qrToken) reject("invalid-qr");
  }
  return c;
}
// Pure business decision. All timestamps below are supplied by the trusted backend.
function decide({
  command: c,
  event: e,
  registration: r,
  session,
  credential,
  now,
}) {
  const result = (status) => ({
    status,
    registrationId: r?.id,
    generation: r?.generation,
  });
  if (!e || e.visibility !== "public") reject("event-not-found");
  if (c.action === "register") {
    if (r?.status === "active") return { result: result("existing") };
    if (e.registrationMode === "free") reject("free-entry");
    if (e.status !== "published") reject("event-cancelled");
    if (!Number.isFinite(e.deadlineMs) || !Number.isFinite(e.startsAtMs))
      reject("invalid-event");
    if (e.deadlineMs <= now || e.startsAtMs <= now)
      reject("registration-expired");
    if (
      !Number.isInteger(e.capacity) ||
      !Number.isInteger(e.activeCount) ||
      e.activeCount < 0
    )
      reject("invalid-event");
    if (e.activeCount >= e.capacity) reject("event-full");
    const generation = (r?.generation || 0) + 1;
    return {
      result: { status: "confirmed", generation },
      count: e.activeCount + 1,
      registration: {
        status: "active",
        generation,
        participant: c.participant,
        createdAtMs: now,
        cancelledAtMs: null,
        checkInAtMs: null,
      },
    };
  }
  if (!r || r.status !== "active") reject("registration-inactive");
  if (r.generation !== c.generation) reject("stale-generation");
  if (c.action === "cancel") {
    if (r.checkInAtMs || now >= e.startsAtMs || e.status !== "published")
      reject("cannot-cancel");
    if (e.activeCount < 1) reject("invalid-event");
    return {
      result: result("cancelled"),
      count: e.activeCount - 1,
      registration: { ...r, status: "cancelled", cancelledAtMs: now },
    };
  }
  if (e.status !== "published") reject("event-cancelled");
  // A repeated scan returns the original timestamp even after the session closes.
  if (r.checkInAtMs)
    return { result: { ...result("checked-in"), checkInAtMs: r.checkInAtMs } };
  if (!credential?.enabled) reject("invalid-qr");
  if (credential.eventId !== c.eventId) reject("wrong-event");
  if (!session?.open) reject("session-closed");
  return {
    result: { ...result("checked-in"), checkInAtMs: now },
    registration: { ...r, checkInAtMs: now },
  };
}
module.exports = { Rejection, hash, registrationId, validateCommand, decide };
