# Cloudinary Free cho PDF Lab 3

Cloudinary là phương án thay Firebase Storage theo quyết định của nhóm. **Đây là upload unsigned; URL của file có thể chia sẻ và preset công khai.** Chỉ dùng PDF lịch không chứa email/số điện thoại. Không dùng cho giấy tờ hay dữ liệu cá nhân nhạy cảm.

1. Tạo một tài khoản Cloudinary Free dùng chung cho nhóm, không đưa mật khẩu/API secret vào Git hoặc chat.
2. Project hiện dùng **Cloud name `qcfqv5oj`**, **unsigned preset `eventhub_lab3_pdf_test`**. Preset cần `Allowed formats: pdf`, thư mục `eventhub/lab3-test`, public ID tự tạo; không bật overwrite. Cloudinary không hỗ trợ giới hạn dung lượng riêng theo unsigned preset; app kiểm tra 5 MB ở client.
3. Trong **Settings → Security**, bật **Allow delivery of PDF and ZIP files** để URL PDF mở được trên gói Free. Đã xác minh ngày 05/11/2026: trước khi bật, URL trả HTTP 401; sau khi bật, URL cũ và PDF thử mới đều trả HTTP 200, `application/pdf`.
4. Chạy app trên Android bằng PowerShell:

   ```powershell
   flutter run -d emulator-5554 -t lib/main.dart --dart-define=CLOUDINARY_CLOUD_NAME=qcfqv5oj --dart-define=CLOUDINARY_UPLOAD_PRESET=eventhub_lab3_pdf_test
   ```

5. Đăng nhập, có ít nhất một đăng ký, vào **Tài khoản → Xuất lịch tham gia → Tạo PDF và tải lên**. Mở URL được trả về và kiểm tra đúng file. Chụp màn app, URL (che phần nhạy cảm nếu có) và Cloudinary Media Library làm bằng chứng. Thử một lần khi mất mạng để ghi state lỗi, rồi thử lại.
6. Preset được nhúng trong app nên có thể bị người ngoài dùng để tải file lên tài khoản Cloudinary. Theo dõi quota, đổi tên hoặc tắt preset sau buổi demo. Không dùng API secret trên mobile. URL public hiện không giới hạn người xem theo UID; phần bảo vệ riêng theo tài khoản chưa đạt.

Ứng dụng kiểm tra đầu vào `%PDF-`, tối đa 5 MB và chỉ nhận URL `https://res.cloudinary.com/...` từ phản hồi. Cloudinary vẫn phải cấu hình giới hạn phía Console; kiểm tra ở client không thay được giới hạn server.
