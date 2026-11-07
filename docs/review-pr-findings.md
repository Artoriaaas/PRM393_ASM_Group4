# Codex AI review — instrumentation/lifecycle PR

Reviewer: Codex assistant (GPT-6.1), 07/11/2026. Scope: scanner lifecycle, cloud ViewModel async ownership, push permission/registration. This is AI-generated review output; not CodeRabbit/Copilot output. Source reviewed at fb2d2ee, file locations below refer to that revision. PR link and fix hashes are recorded below. No findings intentionally introduced.

| ID | Category / location | Finding / decision |
|---|---|---|
| PR01 | Bug: lib/screens/events/scanner_screen.dart, didChangeAppLifecycleState | Camera is stopped on background but never restarted on resumed. Accept: restore only when active registration and no pending command; section 3 flow recovery. |
| PR02 | Bug: lib/screens/events/scanner_screen.dart, initState async after restore | ref is accessed after await restore without checking mounted. Disposing during restore can access dead widget ref. Accept: mounted guard before further provider access; section 5 state reliability. |
| PR03 | Privacy/concurrency: lib/viewmodels/cloud_tools_viewmodel.dart, refresh | Epoch protects UI but analytics log after await still uses current provider/session, potentially attributing previous account action to new user. Accept: gate tracking by UID+epoch before emitting; section 6 analytics correctness. |
| PR04 | Concurrency: lib/viewmodels/cloud_tools_viewmodel.dart, nonFatal | Manual report completion only checks mounted, so a previous session result can overwrite new user's cloud tools state. Accept: capture UID+epoch and gate both outcomes; section 6 failure feedback. |
| PR05 | Reliability: lib/services/firebase/firebase_cloud_services.dart, enablePush | onRegistered.first timeout starts before register. If register throws, its unobserved future may later throw a second asynchronous timeout. Accept: attach error observer immediately while preserving awaited failure; section 6 failure handling. |

Validation plan: analyzer, meaningful session-swap ViewModel regression, scanner widget/static review, existing Flutter suite. Native lifecycle and push runtime checks remain separate evidence; unit tests do not prove console delivery.

## PR và fix commits

PR: https://github.com/ThinhCri/PRM393_Lab03_Group4/pull/3 (draft). Đã đọc danh sách file/diff PR qua GitHub API; scope metadata tại evidence/code-review/pr-3-scope.json. Review dùng Codex trong chat trên phạm vi PR; không giả danh review Copilot/CodeRabbit và không có external bot approval.

| Findings | Fix commit | Kiểm tra |
|---|---|---|
| PR01, PR02 | fe02d20 | Scanner resume chỉ khi registration active/chưa check-in/không pending; guard mounted sau restore. Native background/resume còn cần xác nhận |
| PR03, PR04 | 9f92864 | Test delayed config hoàn tất sau đổi UID không phát event/feedback sang user mới đã đạt |
| PR05 | 33fb007 | Error observer gắn trước await register; analyzer kiểm tra kiểu, native token failure vẫn cần test thật |

Cả 5 finding accepted vì ảnh hưởng flow recovery, lỗi async hoặc attribution của Analytics (Lab3 §3/5/6). Ba commit sửa tách biệt chứa ID. Bằng chứng test local không thay thế ảnh FCM/Crashlytics trên Console.

Source reviewed fb2d2ee: `lib/screens/events/scanner_screen.dart:37` — `Future.microtask`.

Source reviewed fb2d2ee: `lib/screens/events/scanner_screen.dart:83` — `void didChangeAppLifecycleState`.

Source reviewed fb2d2ee: `lib/viewmodels/cloud_tools_viewmodel.dart:34` — `Future<void> refresh`.

Source reviewed fb2d2ee: `lib/viewmodels/cloud_tools_viewmodel.dart:81` — `Future<void> nonFatal`.

Source reviewed fb2d2ee: `lib/services/firebase/firebase_cloud_services.dart:135` — `final registration =`.

Taxonomy theo đề: PR01/02/04/05 → Bug; PR03 → Security (cross-account attribution). Các nhãn concurrency/reliability/privacy trước đây mô tả tác động, không thay danh mục của đề. Hai fix commits gộp findings, nên chưa hoàn thành chặt yêu cầu mỗi finding một commit riêng; không dùng số3 commits để che giới hạn đó. Source FCM/camera đã refactor sau audit; các vị trí trước sửa vẫn tham chiếu fb2d2ee.
