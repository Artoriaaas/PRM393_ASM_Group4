# Mobile Final — chạy và xác nhận

Cập nhật 13/11/2026. Mobile nằm trong `mobile/`, web nằm trong `web/`. Hai client dùng `packages/core/` cho model, contracts, tokens, widgets và Firestore services. Lab 3 riêng không thay đổi. AI và ARTEMIS được hoãn theo yêu cầu; không tính là đã hoàn tất Final.

## 1. Máy teammate

Dùng Flutter 3.47.4 / Dart 3.13.3, Android SDK và JDK tương thích Gradle dự án. Không tự nâng phiên bản dependency. Chạy từ gốc repo:

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter devices
flutter run -d emulator-5554 -t lib/main.dart
```

Thay ID bằng thiết bị thật nếu cần. VS Code chọn **EventHub Mobile — Firebase (Android)**. Mobile không chạy bằng Chrome; web chạy trong thư mục `web/` với cấu hình Firebase theo docs/firebase-setup.md.

Firebase dùng chung **eventhub-group4**, Android package **com.eventhub.app**. Tải `google-services.json` của app Android vào `mobile/android/app/`; file này không đưa lên Git. Thêm SHA-1/SHA-256 debug của từng máy vào Firebase Authentication theo `docs/firebase-setup.md`. Không tạo project riêng cho mỗi người, không gửi mật khẩu/key vào chat.

## 2. App Check — bước Console bắt buộc, chưa được xác nhận

Code mobile dùng `firebase_app_check 0.5.1`: debug build dùng AndroidDebugProvider; release dùng AndroidPlayIntegrityProvider. App Check được kích hoạt trước các service đọc Firestore.

1. Firebase Console → project eventhub-group4 → App Check → Apps → chọn Android com.eventhub.app và đăng ký Play Integrity, điền SHA-256 đúng ứng dụng.
2. Chạy app debug một lần. Log Android SDK in debug token; chỉ đăng ký token đó trong **App Check → Android app → Manage debug tokens**. Không commit token và không đưa token vào ảnh công khai.
3. Mỗi máy/emulator mới cần debug token riêng. Thêm SHA cho Google Sign-In không thay thế token App Check.
4. Xác nhận request Firestore của mobile được ghi nhận là verified trong App Check metrics. Đây là bằng chứng cần chụp, không chỉ chụp màn hình đã cài SDK.
5. Vì project dùng chung, teammate web phải đăng ký provider của web và xác nhận web được verified trước khi bật enforcement cho Firestore. Nếu bật sớm, web hoặc máy debug chưa đăng ký sẽ bị chặn.
6. Bật enforcement cho Firestore khi cả hai client sẵn sàng, chạy lại flow. Không bật AI Logic trong hạng mục mobile này: AI để sau.

Release APK cần cấu hình Play Integrity và chữ ký phát hành; debug APK với debug token chỉ dành kiểm thử. Chưa tuyên bố enforcement đã bật hoặc attestation đã đạt.

## 3. Chức năng và cách kiểm tra

### Vai trò

- Tài khoản `user` đăng nhập mobile bình thường.
- `staff`/`admin`: thấy màn từ chối vai trò, có Đăng xuất; không mở lịch, đăng ký hoặc thông báo người tham gia.
- Mất mạng/không đọc được role: màn lỗi xác minh và Thử lại; không mặc định cấp role user.
- Admin đổi role lúc app đang mở: role stream cập nhật, router chặn private routes, providers UID bị xóa. Không tự thay role tài khoản từ mobile.

### Đăng ký và web duyệt

1. CLB tạo/công khai sự kiện còn hạn, còn chỗ và có clubId đúng trên web.
2. User mobile tìm sự kiện → gửi yêu cầu → thấy Chờ duyệt trong lịch và chi tiết. Chưa được QR; số chỗ chưa giảm.
3. CLB duyệt trên web → chi tiết chuyển Đã được duyệt, có tin riêng trong Inbox. Số chỗ giảm một.
4. CLB mở phiên QR trên web → mobile quét và nhận thời gian từ máy chủ. Mobile không mở/điều khiển web CLB.
5. Thử từ chối với lý do, gửi lại, hủy lúc chờ và hủy khi được duyệt. Pending không chiếm chỗ; approved hủy đúng điều kiện trả lại chỗ.
6. Dữ liệu active cũ chỉ được đọc/hủy/điểm danh theo điều kiện cũ; ASM không cho tạo mới trực tiếp active kể cả sự kiện chưa có clubId. Không tự gán chủ CLB cho dữ liệu cũ.

### Inbox

- Tin duyệt/từ chối: đọc users/{uid}/notifications.
- Thông báo chung: đọc announcements scope global.
- Thông báo event/club: xuất hiện khi user có đăng ký pending/approved/active với sự kiện/CLB đó.
- Chạm tin đánh dấu đã đọc theo tài khoản; dấu đọc announcements lưu users/{uid}/announcementReads/{id}, không sửa thông báo gốc.
- Loading/empty/error/retry không biến lỗi đọc dữ liệu thành danh sách rỗng.

### PDF đúng Final

1. Tài khoản → Xuất lịch tham gia → Tạo và lưu PDF.
2. PDF nằm trong thư mục riêng của app, chia theo UID đã băm; nội dung không có email/số điện thoại. Không tự upload hoặc chia sẻ.
3. Firestore chỉ lưu users/{uid}/reports/{fileId}: fileName, mimeType, byteCount, rowCount, createdAt. Không lưu URL, đường dẫn máy hoặc nội dung PDF.
4. Bấm Chia sẻ PDF để mở hộp chia sẻ Android. Chọn ứng dụng hoặc lưu file bằng công cụ có trên thiết bị. Không cần quyền đọc toàn bộ bộ nhớ điện thoại.
5. Nếu metadata lỗi: PDF vẫn giữ trên máy; bấm Thử lưu metadata. Retry dùng cùng fileId, không tạo file trùng.
6. Đăng xuất xóa file riêng còn trong app; bản đã chủ động chia sẻ/lưu ra ngoài thuộc quyền người dùng, app không xóa được.

## 4. Kiểm tra code và Rules

```powershell
cd mobile
flutter analyze --no-pub lib test
flutter test --no-pub
flutter build apk --debug -t lib/main.dart
```

APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`. File APK không đưa lên Git.

Tại gốc repo:

```powershell
npm ci --prefix firebase/tests
.\firebase\tests\node_modules\.bin\firebase.cmd emulators:exec --only firestore --project demo-direct-booking "npm test --prefix firebase/tests"
```

Nếu đã chạy Firestore emulator port 8085, dùng `$env:FIRESTORE_EMULATOR_HOST="127.0.0.1:8085"` rồi `npm test --prefix firebase/tests` thay vì mở một emulator trùng cổng. Test chỉ xóa dữ liệu project demo trong emulator.

Rules của repo ASM đã deploy vào eventhub-group4 ngày 13/11/2026 trong đợt hoàn thiện mobile. Khi tiếp tục sửa Rules, test lại rồi deploy từ repo ASM. Không deploy lại Rules Lab 3 lên project này. Code được build/test local không chứng minh cloud và App Check đã cấu hình đúng.

## 5. Việc xác nhận cuối

- Đăng ký App Check, token debug và enforcement như mục 2.
- Chạy native share sheet trên Android thật/emulator.
- Chạy flow mobile–web 3 lần, đo độ trễ và lưu ảnh/video theo docs/cross-role-flow.md.
- AI và ARTEMIS để sau. Figma chưa được chỉnh trong lần triển khai này; các thay đổi được ghi trong design-traceability.md.

## Kết quả tự động đã chạy

Xem evidence/mobile-final/validation.md: mobile 84 tests, core 3 tests, web 23 tests, Rules 11 tests đạt; analyze sạch và APK/web build thành công. Rules đã deploy eventhub-group4. Các bước App Check Console, native share và flow mobile–web cloud ở trên chưa được xác nhận bằng thao tác thật trong đợt này.
