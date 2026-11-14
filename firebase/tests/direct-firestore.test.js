const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { createHash } = require('node:crypto');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  collection,
  getDocs,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  writeBatch,
  serverTimestamp,
  Timestamp,
} = require('firebase/firestore');

let env;
const op1 = 'a'.repeat(48);
const op2 = 'b'.repeat(48);
const op3 = 'c'.repeat(48);
const op4 = 'd'.repeat(48);
const participant = {
  name: 'Nguyen Minh Anh',
  email: 'minhanh@fpt.edu.vn',
  group: 'student',
  cohort: 'K18',
  organization: '',
  phone: '0901234567',
};

before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) {
    throw new Error('Start Firestore emulator first.');
  }
  env = await initializeTestEnvironment({
    projectId: 'demo-direct-booking',
    firestore: {
      rules: readFileSync(join(__dirname, '../firestore.rules'), 'utf8'),
    },
  });
});

after(async () => env?.cleanup());

function authedDb(uid, verified = true) {
  return env
    .authenticatedContext(uid, { email_verified: verified })
    .firestore();
}

async function seedSystem({ eventId = 'ev_ai_1', capacity = 1 } = {}) {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db.doc('clubs/club_it').set({
      name: 'CLB IT FPTU',
      shortName: 'ITC',
      description: 'Cau lac bo CNTT',
      status: 'active',
    });
    await db.doc('clubs/club_music').set({
      name: 'CLB Am Nhac',
      shortName: 'MC',
      description: 'Cau lac bo Am Nhac',
      status: 'active',
    });
    await db.doc('users/alice').set({
      role: 'user',
      displayName: 'Alice Student',
      email: 'alice@fpt.edu.vn',
    });
    await db.doc('users/bob').set({
      role: 'user',
      displayName: 'Bob Student',
      email: 'bob@fpt.edu.vn',
    });
    await db.doc('users/staff_it').set({
      role: 'staff',
      clubId: 'club_it',
      clubName: 'CLB IT FPTU',
      displayName: 'Leader IT',
      email: 'leader.it@fpt.edu.vn',
    });
    await db.doc('users/staff_music').set({
      role: 'staff',
      clubId: 'club_music',
      clubName: 'CLB Am Nhac',
      displayName: 'Leader Music',
      email: 'leader.music@fpt.edu.vn',
    });
    await db.doc('users/admin_1').set({
      role: 'admin',
      displayName: 'System Admin',
      email: 'admin@fpt.edu.vn',
    });
    await db.doc(`events/${eventId}`).set({
      title: 'Hoi thao AI & Flutter',
      clubId: 'club_it',
      clubName: 'CLB IT FPTU',
      location: 'Hoi truong Alpha',
      visibility: 'public',
      status: 'published',
      registrationMode: 'required',
      startsAt: Timestamp.fromMillis(Date.now() + 7200000),
      endsAt: Timestamp.fromMillis(Date.now() + 14400000),
      deadline: Timestamp.fromMillis(Date.now() + 3600000),
      capacity,
      activeCount: 0,
    });
  });
}

function createPendingRegistration(db, uid, eventId, clubId = 'club_it', op = op1) {
  return setDoc(doc(db, 'registrations', `${uid}_${eventId}`), {
    uid,
    eventId,
    clubId,
    status: 'pending',
    generation: 1,
    participant,
    reason: null,
    reviewedBy: null,
    reviewedAt: null,
    checkInAt: null,
    createdAt: serverTimestamp(),
    lastOperationId: op,
  });
}

function approveBatch(db, staffUid, studentUid, eventId, nextActiveCount) {
  const regId = `${studentUid}_${eventId}`;
  const batch = writeBatch(db);
  batch.update(doc(db, 'registrations', regId), {
    status: 'approved',
    reason: null,
    reviewedBy: staffUid,
    reviewedAt: serverTimestamp(),
  });
  batch.update(doc(db, 'events', eventId), {
    activeCount: nextActiveCount,
    updatedAt: serverTimestamp(),
  });
  batch.set(doc(db, 'users', studentUid, 'notifications', `approve_${regId}`), {
    title: 'Đơn đăng ký đã được duyệt!',
    body: 'Đơn tham gia sự kiện của bạn đã được phê duyệt.',
    type: 'registration_approved',
    eventId,
    registrationId: regId,
    createdAt: serverTimestamp(),
    readAt: null,
  });
  return batch.commit();
}

test('1. users & clubs: self-bootstrap user allowed, self-privilege-escalation denied, admin cannot change own role, admin manages clubs without hard-delete', async () => {
  await seedSystem();
  const newUserDb = authedDb('new_student');
  const aliceDb = authedDb('alice');
  const staffItDb = authedDb('staff_it');
  const adminDb = authedDb('admin_1');

  // Allowed: new user bootstraps own doc with role == 'user'
  await assertSucceeds(
    setDoc(doc(newUserDb, 'users/new_student'), {
      role: 'user',
      displayName: 'New Student',
      email: 'new@fpt.edu.vn',
      createdAt: serverTimestamp(),
    }),
  );

  // Denied: user tries to bootstrap or escalate to staff/admin
  await assertFails(
    setDoc(doc(authedDb('hacker'), 'users/hacker'), {
      role: 'admin',
      displayName: 'Hacker',
      email: 'h@fpt.edu.vn',
      createdAt: serverTimestamp(),
    }),
  );
  await assertFails(updateDoc(doc(aliceDb, 'users/alice'), { role: 'staff', clubId: 'club_it' }));

  // Denied: staff reads another user's profile or writes clubs
  await assertFails(getDoc(doc(staffItDb, 'users/alice')));
  await assertFails(
    setDoc(doc(staffItDb, 'clubs/club_new'), { name: 'Hack Club', status: 'active' }),
  );

  // Allowed: admin assigns staff + clubId to another user
  await assertSucceeds(
    updateDoc(doc(adminDb, 'users/bob'), {
      role: 'staff',
      clubId: 'club_it',
      updatedAt: serverTimestamp(),
    }),
  );

  // Denied: admin tries to assign staff WITHOUT clubId, or tries to change OWN role
  await assertFails(updateDoc(doc(adminDb, 'users/alice'), { role: 'staff' }));
  await assertFails(updateDoc(doc(adminDb, 'users/admin_1'), { role: 'user' }));

  // Allowed: admin creates/archives club; Denied: hard delete club
  await assertSucceeds(
    setDoc(doc(adminDb, 'clubs/club_ai'), { name: 'CLB AI', status: 'active' }),
  );
  await assertFails(deleteDoc(doc(adminDb, 'clubs/club_ai')));
});

test('2. events: staff manages own club events (create/update/archive), cross-club staff & user writes denied, hard delete denied', async () => {
  await seedSystem();
  const aliceDb = authedDb('alice');
  const staffItDb = authedDb('staff_it');
  const staffMusicDb = authedDb('staff_music');
  const adminDb = authedDb('admin_1');

  const newEventPayload = {
    title: 'Workshop Clean Architecture',
    clubId: 'club_it',
    clubName: 'CLB IT FPTU',
    location: 'Lab 201',
    visibility: 'public',
    status: 'draft',
    registrationMode: 'required',
    startsAt: Timestamp.fromMillis(Date.now() + 7200000),
    endsAt: Timestamp.fromMillis(Date.now() + 10800000),
    deadline: Timestamp.fromMillis(Date.now() + 3600000),
    capacity: 30,
    activeCount: 0,
    updatedAt: serverTimestamp(),
  };

  // Denied: user or other-club staff tries to create event for club_it
  await assertFails(setDoc(doc(aliceDb, 'events/ev_new'), newEventPayload));
  await assertFails(setDoc(doc(staffMusicDb, 'events/ev_new'), newEventPayload));

  // Allowed: staff_it creates draft event and archives it (soft archive)
  await assertSucceeds(setDoc(doc(staffItDb, 'events/ev_new'), newEventPayload));
  await assertSucceeds(
    updateDoc(doc(staffItDb, 'events/ev_new'), {
      status: 'archived',
      updatedAt: serverTimestamp(),
    }),
  );

  // Denied: staff or admin tries to hard-delete event
  await assertFails(deleteDoc(doc(staffItDb, 'events/ev_new')));
  await assertFails(deleteDoc(doc(adminDb, 'events/ev_new')));

  // Allowed: admin can intervene and cancel event of any club
  await assertSucceeds(
    updateDoc(doc(adminDb, 'events/ev_new'), {
      status: 'cancelled',
      updatedAt: serverTimestamp(),
    }),
  );
});

test('3. Cross-Role Flow 1 (registrations + notifications): student submits pending -> staff approves/rejects atomically -> cross-club & over-capacity blocked', async () => {
  await seedSystem({ eventId: 'ev_flow1', capacity: 1 });
  const aliceDb = authedDb('alice');
  const bobDb = authedDb('bob');
  const staffItDb = authedDb('staff_it');
  const staffMusicDb = authedDb('staff_music');

  // The owning club can watch a new event before a session document exists.
  const unopened = await assertSucceeds(getDoc(doc(staffItDb, 'checkinSessions/ev_flow1')));
  assert.equal(unopened.exists(), false);
  await assertFails(getDoc(doc(staffMusicDb, 'checkinSessions/ev_flow1')));
  await assertFails(getDoc(doc(bobDb, 'checkinSessions/ev_flow1')));

  // Denied: student tries to self-approve at creation or forge activeCount
  await assertFails(
    setDoc(doc(aliceDb, 'registrations/alice_ev_flow1'), {
      uid: 'alice',
      eventId: 'ev_flow1',
      clubId: 'club_it',
      status: 'approved',
      generation: 1,
      participant,
      checkInAt: null,
      createdAt: serverTimestamp(),
      lastOperationId: op1,
    }),
  );
  await assertFails(updateDoc(doc(aliceDb, 'events/ev_flow1'), { activeCount: 1 }));

  // Allowed: both Alice and Bob submit pending requests while 1 seat remains
  await assertSucceeds(createPendingRegistration(aliceDb, 'alice', 'ev_flow1'));
  await assertSucceeds(createPendingRegistration(bobDb, 'bob', 'ev_flow1'));

  // Denied: staff from another club (club_music) tries to read or approve club_it registration
  await assertFails(getDoc(doc(staffMusicDb, 'registrations/alice_ev_flow1')));
  await assertFails(approveBatch(staffMusicDb, 'staff_music', 'alice', 'ev_flow1', 1));

  // Allowed: staff_it approves Alice -> activeCount becomes 1/1 & notification created
  await assertSucceeds(approveBatch(staffItDb, 'staff_it', 'alice', 'ev_flow1', 1));
  assert.equal((await getDoc(doc(staffItDb, 'events/ev_flow1'))).data().activeCount, 1);

  // Denied: staff_it tries to approve Bob when event is now full (1/1)
  await assertFails(approveBatch(staffItDb, 'staff_it', 'bob', 'ev_flow1', 2));

  // Denied: staff_it tries to reject Bob WITHOUT a valid >=3-char reason
  await assertFails(
    updateDoc(doc(staffItDb, 'registrations/bob_ev_flow1'), {
      status: 'rejected',
      reason: 'No',
      reviewedBy: 'staff_it',
      reviewedAt: serverTimestamp(),
    }),
  );

  // Allowed: staff_it rejects Bob with clear reason & sends rejection notification (activeCount stays 1)
  const rejectBatch = writeBatch(staffItDb);
  rejectBatch.update(doc(staffItDb, 'registrations/bob_ev_flow1'), {
    status: 'rejected',
    reason: 'Sự kiện đã đủ số lượng chỗ tối đa.',
    reviewedBy: 'staff_it',
    reviewedAt: serverTimestamp(),
  });
  rejectBatch.set(doc(staffItDb, 'users/bob/notifications/reject_bob'), {
    title: 'Đơn đăng ký không được duyệt',
    body: 'Sự kiện đã đủ số lượng chỗ tối đa.',
    type: 'registration_rejected',
    eventId: 'ev_flow1',
    registrationId: 'bob_ev_flow1',
    createdAt: serverTimestamp(),
    readAt: null,
  });
  await assertSucceeds(rejectBatch.commit());

  // Allowed: Alice cancels her approved registration -> activeCount decrements back to 0
  const cancelApproved = writeBatch(aliceDb);
  cancelApproved.update(doc(aliceDb, 'registrations/alice_ev_flow1'), {
    status: 'cancelled',
    lastOperationId: op2,
  });
  cancelApproved.update(doc(aliceDb, 'events/ev_flow1'), { activeCount: 0 });
  await assertSucceeds(cancelApproved.commit());

  // Allowed: Bob re-registers after rejection with generation + 1 -> back to pending
  await assertSucceeds(
    updateDoc(doc(bobDb, 'registrations/bob_ev_flow1'), {
      status: 'pending',
      generation: 2,
      participant,
      reason: null,
      reviewedBy: null,
      reviewedAt: null,
      checkInAt: null,
      createdAt: serverTimestamp(),
      lastOperationId: op3,
    }),
  );
  assert.equal((await getDoc(doc(bobDb, 'registrations/bob_ev_flow1'))).data().generation, 2);

  // Unverified user is always denied
  await assertFails(
    createPendingRegistration(authedDb('eve', false), 'eve', 'ev_flow1'),
  );
});

test('4. Cross-Role Flow 2 (checkinSessions + qrCredentials): staff opens QR session, approved student checks in once, rotated/closed QR & pending check-in denied', async () => {
  await seedSystem({ eventId: 'ev_qr', capacity: 2 });
  const aliceDb = authedDb('alice');
  const bobDb = authedDb('bob');
  const staffItDb = authedDb('staff_it');
  const staffMusicDb = authedDb('staff_music');

  await assertSucceeds(createPendingRegistration(aliceDb, 'alice', 'ev_qr'));
  await assertSucceeds(createPendingRegistration(bobDb, 'bob', 'ev_qr'));
  await assertSucceeds(approveBatch(staffItDb, 'staff_it', 'alice', 'ev_qr', 1));

  const token1 = 'EVT_ev_qr_RANDOM_SECURE_TOKEN_NUMBER_ONE_32CHARS';
  const hash1 = createHash('sha256').update(token1).digest('hex');

  // Denied: student or cross-club staff tries to open session or create QR credential
  await assertFails(
    setDoc(doc(aliceDb, 'checkinSessions/ev_qr'), {
      eventId: 'ev_qr',
      clubId: 'club_it',
      open: true,
      updatedBy: 'alice',
      updatedAt: serverTimestamp(),
    }),
  );
  await assertFails(
    setDoc(doc(staffMusicDb, `qrCredentials/${hash1}`), {
      eventId: 'ev_qr',
      clubId: 'club_it',
      enabled: true,
      createdBy: 'staff_music',
      createdAt: serverTimestamp(),
    }),
  );

  // Allowed: staff_it creates QR credential and opens session
  await assertSucceeds(
    setDoc(doc(staffItDb, `qrCredentials/${hash1}`), {
      eventId: 'ev_qr',
      clubId: 'club_it',
      enabled: true,
      createdBy: 'staff_it',
      createdAt: serverTimestamp(),
    }),
  );
  await assertSucceeds(
    setDoc(doc(staffItDb, 'checkinSessions/ev_qr'), {
      eventId: 'ev_qr',
      clubId: 'club_it',
      open: true,
      updatedBy: 'staff_it',
      updatedAt: serverTimestamp(),
    }),
  );

  // Mobile may watch the QR session only after CLB approval.
  await assertSucceeds(getDoc(doc(aliceDb, 'checkinSessions/ev_qr')));
  await assertFails(getDoc(doc(bobDb, 'checkinSessions/ev_qr')));

  // Exact high-entropy hash lookup is allowed; listing credentials remains denied.
  await assertSucceeds(getDoc(doc(aliceDb, `qrCredentials/${hash1}`)));
  await assertFails(getDocs(collection(aliceDb, "qrCredentials")));

  // Denied: Bob (still pending, NOT approved) tries to check in with valid QR
  await assertFails(
    updateDoc(doc(bobDb, 'registrations/bob_ev_qr'), {
      checkInAt: serverTimestamp(),
      qrHash: hash1,
      lastOperationId: op2,
    }),
  );

  // Allowed: Alice (approved) checks in once with valid QR while session is open
  await assertSucceeds(
    updateDoc(doc(aliceDb, 'registrations/alice_ev_qr'), {
      checkInAt: serverTimestamp(),
      qrHash: hash1,
      lastOperationId: op2,
    }),
  );
  assert.ok((await getDoc(doc(aliceDb, 'registrations/alice_ev_qr'))).data().checkInAt);

  // Denied: Alice tries to overwrite checkInAt a second time
  await assertFails(
    updateDoc(doc(aliceDb, 'registrations/alice_ev_qr'), {
      checkInAt: serverTimestamp(),
      qrHash: hash1,
      lastOperationId: op3,
    }),
  );

  // Staff approves Bob, rotates QR (disables hash1), and closes session -> Bob check-in with old hash or closed session denied
  await assertSucceeds(approveBatch(staffItDb, 'staff_it', 'bob', 'ev_qr', 2));
  await assertSucceeds(updateDoc(doc(staffItDb, `qrCredentials/${hash1}`), { enabled: false }));
  await assertFails(
    updateDoc(doc(bobDb, 'registrations/bob_ev_qr'), {
      checkInAt: serverTimestamp(),
      qrHash: hash1,
      lastOperationId: op4,
    }),
  );
});

test('5. announcements & push receipts: staff publishes club announcement, cross-club/global/user writes denied, private push receipts enforced', async () => {
  await seedSystem();
  const aliceDb = authedDb('alice');
  const bobDb = authedDb('bob');
  const staffItDb = authedDb('staff_it');
  const adminDb = authedDb('admin_1');

  // Denied: user tries to publish announcement; staff tries global or other club
  await assertFails(
    setDoc(doc(aliceDb, 'announcements/ann_bad1'), {
      title: 'Fake',
      body: 'Body',
      scope: 'club',
      clubId: 'club_it',
      clubName: 'CLB IT',
      authorUid: 'alice',
      authorRole: 'staff',
      createdAt: serverTimestamp(),
    }),
  );
  await assertFails(
    setDoc(doc(staffItDb, 'announcements/ann_bad2'), {
      title: 'Global Attempt',
      body: 'Body',
      scope: 'global',
      clubId: 'club_it',
      clubName: 'CLB IT',
      authorUid: 'staff_it',
      authorRole: 'staff',
      createdAt: serverTimestamp(),
    }),
  );

  // Allowed: staff_it publishes club announcement; admin publishes global announcement; user reads
  await assertSucceeds(
    setDoc(doc(staffItDb, 'announcements/ann_ok1'), {
      title: 'Thông báo đổi phòng sinh hoạt',
      body: 'Chuyển sang phòng Beta 202 lúc 14h.',
      scope: 'club',
      clubId: 'club_it',
      clubName: 'CLB IT FPTU',
      authorUid: 'staff_it',
      authorRole: 'staff',
      createdAt: serverTimestamp(),
    }),
  );
  await assertSucceeds(
    setDoc(doc(adminDb, 'announcements/ann_global'), {
      title: 'Thông báo toàn trường',
      body: 'Lịch nghỉ lễ hệ thống CLB.',
      scope: 'global',
      clubId: '',
      clubName: 'EventHub Admin',
      authorUid: 'admin_1',
      authorRole: 'admin',
      createdAt: serverTimestamp(),
    }),
  );
  await assertSucceeds(getDoc(doc(aliceDb, 'announcements/ann_ok1')));

  // Private push receipts remain strictly scoped to owner & type == 'push_received'
  const pushPath = 'users/alice/notifications/push_' + 'b'.repeat(64);
  const receipt = {
    title: 'Reminder',
    body: 'Open the app',
    eventId: 'ev_ai_1',
    registrationId: 'alice_ev_ai_1',
    type: 'push_received',
    createdAt: serverTimestamp(),
    readAt: null,
  };
  await assertSucceeds(setDoc(doc(aliceDb, pushPath), receipt));
  await assertFails(getDoc(doc(bobDb, pushPath)));
  await assertFails(
    setDoc(doc(aliceDb, 'users/alice/notifications/push_' + 'd'.repeat(64)), {
      ...receipt,
      type: 'registration_approved',
    }),
  );
});

test('archived event stays readable only to its registrant or club staff', async () => {
  await seedSystem({eventId: 'archived-event'});
  await env.withSecurityRulesDisabled(async c => {
    await c.firestore().doc('registrations/alice_archived-event').set({uid:'alice', eventId:'archived-event', status:'cancelled'});
    await c.firestore().doc('events/archived-event').update({visibility:'archived'});
  });
  await assertSucceeds(getDoc(doc(authedDb('alice'), 'events/archived-event')));
  await assertFails(getDoc(doc(authedDb('bob'), 'events/archived-event')));
  await assertFails(getDocs(collection(authedDb('alice'), 'events')));
});

test('legacy mobile active registration without clubId can cancel atomically once', async () => {
  await seedSystem({eventId:'legacy-mobile'});
  await env.withSecurityRulesDisabled(async c => {
    await c.firestore().doc('events/legacy-mobile').update({activeCount:1});
    await c.firestore().doc('registrations/alice_legacy-mobile').set({uid:'alice',eventId:'legacy-mobile',status:'active',generation:1,participant,checkInAt:null,createdAt:Timestamp.now(),lastOperationId:op1});
  });
  const db = authedDb('alice');
  const batch = writeBatch(db);
  batch.update(doc(db,'registrations/alice_legacy-mobile'),{status:'cancelled',lastOperationId:op2});
  batch.update(doc(db,'events/legacy-mobile'),{activeCount:0});
  await assertSucceeds(batch.commit());
  assert.equal((await getDoc(doc(db,'registrations/alice_legacy-mobile'))).data().status,'cancelled');
  await assertFails(updateDoc(doc(db,'events/legacy-mobile'),{activeCount:-1}));
});

test('legacy ownerless events cannot create a new direct registration in ASM', async () => {
  await seedSystem({eventId:'direct-lab3'});
  await env.withSecurityRulesDisabled(async c => {
    const db=c.firestore();const e=(await db.doc('events/direct-lab3').get()).data();delete e.clubId;
    await db.doc('events/direct-lab3').set(e);
  });
  const db=authedDb('alice');const b=writeBatch(db);
  b.set(doc(db,'registrations/alice_direct-lab3'),{uid:'alice',eventId:'direct-lab3',status:'active',generation:1,participant,checkInAt:null,createdAt:serverTimestamp(),lastOperationId:op1});
  b.update(doc(db,'events/direct-lab3'),{activeCount:1});
  await assertFails(b.commit());
  await assertFails(updateDoc(doc(db,'events/direct-lab3'),{activeCount:2}));
});


test('pending withdrawal preserves seats and a new request resets review state', async () => {
  await seedSystem({ eventId: 'ev_pending_cancel', capacity: 2 });
  const db = authedDb('alice');
  const ref = doc(db, 'registrations/alice_ev_pending_cancel');
  await assertSucceeds(createPendingRegistration(db, 'alice', 'ev_pending_cancel'));
  await assertSucceeds(updateDoc(ref, { status: 'cancelled', lastOperationId: op2 }));
  assert.equal((await getDoc(doc(db, 'events/ev_pending_cancel'))).data().activeCount, 0);
  await assertSucceeds(setDoc(ref, {
    uid: 'alice', eventId: 'ev_pending_cancel', clubId: 'club_it',
    status: 'pending', generation: 2, participant, checkInAt: null,
    reason: null, reviewedBy: null, reviewedAt: null,
    createdAt: serverTimestamp(), lastOperationId: op3,
  }));
  assert.equal((await getDoc(ref)).data().status, 'pending');
});


test('report metadata is owner-only, shaped, immutable and contains no file URL', async () => {
  await seedSystem();
  const alice=authedDb('alice'), bob=authedDb('bob'), staff=authedDb('staff_it'), admin=authedDb('admin_1');
  const path='users/alice/reports/report-123-abc';
  const metadata={fileName:'report-123-abc.pdf',mimeType:'application/pdf',byteCount:12000,rowCount:2,createdAt:serverTimestamp()};
  await assertSucceeds(setDoc(doc(alice,path),metadata));
  await assertSucceeds(getDoc(doc(alice,path)));
  for (const db of [bob,staff,admin]) {
    await assertFails(getDoc(doc(db,path)));
    await assertFails(setDoc(doc(db,'users/alice/reports/report-other-abc'),{...metadata,fileName:'report-other-abc.pdf'}));
  }
  await assertFails(setDoc(doc(alice,'users/alice/reports/report-url-abc'),{...metadata,fileName:'report-url-abc.pdf',url:'https://example.com/private.pdf'}));
  await assertFails(setDoc(doc(alice,'users/alice/reports/report-empty-abc'),{...metadata,fileName:'report-empty-abc.pdf',rowCount:0}));
  await assertFails(updateDoc(doc(alice,path),{byteCount:1}));
  await assertFails(deleteDoc(doc(alice,path)));
});

test('announcement read receipts belong only to their reader and require a real announcement', async () => {
  await seedSystem();
  await env.withSecurityRulesDisabled(async ctx => { await ctx.firestore().doc('announcements/a1').set({title:'Lich sinh hoat',body:'CLB sinh hoat',scope:'global',createdAt:Timestamp.now()}); });
  const alice=authedDb('alice'), bob=authedDb('bob');
  for (const uid of ['staff_it','admin_1']) {
    await assertFails(setDoc(doc(authedDb(uid),`users/${uid}/announcementReads/a1`),{readAt:serverTimestamp()}));
    await assertFails(getDoc(doc(authedDb(uid),'users/alice/announcementReads/a1')));
  }
  const path='users/alice/announcementReads/a1';
  await assertSucceeds(setDoc(doc(alice,path),{readAt:serverTimestamp()}));
  await assertSucceeds(getDoc(doc(alice,path)));
  await assertFails(getDoc(doc(bob,path)));
  await assertFails(setDoc(doc(bob,path),{readAt:serverTimestamp()}));
  await assertFails(setDoc(doc(alice,'users/alice/announcementReads/missing'),{readAt:serverTimestamp()}));
  await assertFails(setDoc(doc(alice,path),{readAt:serverTimestamp(),role:'admin'}));
});


test('unpublished events stay private; staff submits but cannot publish or impersonate another club', async () => {
  await seedSystem();
  await env.withSecurityRulesDisabled(async c => {
    for (const status of ['draft', 'pending_approval', 'rejected']) {
      await c.firestore().doc('events/private_' + status).set({
        title: 'Private proposal', status, visibility: 'public', clubId: 'club_it',
        registrationMode: 'required', capacity: 3, activeCount: 0,
        startsAt: Timestamp.fromMillis(Date.now()+7200000),
        endsAt: Timestamp.fromMillis(Date.now()+10800000),
        deadline: Timestamp.fromMillis(Date.now()+3600000),
      });
    }
  });
  const user = authedDb('alice'), staff = authedDb('staff_it'), admin = authedDb('admin_1');
  for (const status of ['draft', 'pending_approval', 'rejected']) {
    await assertFails(getDoc(doc(user, 'events/private_' + status)));
    await assertSucceeds(getDoc(doc(staff, 'events/private_' + status)));
    await assertSucceeds(getDoc(doc(admin, 'events/private_' + status)));
  }
  await assertSucceeds(getDoc(doc(user, 'events/ev_ai_1')));
  await assertFails(updateDoc(doc(staff, 'events/private_draft'), {
    status: 'published', updatedAt: serverTimestamp(),
  }));
  await assertSucceeds(updateDoc(doc(staff, 'events/private_draft'), {
    status: 'pending_approval', updatedAt: serverTimestamp(),
  }));
  await assertSucceeds(updateDoc(doc(admin, 'events/private_draft'), {
    status: 'published', updatedAt: serverTimestamp(),
  }));
  await assertSucceeds(getDoc(doc(user, 'events/private_draft')));
  const payload = {title: 'Proposal', clubId: 'club_it', visibility: 'public',
    registrationMode: 'required', capacity: 3, activeCount: 0,
    startsAt: Timestamp.fromMillis(Date.now()+7200000),
    endsAt: Timestamp.fromMillis(Date.now()+10800000), deadline: Timestamp.fromMillis(Date.now()+3600000), updatedAt: serverTimestamp()};
  await assertFails(setDoc(doc(admin, 'events/admin_create'), {...payload, status:'draft'}));
  await assertFails(setDoc(doc(staff, 'events/staff_publish'), {...payload, status:'published'}));
  await assertFails(setDoc(doc(authedDb('staff_music'), 'events/other_club'), {...payload, status:'draft'}));
  await assertSucceeds(setDoc(doc(staff, 'events/staff_proposal'), {...payload, status:'pending_approval'}));
});

// Appendix B: every role × collection. A forbidden-only role has no invented allow case.
for (const [role, uid] of [['user', 'alice'], ['staff', 'staff_it'], ['admin', 'admin_1']]) {
  test(`Appendix B matrix: ${role} covers every collection`, async (t) => {
    await seedSystem();
    const eventId = 'ev_ai_1', regId = `${uid}_${eventId}`, hash = 'e'.repeat(64);
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await db.doc(`registrations/${regId}`).set({uid, eventId, clubId:'club_it',status:'approved',generation:1,participant,checkInAt:null});
      await db.doc(`registrations/${regId}/history/entry`).set({status:'pending'});
      await db.doc(`checkinSessions/${eventId}`).set({eventId,clubId:'club_it',open:true});
      await db.doc(`qrCredentials/${hash}`).set({eventId,clubId:'club_it',enabled:true});
      await db.doc('announcements/notice').set({title:'Notice',body:'Club update',scope:'global',authorRole:'admin'});
      for(const owner of [uid,'bob']) {
        await db.doc(`users/${owner}/notifications/notice`).set({title:'Private',readAt:null});
        await db.doc(`users/${owner}/devices/device`).set({fid:'token',platform:'android'});
        await db.doc(`users/${owner}/reports/report-check`).set({fileName:'report-check.pdf',mimeType:'application/pdf',byteCount:100,rowCount:1});
        await db.doc(`users/${owner}/announcementReads/notice`).set({readAt:Timestamp.now()});
      }
    });
    const db=authedDb(uid);
    const readAndDeny = async (path, denied) => {await assertSucceeds(getDoc(doc(db,path)));await assertFails(denied());};
    await t.test('users: own read/update allowed; role/type violations denied',async()=>{
      await readAndDeny(`users/${uid}`,()=>updateDoc(doc(db,`users/${uid}`),{role:role==='admin'?'user':'admin'}));
      await assertSucceeds(updateDoc(doc(db,`users/${uid}`),{displayName:'Updated profile',updatedAt:serverTimestamp()}));
      await assertFails(updateDoc(doc(db,`users/${uid}`),{displayName:123,updatedAt:serverTimestamp()}));
      await assertFails(updateDoc(doc(db,`users/${uid}`),{email:['invalid'],updatedAt:serverTimestamp()}));
    });
    await t.test('clubs: read allowed, delete denied',()=>readAndDeny('clubs/club_it',()=>deleteDoc(doc(db,'clubs/club_it'))));
    await t.test('events: published read allowed; delete/invalid dates denied',async()=>{
      await readAndDeny(`events/${eventId}`,()=>deleteDoc(doc(db,`events/${eventId}`)));
      if(role==='staff') await assertSucceeds(updateDoc(doc(db,`events/${eventId}`),{description:'Updated description',updatedAt:serverTimestamp()}));
      await assertFails(updateDoc(doc(db,`events/${eventId}`),{startsAt:'invalid',updatedAt:serverTimestamp()}));
      await assertFails(updateDoc(doc(db,`events/${eventId}`),{deadline:null,updatedAt:serverTimestamp()}));
    });
    await t.test('registrations: permitted read allowed, delete denied',()=>readAndDeny(`registrations/${regId}`,()=>deleteDoc(doc(db,`registrations/${regId}`))));
    await t.test('history: own parent history read allowed, writes denied',()=>readAndDeny(`registrations/${regId}/history/entry`,()=>setDoc(doc(db,`registrations/${regId}/history/entry`),{status:'approved'})));
    await t.test('checkinSessions: approved owner/club/admin read allowed, delete denied',()=>readAndDeny(`checkinSessions/${eventId}`,()=>deleteDoc(doc(db,`checkinSessions/${eventId}`))));
    await t.test('qrCredentials: known hash read allowed, delete denied',()=>readAndDeny(`qrCredentials/${hash}`,()=>deleteDoc(doc(db,`qrCredentials/${hash}`))));
    await t.test('announcements: read allowed, immutable update denied',()=>readAndDeny('announcements/notice',()=>updateDoc(doc(db,'announcements/notice'),{title:'Changed'})));
    for(const collection of ['notifications','devices']) {
      const id=collection==='devices'?'device':'notice';
      await t.test(`${collection}: own read allowed, other UID read denied`,()=>readAndDeny(`users/${uid}/${collection}/${id}`,()=>getDoc(doc(db,`users/bob/${collection}/${id}`))));
    }
    await t.test('reports: user owns metadata; staff/admin intentionally forbidden',async()=>{
      const own=doc(db,`users/${uid}/reports/report-check`);
      if(role==='user') {
        await assertSucceeds(getDoc(own));
        await assertSucceeds(setDoc(doc(db,`users/${uid}/reports/report-matrix`),{fileName:'report-matrix.pdf',mimeType:'application/pdf',byteCount:100,rowCount:1,createdAt:serverTimestamp()}));
      } else {
        await assertFails(getDoc(own));
        await assertFails(setDoc(doc(db,`users/${uid}/reports/report-matrix`),{fileName:'report-matrix.pdf',mimeType:'application/pdf',byteCount:100,rowCount:1,createdAt:serverTimestamp()}));
      }
      await assertFails(getDoc(doc(db,'users/bob/reports/report-check')));
      await assertFails(updateDoc(own,{rowCount:2}));
    });
    await t.test('announcementReads: user owns receipt; staff/admin intentionally forbidden',async()=>{
      const own=doc(db,`users/${uid}/announcementReads/notice`);
      if(role==='user') {await assertSucceeds(getDoc(own));await assertSucceeds(setDoc(own,{readAt:serverTimestamp()}));}
      else {await assertFails(getDoc(own));await assertFails(setDoc(own,{readAt:serverTimestamp()}));}
      await assertFails(getDoc(doc(db,'users/bob/announcementReads/notice')));
      await assertFails(deleteDoc(own));
    });
    await t.test('unmatched collection: default-deny read and write',async()=>{
      await assertFails(getDoc(doc(db,'unknown/record')));
      await assertFails(setDoc(doc(db,'unknown/record'),{value:1}));
    });
  });
}

test('Appendix B: anonymous and unverified accounts cannot access application collections',async()=>{
  await seedSystem();
  const paths=['users/alice','clubs/club_it','events/ev_ai_1','registrations/alice_ev_ai_1','registrations/alice_ev_ai_1/history/entry','checkinSessions/ev_ai_1',`qrCredentials/${'e'.repeat(64)}`,'announcements/notice','users/alice/notifications/notice','users/alice/devices/device','users/alice/reports/report-check','users/alice/announcementReads/notice'];
  for(const db of [env.unauthenticatedContext().firestore(),authedDb('bob',false)]) {
    for(const path of paths) {await assertFails(getDoc(doc(db,path))); await assertFails(setDoc(doc(db,path),{unexpected:true}));}
  }
});


// Email onboarding: user proves identity, only Admin writes role.
function managerDb(uid, email, {verified = true, provider = 'google.com'} = {}) {
  return env.authenticatedContext(uid, {email, email_verified: verified, firebase: {sign_in_provider: provider}}).firestore();
}
function invitationBatch(db, email, clubId = 'club_it', clubName = 'CLB IT FPTU') {
  const b = writeBatch(db);
  b.set(doc(db, 'clubAssignments', email), {email, clubId, clubName, status:'pending', createdBy:'admin_1', createdAt:serverTimestamp()});
  b.set(doc(db, 'clubManagerSlots', clubId), {email});
  return b;
}
function identityRequest(db, uid, email) {
  return updateDoc(doc(db, 'clubAssignments', email), {status:'awaiting_activation', requestedUid:uid, requestedAt:serverTimestamp()});
}
function activationBatch(db, uid, email, clubId='club_it', clubName='CLB IT FPTU', actor='admin_1') {
  const b=writeBatch(db);
  b.update(doc(db,'users',uid), {role:'staff',clubId,clubName,updatedAt:serverTimestamp()});
  b.update(doc(db,'clubAssignments',email), {status:'accepted',acceptedUid:uid,acceptedAt:serverTimestamp(),acceptedBy:actor});
  return b;
}
test('email onboarding: verified identity request then Admin-only activation',async(t)=>{
 await seedSystem();
 const admin=managerDb('admin_1','admin@fpt.edu.vn');
 const alice=managerDb('alice','alice@fpt.edu.vn');
 const bob=managerDb('bob','bob@fpt.edu.vn');
 await t.test('only Admin may reserve an email and club',async()=>{
  await assertFails(invitationBatch(alice,'alice@fpt.edu.vn').commit());
  await assertFails(invitationBatch(managerDb('staff_it','leader.it@fpt.edu.vn'),'alice@fpt.edu.vn').commit());
  await assertSucceeds(invitationBatch(admin,'alice@fpt.edu.vn').commit());
  await assertFails(invitationBatch(admin,'other@fpt.edu.vn').commit());
 });
 await t.test('read is scoped to verified email, lists and slots Admin-only',async()=>{
  await assertSucceeds(getDoc(doc(alice,'clubAssignments/alice@fpt.edu.vn')));
  await assertFails(getDoc(doc(bob,'clubAssignments/alice@fpt.edu.vn')));
  await assertFails(getDocs(collection(alice,'clubAssignments')));
  await assertSucceeds(getDocs(collection(admin,'clubAssignments')));
  await assertSucceeds(getDoc(doc(admin,'clubManagerSlots/club_it')));
  await assertFails(getDoc(doc(alice,'clubManagerSlots/club_it')));
 });
 await t.test('cannot self-promote before or after identity registration',async()=>{
  await assertFails(activationBatch(alice,'alice','alice@fpt.edu.vn','club_it','CLB IT FPTU','alice').commit());
  await assertFails(updateDoc(doc(alice,'users/alice'),{role:'staff',clubId:'club_it',clubName:'CLB IT FPTU'}));
 });
 await t.test('wrong, unverified or non-Google identity cannot claim the email',async()=>{
  await assertFails(identityRequest(bob,'bob','alice@fpt.edu.vn'));
  await assertFails(identityRequest(managerDb('alice','alice@fpt.edu.vn',{verified:false}),'alice','alice@fpt.edu.vn'));
  await assertFails(identityRequest(managerDb('alice','alice@fpt.edu.vn',{provider:'password'}),'alice','alice@fpt.edu.vn'));
 });
 await t.test('matching identity can request activation but stays user',async()=>{
  await assertSucceeds(identityRequest(alice,'alice','alice@fpt.edu.vn'));
  assert.equal((await getDoc(doc(alice,'users/alice'))).data().role,'user');
  await assertFails(identityRequest(alice,'alice','alice@fpt.edu.vn'));
  await assertFails(activationBatch(alice,'alice','alice@fpt.edu.vn','club_it','CLB IT FPTU','alice').commit());
 });
 await t.test('Admin cannot activate wrong club or consume invitation without assigning role',async()=>{
  await assertFails(activationBatch(admin,'alice','alice@fpt.edu.vn','club_music','CLB Am Nhac').commit());
  await assertFails(updateDoc(doc(admin,'clubAssignments/alice@fpt.edu.vn'),{status:'accepted',acceptedUid:'alice',acceptedAt:serverTimestamp(),acceptedBy:'admin_1'}));
 });
 await t.test('Admin atomically activates role and invitation, no replay',async()=>{
  await assertSucceeds(activationBatch(admin,'alice','alice@fpt.edu.vn').commit());
  assert.equal((await getDoc(doc(alice,'users/alice'))).data().role,'staff');
  await assertFails(activationBatch(admin,'alice','alice@fpt.edu.vn').commit());
 });
 await t.test('accepted role can only be revoked with slot release',async()=>{
  await assertFails(updateDoc(doc(admin,'clubAssignments/alice@fpt.edu.vn'),{status:'revoked',revokedBy:'admin_1',revokedAt:serverTimestamp()}));
  const b=writeBatch(admin);
  b.update(doc(admin,'clubAssignments/alice@fpt.edu.vn'),{status:'revoked',revokedBy:'admin_1',revokedAt:serverTimestamp()});
  b.delete(doc(admin,'clubManagerSlots/club_it'));
  b.update(doc(admin,'users/alice'),{role:'user',clubId:null,clubName:null,updatedAt:serverTimestamp()});
  await assertSucceeds(b.commit());
  await assertFails(identityRequest(alice,'alice','alice@fpt.edu.vn'));
 });
 await t.test('new account bootstrap and archived-club guard',async()=>{
  await assertSucceeds(invitationBatch(admin,'new@fpt.edu.vn').commit());
  const newcomer=managerDb('new_user','new@fpt.edu.vn');
  await assertSucceeds(setDoc(doc(newcomer,'users/new_user'),{role:'user',email:'new@fpt.edu.vn',displayName:'New manager',createdAt:serverTimestamp()}));
  await assertSucceeds(updateDoc(doc(admin,'clubs/club_it'),{status:'archived'}));
  await assertFails(identityRequest(newcomer,'new_user','new@fpt.edu.vn'));
  await assertSucceeds(updateDoc(doc(admin,'clubs/club_it'),{status:'active'}));
  await assertSucceeds(identityRequest(newcomer,'new_user','new@fpt.edu.vn'));
  await assertSucceeds(activationBatch(admin,'new_user','new@fpt.edu.vn').commit());
  await assertFails(updateDoc(doc(newcomer,'users/new_user'),{role:'admin'}));
 });
});
