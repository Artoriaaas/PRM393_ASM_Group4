# Workflow EventHub — Final

Nguồn hiện hành: đề Final mục 3/6/9 và [cross-role flow](cross-role-flow.md). Đây là mô tả nghiệp vụ, không phải kết quả đã demo. Giữ flow Lab 2/3; không thêm server hoặc luồng tự cấp vé QR.

## Đăng ký và xét duyệt

1. User trên mobile xem sự kiện published/public, còn hạn và có clubId.
2. Gửi biểu mẫu → Firestore tạo registration pending. Chưa chiếm chỗ, chưa được quét QR.
3. Staff đúng CLB duyệt trên web → approved, activeCount tăng nguyên tử; hoặc rejected kèm reason, count giữ nguyên. Rules isStaffOf cũng cho admin theo quyền hiện hành, không tuyên bố admin bị cấm tuyệt đối.
4. Mobile nhận registration stream và tin riêng trong inbox. Tin inbox không đồng nghĩa có push FCM tự động.
5. User có thể hủy khi đủ điều kiện; pending hủy không đổi count; approved hủy trước giờ bắt đầu/chưa check-in trả lại chỗ. Retry phục hồi dùng cùng operation ID.

## QR check-in

1. Staff mở phiên trên web và hiển thị QR của sự kiện; mobile không phát/mở QR.
2. Người có registration approved quét; client băm SHA-256 chuỗi QR, Rules đối chiếu qrCredentials và phiên mở.
3. Khi hợp lệ, ghi checkInAt bằng server timestamp; status vẫn approved và UI hiển thị Đã điểm danh. Không có status ATTENDED riêng.
4. Quét lặp giữ mốc gốc; sai sự kiện/mã vô hiệu/phiên đóng hoặc chưa approved không ghi điểm danh.

## PDF và thông báo

- Announcements do web ghi, mobile inbox theo scope; dấu đọc riêng UID.
- PDF từ lịch hiện tại → local file theo UID → metadata Firestore. Chia sẻ qua Android chỉ khi user bấm. Không upload cloud/public URL.

## Chứng minh

Cross-role deployment 3 lượt và độ trễ ở docs/cross-role-flow.md; ARTEMIS và cloud proof ở docs/test-report.md. Không tự đánh dấu checklist demo đã đạt khi chưa quay/chạy.
