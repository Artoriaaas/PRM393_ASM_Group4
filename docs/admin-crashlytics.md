# Admin Crashlytics reports

Supplementary lecturer instruction: demonstrate an intentional mobile crash and let Admin view processed Crashlytics results inside the web client.

## Implementation

- Mobile: Account → Firebase utilities → Thử crash ứng dụng. Confirmation is required; the button is available in the release demonstration APK as well as debug. Reopen the app after the crash so the SDK can send its report.
- Web: Admin dashboard → Báo cáo lỗi ứng dụng (`/crash-reports`). Staff and participants are rejected by the screen and ViewModel.
- MVVM: `CrashReportsScreen` → `CrashReportsViewModel` → `CrashReportsService`.
- Official Firebase Crashlytics REST API `v1alpha` events.list with a restricted readMask; 25 events per page with explicit pagination. Displays recorded timestamp, issue title/subtitle/type, version and device. No mirrored client claims, mock reports, Cloud Functions, private keys or custom server.
- This alpha API may change. Google IAM authorization, not the Firestore role alone, protects the Crashlytics API. The service only performs GET requests.
- The administrator explicitly reauthenticates the same Google identity with Firebase OAuth scope. Its access token stays in memory and is discarded when leaving the screen. No tokens or raw error responses are logged or stored. End-user IDs, logs and stack traces are not requested by this screen.

## Required project setup and live confirmation

1. Project owner enables `firebasecrashlytics.googleapis.com` if not already enabled.
2. Grant the intended Google Admin account `roles/firebasecrashlytics.viewer` (Firebase Crashlytics Viewer) in Google Cloud IAM. Do not grant project Owner or Editor just for this feature. App `users/{uid}.role=admin` does not grant Google IAM permissions.
3. Google OAuth consent must allow the Firebase scope for that account. If the app is in Testing, include the demo Admin as a test user. Do not publish consent or change IAM automatically.
4. Open deployed web as Admin → connect Google → verify real results. The browser/API CORS path, consent and IAM must be verified on the deployment; local parser tests cannot establish these.
5. Trigger one confirmed mobile crash, reopen app, allow processing time, refresh web and correlate the device/time/version. Do not report success until an actual API record appears.
6. Verify a Staff account cannot access the screen. Test loading, empty, expired-token and permission-denied states. Never describe a permission failure as zero crashes.

Source: https://firebase.google.com/docs/reference/crashlytics/rest
Discovery contract: https://firebasecrashlytics.googleapis.com/$discovery/rest?version=v1alpha
