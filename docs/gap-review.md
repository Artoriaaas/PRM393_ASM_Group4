## Sửa lỗi Final — 13/11/2026

Analyze mobile/web sạch. Mobile 86/86 tests, web 28/28, core 6/6, Firestore emulator 12/12 nhóm đạt. Rules/indexes đã triển khai lên eventhub-group4.

Đã sửa phân quyền tạo/gửi/duyệt sự kiện, giữ ảnh bìa, Remote Config dashboard, chọn đăng ký mới nhất và vùng bấm tab lịch. Đây là kết quả tự động, chưa thay thế chạy cloud liên ứng dụng. AI và ARTEMIS vẫn để sau theo yêu cầu. Slides nhóm không sửa.

# Gap review — Final, 13/11/2026

| Hạng mục | Code hiện tại | Xác nhận còn lại |
|---|---|---|
| Phân vai mobile | Role stream từ Firestore, user-only router/providers, reject staff/admin và fail closed khi lỗi | Đăng nhập từng role trên cloud |
| Đăng ký/duyệt/QR | Pending, approved, rejected + lý do; giao dịch và Rules; không tạo active mới | Rules đã deploy; còn chạy liên ứng dụng 3 lần và đo độ trễ |
| Inbox | Tin riêng + announcements global/club/event, read receipts theo UID | CLB đăng tin và xem mobile realtime trên cloud |
| PDF | File local/private, chia sẻ native theo thao tác, metadata riêng trên Firestore | Native share sheet và metadata cloud trên thiết bị |
| Kiến trúc | mobile/, web/, packages/core/; model/theme/widgets/fonts/icons/Firestore services dùng chung | Test regression cả hai client |
| App Check | Debug provider/Play Integrity khởi tạo trước Firestore | Đăng ký app/token, verified metrics và enforcement Console chưa được xác nhận |
| Lab 2 states và Lab 3 instrumentation | Giữ flows/loading/empty/error; Auth/Analytics/RC/FCM/Crashlytics | Bằng chứng mới cho bản Final không được suy từ test Lab 3 |
| AI | Đã hoàn thành Level 2: Gemini Developer API + Remote Config + App Check + Analytics + Fallback thông minh | Kiểm tra live bằng API key thật trên Web |
| ARTEMIS | Hồ sơ/kịch bản Lab 3 còn trong repo | Cập nhật luồng Final và chạy sau theo yêu cầu |

Không kết luận “tất cả CLOSED” chỉ vì có source code hoặc build thành công. Báo cáo và video Final cần bằng chứng thực thi thật. Figma chưa đồng bộ trong đợt này; thay đổi được ghi ở design-traceability.md.

## Bàn giao và phần hệ thống còn mở

- Runtime chỉ mobile/lib/main.dart và web/lib/main.dart; mock entrypoints/server HTTP mô phỏng đã bỏ. Fake service chỉ dùng test. Tài liệu upload, Storage Rules, seed demo và report Lab03 đã bỏ khỏi cây hiện hành; không thay đổi Git history hoặc repo Lab 3.
- Đề Final mapping: docs/final-requirements.md. docs/ai-feature.md mới ghi yêu cầu/chưa triển khai, không có kết quả AI giả.
- Web deployment/ẩn danh, screenshot main action/error/empty, matrix Rules đầy đủ, demo account/Admin đầu tiên, URL/video và bộ PDF Final: chưa xác nhận hoàn tất.
- Slides nhóm giữ nguyên theo yêu cầu; rà nội dung/độ dài/claim riêng, không lấy số liệu slide làm test result.
