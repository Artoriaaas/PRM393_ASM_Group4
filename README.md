# EventHub — Lộ trình Lab 3

Lab 2 đã được người dùng chốt. Thư mục này bắt đầu giai đoạn triển khai app Flutter Android từ thiết kế đó.

**Bắt đầu tại [Kế hoạch từng bước](KE-HOACH-LAB3.md).** Đã có nền Flutter, UI prototype riêng và các màn dùng service Firestore/Functions. Project `eventhub-group4` đã cấu hình; Google Sign-In được chủ dự án xác nhận thành công. Nghiệp vụ mới đã kiểm thử local, còn deploy và kiểm thử cloud.

## Tài liệu triển khai đã lập

- **[Bộ UI prototype tương tác và hướng dẫn chia việc](docs/ui-prototype.md)** — chạy `flutter run -t lib/main_prototype.dart`; có A01–A12, catalog và state demo. Không cần Firebase, không dùng làm bằng chứng cloud.

- [Đối chiếu Lab 2 → Lab 3](docs/design-traceability.md): màn, route, ViewModel, dữ liệu, flow, component và nhật ký khác biệt.
- [Kiến trúc MVVM](docs/architecture.md): Riverpod, lớp/service, dữ liệu/quyền, transaction, theme và Firebase.

Đã kiểm kê trực tiếp tên/node Final UI và Components ngày 30/10/2026. Các bổ sung Lab 3 (Google Sign-In, auth gate, export và Firebase demo, nhãn email hồ sơ) đã được đặc tả nhưng chưa đồng bộ Figma. Nguồn dữ liệu/backend CLB và khả năng triển khai Firebase phải xác minh ở bước cấu hình.

- Tài liệu Lab 2: `D:/Ky8/prm323-lab2-group2`.
- Figma: https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393
- Đề gốc: `C:/Users/ThinhCri/Downloads/PRM393 - Lab 3 Cloud-Enabled Mobile App (Firebase, Patrol, AI Code Review).pdf`.
- Nội dung đề yêu cầu **Google ARTEMIS**, dù tên file và footer còn ghi Patrol.
- Repo nộp theo đề: `PRM393_Lab03_<StudentID>`; tên thư mục local hiện tại không quyết định tên repo nộp.

## Tiến độ

- [x] Lập lộ trình thực hiện.
- [ ] Bước 1 — Đã lập bảng đối chiếu và phạm vi; còn đồng bộ các bổ sung Lab 3 lên Figma.
- [x] Bước 2 — Đã lập đặc tả kiến trúc, dữ liệu và mapping theme/widget.
- [x] Bước 3 — Môi trường, project và nền UI (Flutter stable, MVVM + Riverpod, Theme Be Vietnam Pro, Bộ widget nền, Khung routing 4 tab & Dev preview, verified trên Android emulator).
- [ ] Bước 4 — Google Sign-In đã được xác nhận; còn hoàn tất các nhánh auth và bằng chứng console.
- [ ] Bước 5 — F1: đã code/test local; chờ backend và dữ liệu cloud.
- [ ] Bước 6 — F2: đã code/test local; còn cloud và cập nhật sự kiện/FCM.
- [ ] Bước 7 — F4A: đã có camera/backend; còn kiểm tra QR web CLB và cloud.
- [ ] Bước 8 — Sinh file và Cloud Storage.
- [ ] Bước 9 — Analytics, Crashlytics, Remote Config, FCM.
- [ ] Bước 10 — ARTEMIS và bằng chứng kiểm thử.
- [ ] Bước 11 — AI code review và sửa lỗi.
- [ ] Bước 12 — Báo cáo, slide, video và nộp bài.

## Môi trường & Công cụ thực tế (Bước 3)

- **Flutter**: Channel stable 3.47.4 (Framework revision `9584c6713b`, Engine revision `06a2e2a110`).
- **Dart SDK**: 3.13.3.
- **Android SDK**: 36.0.0, Platform `android-36.1`, build-tools `36.0.0` tại `C:\Users\ThinhCri\AppData\Local\Android\Sdk`.
- **Java JDK**: OpenJDK Runtime Environment 21.0.10 (build `21.0.10+-14961533-b1163.108`) tại `C:\Program Files\Android\Android Studio\jbr\bin\java`.
- **Android Emulator**: Version 37.1.11.0 (AVD: `Fitmate_Medium_API35` - Android 15 API 35 x86_64).
- **ADB**: Android Debug Bridge version `1.0.41` (Version 36.0.0-13207044).
- **Application ID đề xuất**: `com.eventhub.app` (cấu hình trong `android/app/build.gradle.kts` và `MainActivity.kt`).

## Dependencies đã chọn

- `flutter_riverpod: 3.4.3` — Quản lý state MVVM và dependency injection độc lập giao diện.
- `go_router: 18.1.2` — Quản lý routing khai báo, hỗ trợ `StatefulShellRoute` cho 4 tab điều hướng persistent và navigation stack.
- `cupertino_icons: ^1.0.8` — Bộ icon phụ trợ.
- **Font nội bộ**: `Be Vietnam Pro` (Regular 400, Medium 500, SemiBold 600, Bold 700) lưu tại `assets/fonts/` và khai báo trong `pubspec.yaml`, không phụ thuộc tải mạng khi mở app.

## Hướng dẫn cài đặt và chạy ứng dụng

```powershell
# 1. Lấy dependencies
flutter pub get

# 2. Kiểm tra format mã nguồn
dart format --output=none --set-exit-if-changed .

# 3. Phân tích tĩnh mã nguồn
flutter analyze

# 4. Chạy toàn bộ test tự động (widget & routing)
flutter test

# 5. Build file APK debug
flutter build apk --debug

# 6. Khởi động emulator và chạy app
flutter emulators --launch Fitmate_Medium_API35
flutter run -d emulator-5554
```

## Bằng chứng thực tế (Evidence)

- [Ảnh chụp màn hình Khám phá A02](evidence/discover_screen.png) — Giao diện chính A02 với 4 tab bottom navigation, top bar, search bar và trạng thái placeholder.
- [Ảnh chụp màn hình Xem thử Component](evidence/component_preview_live.png) — Màn hình dev xem thử toàn bộ component nền.
- [Ảnh chụp màn hình Khung nhìn 360dp](evidence/component_preview_360dp.png) — Khung nhìn giới hạn 360 dp kiểm tra tính thích ứng, không tràn viền.
- [Ảnh chụp cuộn xem các Component](evidence/component_preview_scroll1.png), [Scroll 2](evidence/component_preview_scroll2.png), [Scroll 3](evidence/component_preview_scroll3.png), [Scroll 4](evidence/component_preview_scroll4.png) — Nút bấm, trường nhập, tìm kiếm, status badges, loading, empty, error, palette và typography.
- [Ảnh chụp sau khi ấn Back](evidence/after_back.png) — Điều hướng quay lại màn hình trước hợp lệ.

## Những phần còn lại của Bước 3 / Chờ Bước 4

### Bước 4 đang triển khai — 31/10/2026

Đã thêm Firebase Auth adapter, Google Sign-In, A01a–d, đổi email có xác minh và đăng xuất. Xem [hướng dẫn kết nối Firebase](docs/firebase-setup.md) với Application ID, fingerprint debug và checklist test. Project chung `eventhub-group4` đã có config; chủ dự án xác nhận Google đăng nhập thành công. Email/password và các nhánh lỗi còn cần test cloud. Mở app khi thiếu config có thông báo rõ; không tạo user giả. Bốn tab và nghiệp vụ F1/F2/F4A đã nối service, cần deploy backend để chạy cloud đầy đủ.

Dependencies mới trong lockfile: firebase_core 5.1.0, firebase_auth 7.0.1, google_sign_in 7.2.0, flutter_svg 2.3.2. Android khởi tạo bằng resources sinh từ google-services.json; đã có config Android của project nhóm. Firestore Rules/indexes và Remote Config đã deploy; Functions/Storage còn chờ billing.

### Sửa sau review ngày 31/10/2026

- Router theo session restoring/signed-out/unverified/signed-in, giữ đích nội bộ qua đăng nhập/xác minh. FirebaseAuthService dùng đăng nhập thật; InitialAuthService chỉ dùng khi thiếu config hoặc trong test.
- Màn `/dev/components` và các nút mở chỉ tồn tại khi debug. Trong debug có thể mở route này trực tiếp để kiểm tra component khi chưa có Firebase; không giả lập đăng nhập.
- Nút cho xuống dòng nhãn dài; badge co theo chiều rộng, dialog cuộn khi nội dung/chữ lớn, thông báo lỗi trường hỗ trợ nhiều dòng.
- Chạy lại `flutter test`: 15/15 pass, bao gồm auth redirect, chuyển tab với session test injected, dialog/placeholder ở 360/412 dp và text scale 200%. Đây là widget test, chưa phải ARTEMIS hay chạy lại Android.
- Ảnh evidence cũ bên trên thuộc lần dựng trước guard; không dùng ảnh Khám phá để chứng minh app signed-out hiện mở vào A02.

- Đã dựng hoàn chỉnh khung nền tảng: Theme, Tokens, Bộ widget dùng lại, Cấu trúc MVVM + Riverpod, Khung routing 16 routes và màn hình xem thử component.
- **Chưa thực hiện (theo kế hoạch sang Bước 4 trở đi)**:
  - Đã có code Firebase Auth/Google Sign-In, còn cấu hình project nhóm và kiểm thử thật (xem phần Bước 4).
  - Chưa triển khai Cloud Functions và Firestore rules.
  - Chưa thực hiện logic nghiệp vụ F1 (đăng ký), F2 (hủy đăng ký), F4A (quét QR điểm danh).
  - A02–A12 còn là khung phát triển/placeholder; A01 đã có form thật nhưng cần project Firebase hợp lệ. Không tạo dữ liệu giả hay kết quả giả.

## Theo dõi thay đổi giao diện

Lưu ảnh trước/sau và lý do theo [quy ước bằng chứng thay đổi thiết kế](evidence/design-changes/README.md), ghi vào [bảng đối chiếu](docs/design-traceability.md) và cập nhật Figma. Mục tiêu tiếp theo là app chạy dịch vụ Firebase thật dùng chung cho nhóm, phát triển từ nền UI hiện có.

## Triển khai nghiệp vụ đang thực hiện (31/10/2026)

Google Sign-In trên `eventhub-group4` đã được chủ dự án xác nhận. Firestore đã được chủ dự án tạo. A02–A09/A11–A12 có màn Flutter nối service Firestore/Functions, ViewModel và backend transaction; chưa deploy hoặc xác minh các flow trên cloud. Xem [thiết lập backend](docs/backend-setup.md) và [bằng chứng local](evidence/backend/validation.md). Bản `main_prototype.dart` vẫn chỉ là UI demo riêng; bản app thật dùng `lib/main.dart`.

Package mới: `cloud_firestore 7.1.0`, `cloud_functions 7.0.1`, `flutter_secure_storage 11.2.0`, `mobile_scanner 7.4.3` (lockfile). Backend Node runtime 22, dependencies pin trong `functions/package.json`; Firebase CLI kiểm thử 15.34.2.


## Trạng thái hiện hành — 01/11/2026

Xem [bảng bàn giao Lab 3](docs/lab3-readiness.md). Code có profile, PDF/Storage adapter, FCM, Analytics, Crashlytics và Remote Config; không đồng nghĩa tất cả dịch vụ đã được kiểm thử cloud. Firestore Rules/indexes và Remote Config đã deploy. Functions/Storage, ARTEMIS, PR review và báo cáo cuối còn các đầu vào/bằng chứng được liệt kê trong bảng bàn giao. Các số test ở phần tiến độ cũ là kết quả tại thời điểm từng bước; kết quả mới nằm trong [validation](evidence/backend/validation.md).
