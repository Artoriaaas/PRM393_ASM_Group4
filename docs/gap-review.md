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
| AI | Chưa triển khai | Để sau theo yêu cầu |
| ARTEMIS | Hồ sơ/kịch bản Lab 3 còn trong repo | Cập nhật luồng Final và chạy sau theo yêu cầu |

Không kết luận “tất cả CLOSED” chỉ vì có source code hoặc build thành công. Báo cáo và video Final cần bằng chứng thực thi thật. Figma chưa đồng bộ trong đợt này; thay đổi được ghi ở design-traceability.md.
