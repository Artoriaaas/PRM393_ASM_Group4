# Cloudinary Free cho PDF Lab 3

Cloudinary là phương án thay Firebase Storage theo quyết định của nhóm. **Đây là upload unsigned; URL của file có thể chia sẻ và preset công khai.** Chỉ dùng PDF lịch không chứa email/số điện thoại. Không dùng cho giấy tờ hay dữ liệu cá nhân nhạy cảm.

1. Tạo một tài khoản Cloudinary Free dùng chung cho nhóm, không đưa mật khẩu/API secret vào Git hoặc chat.
2. Ở Console, ghi lại **Cloud name**. Vào Settings → Upload → Upload presets → Add upload preset. Chọn **Unsigned**, đặt tên ví dụ `eventhub_lab3_pdf`, folder riêng `eventhub-lab3-reports`. Giới hạn **Allowed formats: pdf**, kích thước tối đa **5 MB** nếu Console có tùy chọn. Không bật overwrite; tắt các nguồn/định dạng không cần dùng.
3. Chạy app trên Android bằng PowerShell:

   ```powershell
   flutter run -d emulator-5554 -t lib/main.dart --dart-define=CLOUDINARY_CLOUD_NAME=<cloud-name> --dart-define=CLOUDINARY_UPLOAD_PRESET=<preset-name>
   ```

4. Đăng nhập, có ít nhất một đăng ký, vào **Tài khoản → Xuất lịch tham gia → Tạo PDF và tải lên**. Mở URL được trả về và kiểm tra đúng file. Chụp màn app, URL (che phần nhạy cảm nếu có) và Cloudinary Media Library làm bằng chứng. Thử một lần khi mất mạng để ghi state lỗi, rồi thử lại.
5. Preset được nhúng trong app nên có thể bị người ngoài dùng để tải file lên tài khoản Cloudinary. Theo dõi quota, đổi tên hoặc tắt preset sau buổi demo. Không dùng API secret trên mobile. Nếu cần file chỉ chủ sở hữu xem, phải chuyển sang upload có chữ ký qua backend đáng tin cậy hoặc chỉ tạo/chia sẻ PDF cục bộ.

Ứng dụng kiểm tra đầu vào `%PDF-`, tối đa 5 MB và chỉ nhận URL `https://res.cloudinary.com/...` từ phản hồi. Cloudinary vẫn phải cấu hình giới hạn phía Console; kiểm tra ở client không thay được giới hạn server.
