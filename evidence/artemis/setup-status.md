# ARTEMIS setup — 2026-11-06

- Installed upstream runtime at D:/Ky8/artemis, commit 351ca8422f7b5b54e80a9c1ce03a222e02415b6b, and pinned pytest client environment.
- Groq credentials validated via models endpoint HTTP 200 (secret not recorded).
- Vision probe with synthetic red image returned Red using qwen/qwen3.8-27b.
- Runtime configured locally through OpenAI-compatible endpoint; no secrets in this repository.
- pytest collection: 25 cases collected, not executed.
- Attempted Flash standalone setup-smoke on emulator-5554, session e290ba38-f9ab-46f1-8fec-352c9373cd1f.
- Blocked: emulator system ANR, app foreground detection timeout. adb dumpsys window showed Application Not Responding: system. No passing E2E claim.

Pending: healthy emulator and dedicated Google test account; then SDK daemon, regression 3 runs per case and Pro exploration with actual traces. Smoke attempt is not part of the required pass-rate results.

## Follow-up

Local SDK server started successfully on loopback port 8001 with Groq model configured. TC01 was submitted but rejected before execution (HTTP 409 device locked/not ready). Android diagnostics show com.android.systemui ANR after cold boot, despite keyguard showing=false/deviceLocked=0. These setup attempts are not passing runs and not application failures. Dedicated account was supplied privately; omitted from evidence. A healthy Android device is required before regression can continue.

## Groq compact retry

Shortened prompt/tool descriptions, kept navigation tools and latest observation with bounded history (local patch disclosed). Fixed SDK Flash result omission by reading the exact session report through the host steps API; missing/wrong structured observations still fail assertions. TC01 explicitly requires logout/login before Discover.

Session fc739a62-16b6-4d88-a089-706a575e548f produced actual tap actions, but repeatedly targeted Google sign-in without completing login. Groq repeatedly returned 429 (~40-second waits). Run stopped rather than counted as passed. Current combination is not validated for the required regression or Pro suite. No app login defect is established by these agent failures.
