# Repository cleanup validation — 2026-11-05

Executed locally against the Lab 3 working tree:

- `flutter test`: 57 passed after removing prototype tests.
- `flutter analyze`: no issues after the Cloudinary constructor cleanup.
- `flutter test test/cloudinary_report_storage_test.dart`: 2 passed after constructor cleanup.
- `flutter build apk --debug -t lib/main.dart`: succeeded; APK at `build/app/outputs/flutter-apk/app-debug.apk`. Toolchain emits KGP and Android SDK XML compatibility warnings; build is not blocked.
- Firestore emulator: `node --test firebase/tests/direct-firestore.test.js`, 4 passed, 0 failed, demo project only. Expected permission-denied output is asserted by negative tests.
- `npm install --ignore-scripts` in `firebase/tests`: audit reports 0 vulnerabilities with grpc-js override 1.14.7.

Removed offline prototype, placeholder screen/tests and unused Functions backend. Kept Rules tests under `firebase/tests`, with pinned dependencies. Test doubles remain in tests only; production `lib` has no prototype/mock target.

## Not proven by these checks

These are local unit/widget/Rules/build results, not Android end-to-end or cloud acceptance results. Still open: FCM received-message persistence, real FCM delivery in three states, private per-account Cloudinary access, cloud dashboard evidence, ARTEMIS runs, final Figma comparison, AI PR review evidence and submission artifacts. Existing Firestore sample records are fixtures, not real-world club announcements.
