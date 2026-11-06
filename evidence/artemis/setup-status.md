# ARTEMIS setup — 2026-11-06

- Installed upstream runtime at D:/Ky8/artemis, commit 351ca8422f7b5b54e80a9c1ce03a222e02415b6b, and pinned pytest client environment.
- Groq credentials validated via models endpoint HTTP 200 (secret not recorded).
- Vision probe with synthetic red image returned Red using qwen/qwen3.8-27b.
- Runtime configured locally through OpenAI-compatible endpoint; no secrets in this repository.
- pytest collection: 25 cases collected, not executed.
- Attempted Flash standalone setup-smoke on emulator-5554, session e290ba38-f9ab-46f1-8fec-352c9373cd1f.
- Blocked: emulator system ANR, app foreground detection timeout. adb dumpsys window showed Application Not Responding: system. No passing E2E claim.

Pending: healthy emulator and dedicated Google test account; then SDK daemon, regression 3 runs per case and Pro exploration with actual traces. Smoke attempt is not part of the required pass-rate results.
