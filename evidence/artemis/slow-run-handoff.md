# Slow ARTEMIS continuation

07/11/2026. Runtime http://127.0.0.1:8001, active TC03 session 0abaf711-304e-48f5-8ce5-9aa13364e20a. At handoff: running, one real input_text step; no HTTP429/413 in this session yet. This is not a pass result.

Local runtime env: ARTEMIS_GROQ_HTTP_INTERVAL_SECONDS=90, ARTEMIS_MIN_MODEL_INTERVAL_SECONDS=0, ARTEMIS_MODEL_MAX_TOKENS=1024. Global httpx request hook gates auxiliary model calls and retries, not just Flash turns. Test timeout default1800 seconds. Current exec pytest session49865, runtime session46932; check actual processes/API after restart before starting duplicates.

Previous slow session205b44be-1860-4a3c-8d54-f28e7f2b6105 cancelled when server restarted; client may report NetworkError. Do not count as passed. Full trace remains in local D:/Ky8/artemis/traces. Artifacts redact dedicated account email.

Analytics debug and FA/FA-SVC verbose enabled on emulator-5554 for live capture; restore debug.firebase.analytics.app=.none. when testing ends. Console screenshot work blocked by kernel-assets initialization error in node_repl and cua_repl. User chose restart Codex; retry browser tools after restart. No Console screenshots created in this attempt.
