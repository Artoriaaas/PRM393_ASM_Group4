# Bước 4 — Kết nối Firebase của Group4

Trạng thái ngày 31/10/2026: đã viết adapter Firebase Auth và UI A01a–d; **đã nhận cấu hình project `eventhub-group4`, package `com.eventhub.app` và OAuth web client; đăng nhập Google thật đã được chủ dự án xác nhận thành công ngày 31/10/2026; các nhánh lỗi/đăng xuất vẫn cần kiểm thử riêng**. Không đánh dấu bước 4 hoàn thành chỉ vì widget test/build pass.

## 1. Việc cần người sở hữu tài khoản thực hiện

1. Mở https://console.firebase.google.com/ bằng tài khoản Google của nhóm, tạo project `EventHub Group4`. Ghi lại **Project ID** thực, không dùng tên hiển thị thay ID. Có thể bật Analytics để dùng ở bước 9. Không cần bật billing chỉ để cấu hình Authentication.
2. Project settings → General → Add app → Android. Package chính xác: **`com.eventhub.app`**. Nickname tùy chọn `EventHub Android`.
3. Thêm SHA-1 và SHA-256 của khóa debug dùng trên máy chạy. Đọc bằng `android/gradlew.bat signingReport` trong Android folder, hoặc keytool với debug keystore local. Không gửi/commit keystore.
4. Authentication → Get started → Sign-in method: bật **Email/Password** và **Google**. Với Google chọn support email của nhóm. Chưa bật liên kết tài khoản tự động theo email bằng code.
5. Sau khi bật Google và thêm SHA, tải lại **google-services.json**, đặt tại `android/app/google-services.json`. File phải có project ID đúng và package `com.eventhub.app`; Google OAuth web client là `client_type: 3` cho Google Sign-In.
6. Gửi người hỗ trợ Project ID; file Android client config không phải service-account key. Không gửi mật khẩu/token/khóa riêng. Có thể commit client config theo đề, không commit service-account credentials.

Tài khoản console và cấp quyền/billing thuộc chủ project. Không có thông tin project thì không tạo config giả hoặc trỏ sang project của người khác.

Fingerprint debug đã đọc trên máy này (31/10/2026), có thể thêm vào Android app Firebase:

```text
SHA-1: 86:45:9E:E1:B3:AF:AA:A9:90:52:8D:AA:40:39:BD:FD:59:D4:0B:1F
SHA-256: B5:F9:2C:A0:CB:60:E8:F2:11:A7:C2:A7:B6:16:A8:EA:4B:F5:76:DB:F9:0C:2E:C7:ED:77:C3:A9:78:FE:7D:F8
```

Đây là dấu vân tay chứng chỉ công khai, không phải private key. Máy teammate dùng keystore khác cần thêm fingerprint của máy đó; release sau này cần fingerprint signing key tương ứng.

## 2. App đã chuẩn bị cách khởi động thế nào

Gradle áp dụng Google Services plugin khi file JSON tồn tại. `initializeFirebase()` đọc Android resources; thiếu hoặc lỗi cấu hình thì màn auth hiển thị trạng thái chưa kết nối, service từ chối thao tác. Không coi thiếu config là đăng nhập thành công. Đây là fallback development, cần bảo đảm bản nộp thật có config hợp lệ.

FlutterFire CLI theo đề cần chạy sau khi có project:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=<PROJECT_ID_THAT> --platforms=android --android-package-name=com.eventhub.app
flutter run -d emulator-5554
```

CLI có thể sinh `lib/firebase_options.dart` và cập nhật Gradle; kiểm tra diff trước khi nhận thay đổi. App Android hiện khởi tạo từ resources, không cần import file options chưa được sinh. Nếu thêm platform sau này, dùng options do CLI tạo đúng project. Ghi phiên bản CLI thực tế vào README sau khi cài.

Firebase Auth hiện dùng `firebase_core 5.1.0`, `firebase_auth 7.0.1`, `google_sign_in 7.2.0` theo lockfile; các phiên bản này đã được tải trong lần triển khai. FlutterFire/Auth API đã đối chiếu tài liệu chính thức:

- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/auth/flutter/federated-auth
- https://firebase.google.com/docs/auth/flutter/manage-users

## 3. Hành vi đã viết

- Google Sign-In qua native account picker, chuyển credential tới Firebase; hủy/lỗi có thông báo; không tự link provider trùng email.
- Email/password đăng nhập; tạo tài khoản với name/email/password, gửi verification. Khi tạo account xong nhưng gửi email lỗi, session unverified vẫn được giữ và có gửi lại; không tạo user trùng bằng nút retry đăng ký.
- Reload user + refresh token mới tiếp tục qua AuthGate; không tự bật `emailVerified` trên client.
- Quên mật khẩu gọi Firebase, thông báo có điều kiện sau phản hồi; không tiết lộ chắc chắn email tồn tại; mật khẩu mới được đặt qua liên kết email bên ngoài app.
- Đổi email xác thực lại bằng mật khẩu hiện tại và `verifyBeforeUpdateEmail`; chờ link mới, không tạo tài khoản thứ hai. Đây là điều chỉnh so với form Đổi email ở Lab 2; họ tên/email draft giữ trong bộ nhớ, không lưu mật khẩu vào provider/disk.
- Đăng xuất Firebase và Google, xóa draft auth. Chưa có dữ liệu user Firestore/offline cache của flow F1/F2 để xóa; khi bổ sung các provider user-scoped phải invalidate chúng khi UID thay đổi.

## 4. Thay đổi giao diện có truy vết

Tham chiếu Figma A01a `275:2894`, A01b `177:409`, A01c `177:610`, A01d `177:721`. Giữ font, spacing và hierarchy; tải icon Eye/Back/Bell từ Figma vào `assets/icons/`.

- Thêm Google button và bỏ guest entry theo D01/D02 trong traceability.
- Không hiển thị workshop hard-code trong tạo tài khoản/xác minh khi mở từ đầu app. Event summary chỉ được thêm từ dữ liệu sự kiện thật ở bước F1; giữ pending route, không nhúng workshop mẫu.
- Chưa có chính sách phát hành chính thức: dialog thông tin dữ liệu nêu rõ trạng thái này, không gắn nhãn đã đồng ý với điều khoản chưa tồn tại.
- Đổi email có mật khẩu hiện tại và link xác minh theo yêu cầu Firebase; cần đồng bộ bản thiết kế Lab 3 trước khi chốt fidelity.

## 5. Kiểm thử bắt buộc sau khi nối project

Chạy trên Android có Google Play. Dùng tài khoản Google test riêng.

| Tình huống | Kết quả cần xác minh và bằng chứng |
|---|---|
| Mở signed-out | A01a, không vào tab app; ảnh app |
| Google thành công | A02 hoặc pending route; UID thật trong Auth Users console |
| Hủy account picker | A01a có thông báo, không có phiên giả |
| Google lỗi cấu hình/mất mạng | Thông báo, thử lại; không tự link tài khoản |
| Đăng ký email | Có user unverified; mở A01c; không được vào nội dung |
| Xác nhận email | Link email → reload → token refreshed → pending route |
| Gửi lại email thất bại | Không tuyên bố gửi thành công; giữ email và cho thử lại |
| Đổi email | Xác thực lại; link mới, kiểm tra console sau xác nhận |
| Quên mật khẩu | Email không hợp lệ lỗi tại ô; email hợp lệ gọi thật; link reset hoạt động |
| Sign-out và mở lại app | Signed-out; không hiện dữ liệu user cũ |

Lưu ảnh tại `evidence/step4/` và ghi project ID trong ảnh khớp JSON. Widget/unit tests với fake service chỉ chứng minh điều phối UI, không chứng minh Firebase hoạt động. Sau auth mới triển khai Firestore nghiệp vụ theo rules được test; file rules hiện tại default-deny, không deploy thay một cấu hình đang sử dụng mà chưa review.

## Xác nhận kết nối ngày 31/10/2026

- Config Android đúng `eventhub-group4`, `com.eventhub.app`, OAuth web client và SHA-1 debug máy này.
- Build APK debug từ `lib/main.dart` và cài/mở trên emulator thành công.
- Chủ dự án báo đăng nhập Google thành công. Chưa thu ảnh Auth Users console; không suy rộng thành toàn bộ test auth đã pass.
- Ảnh màn đăng nhập có config: `evidence/step4/login-configured.png`.
