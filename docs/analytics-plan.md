> Final: thay export_upload bằng export_share (row_count); export_generate giữ row_count. Metadata không chứa PII/URL. Cloudinary không còn trong app Final. Event AI chưa triển khai; ARTEMIS chưa chạy lại.

# Analytics plan — EventHub Lab 3

Lập trước khi thêm tracking (31/10/2026). Analytics không được làm thất bại nghiệp vụ; dùng adapter inject. Không gửi email, tên, điện thoại, QR token, URL download, nội dung tìm kiếm hoặc registration ID. Firebase user ID là UID giả danh sau đăng nhập và được xóa khi đăng xuất. `result`/`action`/`screen_code` là enum kiểm soát; số là int.

| Event | Trigger / flow | Tham số và kiểu | Câu hỏi sản phẩm | Bằng chứng còn cần |
|---|---|---|---|---|
| login | Auth xác nhận thành công | method:string google/password | Người dùng chọn cách nào? | DebugView |
| logout | Người dùng đăng xuất | method:string manual | Phiên kết thúc thế nào? | DebugView |
| search | A02/A03 gửi tìm kiếm | query_length:int | Người dùng có dùng tìm kiếm? | DebugView |
| view_event_detail | Mở A04 | screen_code:string A04 | Bao nhiêu lượt xem detail? | DebugView |
| view_registration_detail | Mở A08 | screen_code:string | Người dùng xem đăng ký ở đâu? | DebugView |
| view_checkin_result | Mở A12 | screen_code:string A12 | Bao nhiêu lượt xem kết quả? | DebugView |
| booking_submit | Gửi command đăng ký/hủy/checkin | action:string | Flow nào được dùng? | DebugView |
| booking_result | Backend confirmed/rejected/unknown | action:string, result:string | Flow nào có lỗi/phục hồi? | DebugView |
| booking_recover | Người dùng kiểm tra kết quả | action:string | Mức độ cần phục hồi mạng? | DebugView |
| export_generate | Tạo PDF thành công | row_count:int | Báo cáo có được dùng? | DebugView |
| export_upload | Upload hoàn tất | byte_count:int | Upload thành công bao nhiêu? | DebugView |
| notification_open | Chạm notification | source:string in_app/push | Thông báo dẫn tới hành động? | DebugView |
| remote_config_fetch | Fetch/activate cấu hình | result:string success/error | App có nhận config mới? | DebugView |
| view_screen | Thay route chính | screen_code:string | Đường đi qua các màn? | DebugView |

Có thể bổ sung event sau nhưng phải cập nhật bảng trước khi instrument. Không coi việc gọi SDK thành bằng chứng event đã nhận trên console.

Enable DebugView trên máy thử: `adb shell setprop debug.firebase.analytics.app com.eventhub.app`; mở Analytics → DebugView và chạy từng trigger. Chụp từng event + params vào `evidence/instrumentation/analytics/`. Tắt bằng `adb shell setprop debug.firebase.analytics.app .none.`. Đã có ảnh cho 8 tên event, 7 event có tham số riêng; xem [trạng thái bằng chứng](../evidence/instrumentation/status.md). Không coi đủ 7 là đủ mọi event trong plan.

Screen identity được quản lý tại `lib/utils/screen_identity.dart`: A01a–d riêng biệt; A11 quét QR; LAB3_EXPORT và LAB3_FIREBASE riêng khu demo. Route khởi tạo/development/không tồn tại không phát view_screen. Không đưa ID hoặc query vào screen_code.

Sửa source sau audit: notification_open phát source=push khi onMessageOpenedApp/getInitialMessage được xử lý với UID hợp lệ, source=in_app khi chạm một tin trong inbox. Receipt foreground không tự phát open. Cần chụp DebugView source=push sau cài bản mới. Lỗi lưu inbox có thông báo rõ và báo non-fatal notification_history_save_failed (không chứa nội dung tin/UID/token trong exception).
