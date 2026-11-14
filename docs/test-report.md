## Kết quả mới nhất — 13/11/2026

Web40/40, core6/6 và Rules55/55 đạt; web/core analyze sạch; web production build thành công. Rules JUnit có52case lá+3role suites,0failure/skip. Force-refresh RC cho AI đã được kiểm tra: đổi kill-switch được lấy lại khi người dùng yêu cầu; lỗi fetch không tiếp tục dùng cấu hình cũ. Rules bổ sung kiểm tra kiểu displayName/email và timestamp hồ sơ, ngày/giờ/deadline sự kiện. Cloud/native/AI-output/cross-role vẫn cần chạy thật, không suy pass từ các kết quả này.

## Appendix B và cloud readiness — 13/11/2026

Rules emulator:55 tests đạt,0fail,0skipped, gồm16 top-level groups và39 role/collection subtests. JUnit thật: evidence/rules/final-matrix.xml; ma trận docs/security-rules-matrix.md. Project test demo-direct-booking, không ghi production data.

Cloud đọc thật: evidence/cloud-readiness/config-status.json. Hosting HTTP200; Web Enterprise và Android Play Integrity registered; AI Logic ENFORCED; Firestore UNENFORCED, Android debug tokens0 và chưa có verified requests trong cửa sổ quan sát. Không coi config/HTTP200 là AI hoặc cross-role pass. Các mục native/cloud cần người dùng chạy theo docs/final-live-verification.md.

## Sửa AI theo mục 8 — 13/11/2026

Web analyze sạch; 39/39 tests đạt (10 service/model/lifecycle AI +1 UI preview/cancel/apply và các regression hiện hữu). Core analyze sạch và 6/6 tests đạt. Web build với Firebase config local thành công. Không gọi Gemini thật trong test, không phát sinh bằng chứng cloud giả. Chưa xác nhận AI Logic/App Check Console, 3 input/output thật, 1 failure thực và Analytics Console. Chi tiết: docs/ai-feature.md, docs/code-review.md.

## Sửa lỗi Final — 13/11/2026

Analyze mobile/web sạch. Mobile 86/86 tests, web 28/28, core 6/6, Firestore emulator 12/12 nhóm đạt. Rules/indexes đã triển khai lên eventhub-group4.

Đã sửa phân quyền tạo/gửi/duyệt sự kiện, giữ ảnh bìa, Remote Config dashboard, chọn đăng ký mới nhất và vùng bấm tab lịch. Đây là kết quả tự động, chưa thay thế chạy cloud liên ứng dụng. AI và ARTEMIS vẫn để sau theo yêu cầu. Slides nhóm không sửa.

# Test report — Final

Kết quả được phân biệt local / cloud / kế thừa. Không coi test count, ảnh dự kiến hay trạng thái AI tự báo là pass toàn hệ thống.

## Kiểm tra sau pull e5b15a4 — 13/11/2026

Main đã fast-forward từ a96d0b3 lên e5b15a4 (5 commits của Phạm Gia Huy); phần sửa local giữ nguyên, không xung đột.

- Analyze mobile/web: sạch. Mobile 84/84; core 3/3; Rules 11/11 nhóm đạt trên emulator 127.0.0.1:8085 (demo-direct-booking). Không deploy Rules mới lên cloud trong lượt này.
- Web regression: **22 đạt, 1 fail** (admin_features_test.dart:433 còn kỳ vọng Admin không có nút tạo, trong khi UI mới đã thêm). Kết quả 23/23 bên dưới thuộc lần trước pull, không phải trạng thái hiện tại.
- Review code mới phát hiện: Admin create form vẫn readOnly theo isAdmin; staff draft publish gọi approveEvent bị chặn admin-only; gộp lịch ưu tiên status thay vì generation/thời điểm nên có thể chọn bản cũ; lịch tab mới vùng bấm chỉ khoảng36dp dưới48dp.
- Chưa sửa các finding này trong lượt pull/review. Test hiện có chưa bao phủ đủ các tình huống trên; pass unit không đồng nghĩa không có lỗi.
- Hồ sơ ARTEMIS mới có summary 25 ca ×3 lượt **đều skipped**, thêm client_error NetworkError; không tính Final pass. Đọc nguyên nhân skip trong run XML, không quy hết cho quota.

## Kết quả local đã ghi nhận

| Kiểm tra | Kết quả được lưu | Giới hạn |
|---|---|---|
| Mobile flutter test --no-pub | 84/84 đạt | Gồm missing-event export, role gate, announcements scope, local file/metadata retry; không xác nhận thao tác Android/cloud |
| Mobile analyze | Không có lỗi | Source lib/test |
| Core tests | 3/3 ở đợt hoàn thiện mobile | Cần chạy lại khi đổi shared package |
| Web tests | 23/23 chạy lại sau dọn repo | Fake chỉ nằm trong test/, không HTTP bridge; analyze lib/test sạch |
| Rules emulator | 11/11 nhóm test ở đợt hoàn thiện mobile | Nhiều assertions trong mỗi nhóm; không tự suy ra đủ matrix role × collection |
| APK build | Thành công ở đợt hoàn thiện mobile | Không xác nhận thao tác native/cloud |
| Web production build main.dart | Chạy lại sau dọn repo: thành công (114.7s) | Không deploy Hosting, không xác nhận URL/App Check/cloud |

Nguồn: [mobile validation](../evidence/mobile-final/validation.md). Rules đã deploy eventhub-group4 trong đợt hoàn thiện mobile; local tests dùng emulator demo-direct-booking, không phải production data.

## Rules theo Appendix B

Source: firebase/tests/direct-firestore.test.js. Nhóm test gồm users/clubs; events; pending approval + notifications; QR/session; announcements/device receipts; archived-event read; legacy cancel và chặn direct-create; pending withdrawal; private report metadata; announcement read receipts.

Trước nộp cần đối chiếu **allowed/denied mỗi role mỗi collection**, all pass; với thao tác không role nào được phép phải ghi policy cấm và ca deny tương ứng, không bịa ca allowed. Chưa chốt matrix đầy đủ chỉ từ tổng 11 nhóm.

## Web checklist — chưa có đủ ảnh Final

| Màn | Action / state phải chứng minh | Trạng thái |
|---|---|---|
| Sign-in | Google staff/admin; reject user; lỗi/cancel | Chờ cloud proof |
| Management | List/search/create/edit/archive; loading/empty/error | Chờ cloud proof |
| Review | Approve/reject reason đúng club; lỗi/empty/loading | Chờ cloud proof |
| Dashboard | ≥3 aggregation figures, 1 chart; loading/empty/error | Chờ cloud proof |
| Announcement form | Ghi Firestore và mobile inbox đúng scope | Chờ cloud proof |

Danh mục cần chụp ở evidence/web-admin/README.md không phải ảnh đã tồn tại. URL phải mở được trong cửa sổ ẩn danh ở thời điểm nộp.

## Cross-role và mobile cloud

- Chưa có kết quả 3 lượt deployment/latency; bảng ở [cross-role flow](cross-role-flow.md) còn chờ đo.
- App Check Android/web, native PDF share, role rejection bằng tài khoản thật và announcements realtime: chưa đủ xác nhận Final.
- [Instrumentation cũ](../evidence/instrumentation/status.md) là bằng chứng Lab 3; chạy lại phần thay đổi cho Final, nhất là export_share và pending/approved. Không lấy export_upload cũ để chứng minh local share.

## ARTEMIS

Kịch bản đã sửa một số kỳ vọng cho Final; chưa chạy lại suite Final. Cross-role và AI còn phải bổ sung coverage sau khi fixtures/tính năng sẵn sàng. Mọi flow Lab 2, phần mobile cross-role và AI cần 3 lượt, pass rate, trace; skipped/failed không tính đạt. Hồ sơ cũ tại evidence/artemis được giữ nhưng không công nhận Final pass.

## AI code review mới

Finding/decision FM-01..FM-06 tại [code review](code-review.md): role fail-closed; service/core reuse; thay cloud upload bằng local/share; metadata idempotency; chặn direct active; export không thiếu dòng âm thầm. Có local test cho các fix; commit/final review evidence cần đối chiếu trước nộp. Finding cũ CR/L của Lab 3 chỉ là nền kế thừa.

## Chưa hoàn tất

AI feature và bằng chứng; ARTEMIS; App Check/cloud/native proof; web screenshots; cross-role 3 runs; danh tính Admin/demo accounts; URL/video; report PDF 10–15 trang, slides PDF 12–15, video live 8–12 phút. Slide nhóm giữ nguyên và rà riêng; chưa dùng số liệu trên slide để đánh dấu pass.

## Audit toàn hệ thống sau main e5b15a4

- Cấu trúc có đủ thư mục chính theo Final; không cần refactor lần nữa chỉ để đổi tên.
- Bổ sung findings S01/W02/W04/W05 bên cạnh4 finding lượt trước: Rules public draft đọc được (reproduced emulator demo-final-audit, user verified get draft=true, đã clear namespace test); Admin tự chọn CLB đầu; form sửa mất coverKey; RC web fetch nhưng chưa dùng giá trị ở ViewModel/UI.
- web/web_env.json thiếu local; chưa thể khẳng định chạy web Firebase thật theo lệnh README. Android config local có; App Check Console chưa xác nhận.
- Không sửa production source hoặc deploy trong audit. Hướng dẫn chuẩn bị, thứ tự chạy thật và danh sách lỗi tại docs/one-pass-test.md. Không chạy lại unit suite vì không đổi code kể từ kết quả mới nhất.

## Phân công CLB bằng email — 14/11/2026

- Web: toàn bộ 45 tests đạt (gồm nhập email/chọn CLB, giữ input khi lỗi, empty, ViewModel và các regression Admin/Auth/AI).
- Core: 6 tests đạt.
- Rules: `evidence/rules/club-onboarding.xml` có 61 leaf test cases, 0 failure/error/skip (Node báo 65 tính cả 4 nhóm cha). Chạy với project local `demo-direct-booking`, không sửa dữ liệu production.
- Onboarding kiểm tra Admin-only, giữ chỗ CLB, email từ Auth token đã xác minh, Google-only, chống ghi nửa transaction/nâng quyền/sai CLB/replay, thu hồi pending/accepted, cấp lại, CLB archived và tài khoản hoàn toàn mới.
- Chưa build/deploy web cho thay đổi này; chưa có bằng chứng đăng nhập onboarding trên Hosting thật. Xem `docs/club-onboarding.md` để chạy xác nhận hai tài khoản.
