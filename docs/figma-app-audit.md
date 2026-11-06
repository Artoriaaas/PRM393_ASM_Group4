# Kiểm kê trực tiếp Figma → Flutter — 07/11/2026

File WC21Na9ZDS8jjM2LzPKeXa. Phiên đọc f2e0005a-c671-41ec-a4bb-5f7d62e457bc. Chỉ đọc, không sửa Figma. Source mobile fb0517a. Inventory node IDs lưu ở figma-screen-inventory.json.

## Phạm vi và cách đếm

- Page 03 `153:2`: 78 frame màn hình có parent bắt đầu `Final UI /`; gồm biến thể/state, không phải 78 chức năng. Thêm 74 frame cũ/QA trong các row A01–A06/A07–A12/QA; không cộng các frame lồng tên trùng hoặc vùng scroll.
- Page 06 `199:1681`: 55 frame màn mô phỏng F1/F2/F4A. Đây là các snapshot phục vụ flow, không phải toàn bộ Final UI.
- Code có A01a–d và A02–A12. Không thiếu nguyên nhóm chức năng, nhưng chưa đủ state/control và chưa có kết luận pixel 1:1.
- Audit là kiểm kê cấu trúc Figma, đọc nội dung các state trọng điểm và đối chiếu source; không phải chạy Present hoặc ảnh Android đối chiếu mọi frame. Cần xác nhận bộ Final UI mới là baseline của nhóm vì frame cũ vẫn còn.

| Nhóm | Đối chiếu code | Thiếu hoặc khác xác định được |
|---|---|---|
| A01a–d | AuthScreen(mode), AuthViewModel: login/register/verify/reset/change-email, busy/error và giữ draft | Có các nhóm; layout app đã thêm Google theo Lab3, chưa xác minh visual 1:1 |
| A02/A03 | EventListScreen, eventFilterProvider/feed và loading/empty/error | `179:908` / `199:1816` là bottom sheet Lọc sự kiện; app dùng chip/dropdown inline, không có sheet. Cover mới và bỏ Xem tất cả là thay đổi có log, chưa sync Figma |
| A04 | EventDetailScreen: availability, active registration, free mode | Có nhánh chặn/tự do/đã đăng ký; bố cục/ảnh khác baseline. Chưa kiểm visual mọi trạng thái |
| A05 | RegistrationFormScreen + BookingViewModel: sinh viên/khách, lỗi K, sending/unknown/recover/retry | Có cơ chế, chưa chứng minh UI của từng snapshot tương ứng bằng E2E |
| A06 | RegistrationDetailScreen(success:true), snapshot participant | Có xác nhận/khách qua cùng route; chưa so hình toàn bộ |
| A07 | LiveScheduleScreen: tabs, empty/loading/error, cancelled/ended/guest | Có nhóm, tự hủy và CLB hủy dùng nội dung phân biệt. Chưa so tất cả snapshot |
| A08 | RegistrationDetailScreen, cancel dialog/recovery/canCancel | `181:1572`: thiết kế hiện phiên mở mới có CTA; app không đọc checkinSessions để hiển thị trạng thái phiên, hiện Quét QR cho đăng ký active/published chưa điểm danh. Không thể tự hủy chỉ ẩn nút, chưa có thông báo riêng như `181:1728` |
| A09 | NotificationsTabScreen/NotificationsViewModel, dữ liệu từ inbox | Có list/empty/error và route; đổi lịch/hủy cần message thật tương ứng, chưa có chứng cứ mọi state |
| A10 | ProfileEditScreen/ProfileViewModel: busy/error/dirty/pending email | `181:2118` có Gửi lại email xác nhận; app chỉ hiện pending email, chưa có CTA gửi lại trong màn chỉnh hồ sơ. Google email readonly là deviation đã ghi |
| A11 | ScannerScreen/camera/BookingFeedback, unknown/recover | `182:1866` QR sai sự kiện và `182:1887` phiên đóng chưa được phân biệt: FirestoreEventService đổi permission-denied khi checkin thành invalid-qr. `182:1908` có Xem sự kiện; app null/inactive về Khám phá. Đăng ký đã hủy và chưa đăng ký cùng một empty state |
| A12 | RegistrationDetailScreen(checkInResult:true), giờ server, không email | Có xem giờ cũ/hủy; mới thành công và xem lại đều dùng Bạn đã điểm danh. Thiếu câu Đưa màn hình này cho CLB kiểm tra của `182:1995/2036/2074` |

## Kết luận

Không được ghi “đã đưa toàn bộ Figma vào app 1:1”. Đủ nhóm chức năng, chưa đủ chi tiết các state/control trên. Các khác biệt được người dùng chấp nhận trước (cover, Google login, bỏ Xem tất cả, demo Firebase) cần cập nhật lại Figma. Các phần thiếu chưa tự sửa trong lượt audit; không tạo route riêng cho mọi state mà phải xuất hiện theo dữ liệu/lỗi thực tế.
