const { test } = require("node:test");
const assert = require("node:assert/strict");
const { validateCommand, decide, registrationId } = require("../src/booking");
const p = {
  name: "Minh Anh",
  email: "a@example.com",
  group: "student",
  cohort: "K18",
};
const c = () =>
  validateCommand({
    action: "register",
    eventId: "workshop",
    operationId: "a".repeat(32),
    participant: p,
  });
const event = {
  visibility: "public",
  status: "published",
  registrationMode: "required",
  deadlineMs: 200,
  startsAtMs: 300,
  capacity: 1,
  activeCount: 0,
};
function run(command = c(), overrides = {}) {
  return decide({ command, event, now: 100, ...overrides });
}
test("student requires cohort, guest clears it", () => {
  assert.throws(() =>
    validateCommand({ ...c(), participant: { ...p, cohort: "" } }),
  );
  assert.equal(
    validateCommand({
      ...c(),
      participant: { ...p, group: "guest", cohort: "K99" },
    }).participant.cohort,
    "",
  );
});
test("reject free/full/expired/cancelled before creating registration", () => {
  for (const [field, value, code] of [
    ["registrationMode", "free", "free-entry"],
    ["activeCount", 1, "event-full"],
    ["deadlineMs", 99, "registration-expired"],
    ["status", "cancelled", "event-cancelled"],
  ])
    assert.throws(
      () => run(c(), { event: { ...event, [field]: value } }),
      (e) => e.code === code,
    );
});
test("existing active registration wins over full and expired", () => {
  const d = run(c(), {
    event: { ...event, activeCount: 1, deadlineMs: 0 },
    registration: { id: "r", status: "active", generation: 1 },
  });
  assert.equal(d.result.status, "existing");
  assert.equal(d.count, undefined);
});
test("cancel and re-register increases generation without losing history", () => {
  const r = { id: "r", ...run().registration };
  const cancelled = run(
    { action: "cancel", generation: 1 },
    { registration: r, event: { ...event, activeCount: 1 } },
  );
  assert.equal(cancelled.count, 0);
  const again = run(c(), { registration: cancelled.registration });
  assert.equal(again.registration.generation, 2);
  assert.throws(
    () =>
      run(
        { action: "cancel", generation: 1 },
        { registration: again.registration },
      ),
    (e) => e.code === "stale-generation",
  );
});
test("checkin validates QR event, session, preserves first timestamp", () => {
  const r = { id: "r", ...run().registration };
  const command = { action: "checkin", generation: 1, eventId: "workshop" };
  assert.throws(
    () =>
      run(command, {
        registration: r,
        credential: { enabled: true, eventId: "other" },
        session: { open: true },
      }),
    (e) => e.code === "wrong-event",
  );
  assert.throws(
    () =>
      run(command, {
        registration: r,
        credential: { enabled: true, eventId: "workshop" },
        session: { open: false },
      }),
    (e) => e.code === "session-closed",
  );
  const ok = run(command, {
    registration: r,
    credential: { enabled: true, eventId: "workshop" },
    session: { open: true },
  });
  assert.equal(ok.result.checkInAtMs, 100);
  assert.equal(
    run(command, {
      registration: ok.registration,
      now: 200,
      session: { open: false },
    }).result.checkInAtMs,
    100,
  );
});
test("cannot cancel after check-in/start or check in cancelled registration", () => {
  assert.throws(
    () =>
      run(
        { action: "cancel", generation: 1 },
        {
          registration: { status: "active", generation: 1, checkInAtMs: 90 },
          event: { ...event, activeCount: 1 },
        },
      ),
    (e) => e.code === "cannot-cancel",
  );
  assert.throws(
    () =>
      run(
        { action: "checkin", generation: 1 },
        { registration: { status: "cancelled", generation: 1 } },
      ),
    (e) => e.code === "registration-inactive",
  );
});
test("registration IDs distinguish delimiter collisions", () => {
  assert.notEqual(registrationId("a_b", "c"), registrationId("a", "b_c"));
});

test("malformed command and participant are rejected safely", () => {
  assert.throws(
    () => validateCommand(null),
    (e) => e.code === "invalid-command",
  );
  assert.throws(
    () => validateCommand({ ...c(), participant: null }),
    (e) => e.code === "invalid-participant",
  );
});
