# FCM receipt history — 2026-11-06

Added per-user Firestore receipt persistence on foreground/open/initial/background callbacks. Message ID is hashed for deduplication. Existing receipts are preserved (including read state). Mismatched payload UID is rejected. Receipt type is push_received and grants no registration/attendance rights.

Validation: flutter analyze clean; flutter test 57 passed; Firestore emulator 5 passed, including owner-only receipt access and denial of forged server notification types.

Not yet verified: actual FCM delivery and persistence on Android in foreground/background/terminated states. Android notification-only payload may be delivered to the background callback only when opened; test this explicitly before claiming complete history. Cloudinary privacy and ARTEMIS remain open.
