# Codex AI review — instrumentation/lifecycle PR

Reviewer: Codex assistant (GPT-6.1), 07/11/2026. Scope: scanner lifecycle, cloud ViewModel async ownership, push permission/registration. This is AI-generated review output; not CodeRabbit/Copilot output. Source reviewed at fb2d2ee, file locations below refer to that revision. PR link and fix hashes will be added after creation. No findings intentionally introduced.

| ID | Category / location | Finding / decision |
|---|---|---|
| PR01 | Bug: lib/screens/events/scanner_screen.dart, didChangeAppLifecycleState | Camera is stopped on background but never restarted on resumed. Accept: restore only when active registration and no pending command; section 3 flow recovery. |
| PR02 | Bug: lib/screens/events/scanner_screen.dart, initState async after restore | ref is accessed after await restore without checking mounted. Disposing during restore can access dead widget ref. Accept: mounted guard before further provider access; section 5 state reliability. |
| PR03 | Privacy/concurrency: lib/viewmodels/cloud_tools_viewmodel.dart, refresh | Epoch protects UI but analytics log after await still uses current provider/session, potentially attributing previous account action to new user. Accept: gate tracking by UID+epoch before emitting; section 6 analytics correctness. |
| PR04 | Concurrency: lib/viewmodels/cloud_tools_viewmodel.dart, nonFatal | Manual report completion only checks mounted, so a previous session result can overwrite new user's cloud tools state. Accept: capture UID+epoch and gate both outcomes; section 6 failure feedback. |
| PR05 | Reliability: lib/services/firebase/firebase_cloud_services.dart, enablePush | onRegistered.first timeout starts before register. If register throws, its unobserved future may later throw a second asynchronous timeout. Accept: attach error observer immediately while preserving awaited failure; section 6 failure handling. |

Validation plan: analyzer, meaningful session-swap ViewModel regression, scanner widget/static review, existing Flutter suite. Native lifecycle and push runtime checks remain separate evidence; unit tests do not prove console delivery.
