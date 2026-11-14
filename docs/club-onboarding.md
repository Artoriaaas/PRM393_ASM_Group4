# Phân công đại diện CLB trước lần đăng nhập đầu tiên

Luồng đã chốt: nhà trường công nhận CLB ngoài hệ thống; Admin tạo hồ sơ CLB và phân công email Google trên web. Không đăng ký CLB trên mobile, không gửi mật khẩu, không tự cấp quyền và không gửi email tự động.

## Thao tác Admin

1. Đăng nhập tài khoản Admin trên cổng web. Vào Quản lý CLB, tạo CLB và giữ trạng thái hoạt động.
2. Vào Quản lý Người dùng & Phân quyền → Phân công đại diện CLB bằng email.
3. Nhập email Google chính xác, chọn CLB rõ ràng (không tự chọn CLB đầu tiên), Lưu phân công.
4. Danh sách hiển thị Chờ đăng nhập. Sao chép link cổng CLB và gửi qua kênh liên lạc của nhà trường.
5. Đại diện đăng nhập Google đúng email → phân công chuyển Đã kích hoạt; tài khoản nhận staff và clubId tương ứng, không cần đăng nhập mobile trước.
6. Đổi người đại diện: Thu hồi phân công cũ (xác nhận) → phân công email mới. Thu hồi gỡ quyền staff của tài khoản còn quản lý đúng CLB, giải phóng chỗ phân công, giữ dữ liệu sự kiện. Nếu quyền đã đổi sang CLB khác/Admin, không ghi đè quyền mới.

Tài khoản cũ được cấp staff trực tiếp trước tính năng này: Admin đổi về user trong danh sách người dùng trước khi dùng luồng phân công email mới. Email/CLB đã có quản lý đang hoạt động bị service chặn để tránh phân công nhầm.

## Đăng nhập và bảo mật

Email được trim/lowercase; không tự ghép alias Gmail. Đại diện dùng đúng email Google đã phân công. Tài khoản không có phân công vẫn là user và nhận hướng dẫn liên hệ quản trị viên nhà trường.

- `clubAssignments/{email}`: email, clubId, clubName, status=pending, createdBy, createdAt. Khi nhận: acceptedUid, acceptedAt, status=accepted. Khi thu hồi: revokedBy, revokedAt, status=revoked.
- `clubManagerSlots/{clubId}`: email giữ chỗ. Cấp và thu hồi dùng transaction; không ghi đè chỗ đã có phân công.
- Chỉ Admin list/cấp/thu hồi. Tài khoản email đã xác minh chỉ get phân công đúng email trong Firebase Auth token; không dựa vào email tự sửa trong hồ sơ.
- Chỉ Google sign-in mới nhận phân công. Nhận quyền ghi đồng thời user→staff và pending→accepted. Rules đối chiếu getAfter cả hai tài liệu, CLB hoạt động và giữ chỗ; cấm đổi clubId, đổi người nhận, nhận lại hoặc nâng lên Admin.
- Hồ sơ web được theo dõi realtime để thu hồi quyền cập nhật phiên đang mở; Rules luôn là lớp quyết định quyền kể cả client cũ.
- Không thêm Cloud Functions hay backend riêng.

## Xác nhận thật sau khi triển khai

Admin tạo một CLB thử hợp lý, phân công Gmail riêng của người kiểm thử. Dùng cửa sổ trình duyệt khác đăng nhập Gmail đó lần đầu, kiểm tra đúng CLB, tạo bản nháp và gửi duyệt. Thu hồi trong cửa sổ Admin, xác nhận cửa sổ đại diện mất quyền; đăng nhập lại không khôi phục quyền cũ. Thử Gmail khác và email chưa phân công: không được vào quản lý.

Các test local không thay thế lần chạy thật này. Cần triển khai đồng thời web và Firestore Rules mới; chưa có bằng chứng chạy onboarding trên Hosting.
