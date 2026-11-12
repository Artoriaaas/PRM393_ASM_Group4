# Rà soát Khoảng cách Giữa Lab 2, Lab 3 & Hoàn thiện Hệ thống (`docs/gap-review.md`)

> **Căn cứ yêu cầu**: Đề Final Assignment — Mục 5 (Workflow Stage 1: Gap review of Lab 2 and Lab 3) & Mục 11 (Grading rubric: "Every Lab 2 flow and Lab 3 requirement works; gap review closed").  
> **Mục đích**: Rà soát đối chiếu toàn bộ các thành phần từ thiết kế Lab 2 (`Figma`, `design/screen-spec.md`, `handoff/flutter-handoff.md`), quá trình triển khai Lab 3, và xác nhận tình trạng đóng các khoảng cách (`gap closure`) trong mã nguồn hiện tại của dự án EventHub.

---

## 1. Tổng quan Trạng thái Rà soát (`Audit Status Overview`)

Dự án EventHub phát triển liên tục trên cơ sở nối tiếp Lab 2 và Lab 3 thành một hệ thống hoàn chỉnh phục vụ đa vai trò:
- **Mobile App (`lib/`)**: Dành cho vai trò `user` (Sinh viên FPTU và khách vãng lai).
- **Shared Core (`packages/core/`)**: Chứa toàn bộ model, theme, design tokens và widget tái sử dụng.
- **Web Admin (`web/`)**: Dành cho vai trò `staff` (Trưởng CLB) và `admin` (Quản trị viên hệ thống).
- **Backend Firebase Serverless (`firebase/`)**: Cloud Firestore được bảo vệ bằng Security Rules đa vai trò, Firebase Auth, Remote Config, Analytics và Crashlytics.

---

## 2. Bảng Rà soát Từng Khoảng cách & Biện pháp Khắc phục (`Gap Matrix`)

| Hạng mục | Hiện trạng Lab 2 / Thiết kế gốc | Hiện trạng Lab 3 / Vấn đề phát sinh | Giải pháp & Trạng thái đóng (`Gap Status`) |
|---|---|---|---|
| **1. Xác thực & Phân quyền đa vai trò** | Lab 2 chỉ thiết kế form email/mật khẩu cho người tham gia; chưa có vai trò CLB hay Admin trên Mobile. | Lab 3 bổ sung Google Sign-In, tuy nhiên tài khoản `staff`/`admin` chưa có ranh giới rõ ràng nếu đăng nhập vào Mobile. | **ĐÃ ĐÓNG (`CLOSED`)**: Triển khai `users/{uid}.role` (`user`, `staff`, `admin`). Mobile App chỉ phục vụ `user`, chặn tài khoản sai vai trò (`Role Rejection`). Web Admin phục vụ `staff` và `admin` bằng Google Sign-In với màn hình chặn riêng (`role_rejection_screen.dart`). |
| **2. Cơ chế Duyệt Đăng ký (Cross-Role Flow 1)** | Lab 2: Sinh viên đăng ký và nhận xác nhận trực tiếp (`active`). | Lab 3: Cần chuyển sang cơ chế duyệt đơn hai chiều giữa Mobile và Web theo yêu cầu của đề Final. | **ĐÃ ĐÓNG (`CLOSED`)**: Đơn chuyển sang `pending` khi gửi từ Mobile (`A05`). Web Admin cung cấp màn `ReviewQueueScreen` để Trưởng CLB duyệt (`approved` kèm tăng `activeCount + 1`) hoặc từ chối (`rejected` kèm nhập lý do). Mobile cập nhật thời gian thực qua Stream. |
| **3. Điểm danh QR Trực tiếp (Cross-Role Flow 2)** | Lab 2: Màn quét `A11` và kết quả `A12`, nhưng giả định CLB mở màn hình QR bên ngoài mà không có hệ thống quản lý phiên. | Lab 3: Mobile có Scanner và băm SHA-256 mã QR, nhưng thiếu màn hình phát sinh mã và quản lý phiên phía CLB. | **ĐÃ ĐÓNG (`CLOSED`)**: Web Admin bổ sung `LiveQrPanelScreen` cho phép Trưởng CLB mở/đóng phiên (`checkinSessions/{eventId}`) và sinh mã QR động (`qrCredentials/{qrHash}`). Khi sinh viên quét trên Mobile, kết quả đồng bộ realtime sang cả hai màn hình. |
| **4. Hộp thư Thông báo Realtime (Inbox)** | Lab 2: Màn `A09` hiển thị thông báo mẫu. | Lab 3: FCM nhận test push từ Console, nhưng chưa có luồng tự động nhận thông báo khi có thay đổi trạng thái đơn hoặc thông báo từ CLB. | **ĐÃ ĐÓNG (`CLOSED`)**: Bổ sung collection `announcements` cho phép Web Admin phát thông báo, kết hợp với `users/{uid}/notifications` nhận thông báo duyệt/từ chối đơn. Tab `A09` trên Mobile lắng nghe realtime cả hai luồng này. |
| **5. Kiến trúc Thư viện Dùng chung (`packages/core/`)** | Lab 2 & Lab 3: Toàn bộ model và widget nằm cục bộ trong thư mục `lib/` của Mobile App. | Đề Final yêu cầu cả Mobile và Web cùng tái sử dụng chung một Design System và kiến trúc MVVM. | **ĐÃ ĐÓNG (`CLOSED`)**: Đã tách toàn bộ `models/`, `services/contracts/`, `theme/`, `utils/`, và `widgets/` sang `packages/core/`. Cả `lib/` (Mobile) và `web/lib/` (Web) đều phụ thuộc vào `packages/core/`. |
| **6. Giao diện Màn hình rộng (Wide-screen Layout)** | Lab 2: Chỉ thiết kế frame mobile (360dp / 390dp / 412dp). | Web Admin cần hiển thị trên Desktop/Tablet mà không bị vỡ layout hoặc kéo giãn form quá mức. | **ĐÃ ĐÓNG (`CLOSED`)**: Dựng `AppShell` cho Web với Navigation Drawer/Rail cố định, vùng nội dung giới hạn `maxWidth: 1200` (form đơn lẻ `maxWidth: 800`), thích ứng mượt mà từ màn hình nhỏ đến màn hình máy tính để bàn. |
| **7. Không xóa cứng Dữ liệu (`Soft Delete / Archive`)** | Thiết kế gốc có nút "Hủy sự kiện" hoặc xóa. | Đề Final và thực tiễn dữ liệu yêu cầu không được dùng lệnh `delete` làm mất toàn vẹn lịch sử tham gia của sinh viên. | **ĐÃ ĐÓNG (`CLOSED`)**: Chuyển toàn bộ thao tác xóa sang cờ trạng thái `archived` hoặc `cancelled` trên cả Firestore Security Rules và giao diện Web. |
| **8. Bảo vệ Quyền riêng tư (Privacy & PII)** | Lab 2: Màn `A12` vô tình hiển thị cả email/số điện thoại khi xuất trình biên nhận. | Nguy cơ lộ thông tin cá nhân của người tham gia tại bàn điểm danh đông người. | **ĐÃ ĐÓNG (`CLOSED`)**: Màn `A12` trên Mobile ẩn hoàn toàn email và số điện thoại, chỉ hiển thị họ tên, thông tin sự kiện và mốc thời gian máy chủ xác nhận điểm danh. |
| **9. Xử lý Lỗi Mạng & Tránh Gửi Lặp** | Thao tác bấm nút nhiều lần có thể gây đăng ký trùng hoặc trừ sai số chỗ. | Mạng di động chập chờn khiến client timeout dù máy chủ đã xử lý xong. | **ĐÃ ĐÓNG (`CLOSED`)**: Triển khai `lastOperationId` (chuỗi hex 48 ký tự) lưu cục bộ qua `SecurePendingBookingStore`; client có thể kiểm tra trạng thái cũ (`recover`) hoặc gửi lại an toàn mà không sinh đơn trùng. |

---

## 3. Kết luận Rà soát (`Gap Review Conclusion`)

Tất cả các khoảng cách kiến trúc, luồng người dùng và ranh giới phân vai giữa Lab 2, Lab 3 và đề Final Assignment **đều đã được giải quyết triệt để trong mã nguồn và tài liệu kiến trúc**. Hệ thống EventHub đã sẵn sàng đáp ứng trọn vẹn tiêu chí đánh giá của đề Final Assignment.
