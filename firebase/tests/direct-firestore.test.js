const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { createHash } = require('node:crypto');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { doc, getDoc, writeBatch, updateDoc, serverTimestamp, Timestamp } = require('firebase/firestore');

let env;
const operationId = 'a'.repeat(48);
const participant = {name: 'Test User', email: 'test@example.com', group: 'guest', cohort: '', organization: '', phone: ''};

before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error('Start Firestore emulator first.');
  env = await initializeTestEnvironment({
    projectId: 'demo-direct-booking',
    firestore: {rules: readFileSync(join(__dirname, '../firestore.rules'), 'utf8')},
  });
});
after(async () => env?.cleanup());

async function seed(eventId, capacity = 1) {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async context => {
    await context.firestore().doc(`events/${eventId}`).set({
      visibility: 'public', status: 'published', registrationMode: 'required',
      startsAt: Timestamp.fromMillis(Date.now() + 3600000),
      deadline: Timestamp.fromMillis(Date.now() + 1800000),
      capacity, activeCount: 0,
    });
  });
}
function userDb(uid = 'alice') {
  return env.authenticatedContext(uid, {email_verified: true}).firestore();
}
function registerBatch(db, uid, eventId) {
  const batch = writeBatch(db);
  batch.set(doc(db, 'registrations', `${uid}_${eventId}`), {
    uid, eventId, status: 'active', generation: 1, participant,
    checkInAt: null, createdAt: serverTimestamp(), lastOperationId: operationId,
  });
  batch.update(doc(db, 'events', eventId), {activeCount: 1});
  return batch.commit();
}

test('owner can atomically register; count-only and other-user writes are denied', async () => {
  await seed('direct-a');
  const db = userDb();
  await assertFails(updateDoc(doc(db, 'events', 'direct-a'), {activeCount: 1}));
  await assertFails(registerBatch(db, 'bob', 'direct-a'));
  await assertSucceeds(registerBatch(db, 'alice', 'direct-a'));
  assert.equal((await getDoc(doc(db, 'events', 'direct-a'))).data().activeCount, 1);
  await assertFails(registerBatch(userDb('bob'), 'bob', 'direct-a'));
});

test('owner can cancel with count decrement; check-in cannot be forged', async () => {
  await seed('direct-b');
  const db = userDb();
  await assertSucceeds(registerBatch(db, 'alice', 'direct-b'));
  const ref = doc(db, 'registrations', 'alice_direct-b');
  await assertFails(updateDoc(ref, {checkInAt: serverTimestamp(), qrHash: 'b'.repeat(64), lastOperationId: 'b'.repeat(48)}));
  const batch = writeBatch(db);
  batch.update(ref, {status: 'cancelled', lastOperationId: 'c'.repeat(48)});
  batch.update(doc(db, 'events', 'direct-b'), {activeCount: 0});
  await assertSucceeds(batch.commit());
  assert.equal((await getDoc(ref)).data().status, 'cancelled');
});

test('a web-created QR credential and open session allow one check-in', async () => {
  await seed('direct-c');
  const db = userDb();
  await assertSucceeds(registerBatch(db, 'alice', 'direct-c'));
  const token = 'long-random-qr-token-created-by-web-staff';
  const hash = createHash('sha256').update(token).digest('hex');
  await env.withSecurityRulesDisabled(async context => {
    await context.firestore().doc(`qrCredentials/${hash}`).set({eventId: 'direct-c', enabled: true});
    await context.firestore().doc('checkinSessions/direct-c').set({open: true});
  });
  const ref = doc(db, 'registrations', 'alice_direct-c');
  await assertSucceeds(updateDoc(ref, {
    checkInAt: serverTimestamp(), qrHash: hash, lastOperationId: 'd'.repeat(48),
  }));
  assert.ok((await getDoc(ref)).data().checkInAt);
  await assertFails(updateDoc(ref, {
    checkInAt: serverTimestamp(), qrHash: hash, lastOperationId: 'e'.repeat(48),
  }));
});

test('cancelled registration can be recreated with next generation, unverified user cannot', async () => {
  await seed('direct-d');
  const db = userDb();
  await assertSucceeds(registerBatch(db, 'alice', 'direct-d'));
  const ref = doc(db, 'registrations', 'alice_direct-d');
  const cancel = writeBatch(db);
  cancel.update(ref, {status: 'cancelled', lastOperationId: 'b'.repeat(48)});
  cancel.update(doc(db, 'events', 'direct-d'), {activeCount: 0});
  await assertSucceeds(cancel.commit());
  const again = writeBatch(db);
  again.set(ref, {
    uid: 'alice', eventId: 'direct-d', status: 'active', generation: 2,
    participant, checkInAt: null, createdAt: serverTimestamp(),
    lastOperationId: 'c'.repeat(48),
  });
  again.update(doc(db, 'events', 'direct-d'), {activeCount: 1});
  await assertSucceeds(again.commit());
  assert.equal((await getDoc(ref)).data().generation, 2);
  const unverified = env.authenticatedContext('eve', {email_verified: false}).firestore();
  await assertFails(registerBatch(unverified, 'eve', 'direct-d'));
});
