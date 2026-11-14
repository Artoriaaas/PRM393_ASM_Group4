# Đối chiếu đề Final — không thay bằng checklist Lab 3

Nguồn: PDF Final Assignment trong gốc repo, 9 trang. Đây là danh mục kiểm tra, không phải tuyên bố đã hoàn thành. Chủ đề EventHub giữ nguyên.

| Mục đề | Phải có | Nguồn đối chiếu hiện hành / trạng thái |
|---|---|---|
| 3 Mobile | Mọi màn/flow Lab 2 + Lab 3 còn áp dụng, Firestore, đóng findings, announcements inbox | mobile/, docs/design-traceability.md; cần cloud proof |
| 3 Cross-role | Ít nhất một flow qua hai client/vai trò, realtime/inbox | docs/cross-role-flow.md; chưa có 3 lượt deployment |
| 4 Architecture | Một Firestore và shared Dart package, không custom server/Functions/Storage/App Hosting | mobile/, web/, packages/core/, firebase.json; PDF local/share + metadata |
| 6 Model/roles | Fields/types, CRUD roles, screens, status transitions; Admin đầu tiên Console và ghi README; không tự đổi role | docs/data-model.md, README; danh tính Admin/demo chưa xác nhận |
| 6 Rules | Deny default, shape/transitions, allowed/denied từng role/collection | docs/security-rules-matrix.md; 55/55 tests đạt, JUnit đã lưu |
| 6 Instrumentation | App Check Firestore/AI; RC+Analytics cả hai client; Crashlytics mobile | AI enforcement đã bật; Web Enterprise/Android Play Integrity registered; Android debug token/request hợp lệ và Firestore enforcement còn thiếu |
| 7 Web | Google role gate; management list/search/create/edit/archive; review reason; ≥3 aggregation figures +chart; announcement form | web/ đã deploy; cần thao tác/ảnh main actions và states thật |
| 8 AI | Firebase AI Logic Gemini, App Check, RC model/prompt/flag, no PII, label/edit/fallback, 3 events; 3 real input/output +1 failure | docs/ai-feature.md; SDK/preview/validation đã sửa, RC bật thật; còn 3output/1failure/Analytics proof |
| 9 Test | ARTEMIS mỗi flow/cross-role/AI 3 lượt; Rules all pass; web checklist ảnh; cross-role deployed 3 lần | docs/test-report.md; chưa đủ bằng chứng |
| 9 Review | AI review code mới ≥3 findings + quyết định | docs/code-review.md FM findings; cần bằng chứng/commit đối chiếu cuối |
| 10 Repo | Tiếp nối Lab 3, tên PRM393_Final_<ID>, cấu trúc theo đề; README đủ roles/URL/run/demo/versions/tools/video | README; ID, URL, demo accounts, video chưa xác nhận |
| 10 Report/slides/video | Report 10–15 trang; slides 12–15; video live 8–12 phút, đủ nội dung | report/README.md; slides nhóm giữ nguyên để rà sau; chưa chốt file nộp |
| 12 Integrity | Lịch sử đóng góp thành viên, bằng chứng thật, khai báo AI | Không rewrite history/fake test; [N]/[date]/ID trong đề cần thầy/nhóm xác nhận |

Không bổ sung tính năng bonus hoặc server chỉ để lấp chỗ thiếu. Không xóa instrumentation Lab 3 vì Final vẫn kế thừa; chỉ bỏ cloud-file upload được Final thay thế rõ ràng.
