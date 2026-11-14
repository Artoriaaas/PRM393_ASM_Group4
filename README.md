# EventHub — PRM393 Final Assignment / Group 4

Một hệ thống gồm Flutter Mobile cho người tham gia, Flutter Web cho staff/admin và Firebase project **eventhub-group4**. Chủ đề kế thừa Lab 2/3; repo này dùng để nộp Final, không dùng bộ bàn giao Lab03.

## Phạm vi theo đề Final

- Mobile: mọi flow/state Lab 2 và yêu cầu Lab 3 còn áp dụng; dữ liệu Firestore; đăng ký chờ staff duyệt; inbox announcements.
- Web: Google Sign-In/chặn sai role, management, review queue, dashboard aggregation/chart và announcement form.
- Chung: MVVM, models/Firestore services/tokens/components tại packages/core; Rules phân vai; App Check.
- PDF **lưu/chia sẻ trên thiết bị**, chỉ metadata lưu Firestore. Không Cloud Functions, Cloud Storage, App Hosting, Cloudinary hoặc custom server.
- Gemini qua Firebase AI Logic đã có source và được bật trên cloud; còn bằng chứng chạy thật; không coi AI code review là tính năng AI cho người dùng.

## Bắt đầu và cấu trúc

| Thư mục | Dùng cho |
|---|---|
| mobile/ | Android participant app, lib/main.dart |
| web/ | Flutter Web staff/admin, lib/main.dart |
| packages/core/ | Models, contracts, Firebase services, tokens/components/font/icon dùng chung |
| firebase/ | Rules, indexes, Remote Config, emulator tests |
| e2e_test/ | ARTEMIS, 3 lượt/ca, chỉ tính kết quả có trace/assertion |
| docs/ | Yêu cầu, kiến trúc, hướng dẫn và đối chiếu Final |
| evidence/ | Bằng chứng thật; hồ sơ kế thừa được phân biệt với Final |
| report/ | Hướng dẫn report Final; PDF chưa hoàn tất |
| slides/ | Bộ slide nhóm được giữ nguyên; nội dung kiểm tra riêng |

Mobile:

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter run -d emulator-5554 -t lib/main.dart
```

Cần config `mobile/android/app/google-services.json`, SHA và App Check debug token của từng máy. Không commit token, keystore, service-account hay config local. Chi tiết [mobile setup](docs/mobile-setup.md).

Web:

```powershell
cd web
flutter pub get --enforce-lockfile
flutter run -d chrome -t lib/main.dart --dart-define-from-file=web_env.json
```

Tạo web_env.json local từ cấu hình Web app cùng project theo [Firebase setup](docs/firebase-setup.md). VS Code chỉ có cấu hình chạy Firebase, không có mock/server mô phỏng.

Emulator Rules tại gốc:

```powershell
npm ci --prefix firebase/tests
npx --yes firebase-tools@15.34.2 emulators:exec --only firestore --project demo-direct-booking "npm test --prefix firebase/tests"
```

Không chạy lệnh Flutter ở gốc hệ thống. Test doubles nằm trong test/, không phải entrypoint bản nộp. Không seed dữ liệu tự động khi mở app. Firebase Hosting lấy web/build/web theo firebase.json.

## Vai trò và tài khoản bàn giao

| Nội dung | Trạng thái |
|---|---|
| user | Mobile; guest/student là nhóm tự khai, không phải role quản trị |
| staff | Web; chỉ CLB được admin gán clubId |
| admin | Web; phân vai người khác; không tự đổi role |
| Admin đầu tiên | Chưa xác nhận danh tính để ghi README; chủ project cần cung cấp tài khoản demo được phép công bố |
| Demo user/staff/admin | Chưa có danh sách bàn giao đã xác nhận; không công bố mật khẩu |
| Web URL | https://eventhub-group4.web.app — đã deploy/HTTP200, cần kiểm tra đăng nhập và chức năng trong cửa sổ ẩn danh |
| Video Final | Chưa có link |
| ID đặt tên bài | Cần nhóm xác nhận theo lớp; đề dùng PRM393_Final_<ID>, Final_<ID>.pdf và Final_<ID>_slides.pdf |

Đề yêu cầu Git tiếp nối Lab 3 và thấy đóng góp thành viên. Không xóa/viết lại lịch sử để giả tiến trình. Nhóm cần xác nhận repo hiện tại đáp ứng lịch sử này trước nộp; không tự đổi tên remote.

## Kết quả tự động mới nhất

Mobile86, web40, core6 và Rules55 tests đạt; web/Rules/indexes đã deploy. Chưa thay thế kiểm thử native, 3AIoutputs/1failure, 3cross-role runs và request App Check hợp lệ. Xem docs/final-live-verification.md trước khi chạy.

## Theo dõi hoàn thành

- [Đối chiếu từng mục đề Final](docs/final-requirements.md)
- [Gap review toàn hệ thống](docs/gap-review.md)
- [Checklist mobile](docs/mobile-final-checklist.md) và [test một lượt](docs/one-pass-test.md)
- [Kiến trúc](docs/architecture.md), [data model](docs/data-model.md), [cross-role](docs/cross-role-flow.md)
- [Test report](docs/test-report.md), [AI requirements/status](docs/ai-feature.md), [code review](docs/code-review.md)
- [Traceability](docs/design-traceability.md), [Flutter handoff](docs/flutter-handoff.md)
- [Report](report/README.md), [video script](docs/demo-video-script.md), [evidence index](evidence/README.md)
- [Figma Lab 2](https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393): chưa xác nhận đồng bộ mọi thay đổi Final.

Code/build/unit test không thay thế cloud/native/cross-role proof. AI source/config đã có; ARTEMIS và bằng chứng thực thi Final vẫn cần trước nộp. Bộ slide của nhóm không bị sửa trong đợt dọn repo này và chưa được coi là bộ nộp đã xác nhận.

## Phiên bản và công cụ AI

Flutter **3.47.4**, Dart **3.13.3**; dependencies/lockfile theo từng package, không tự nâng phiên bản. ARTEMIS pin **351ca8422f7b5b54e80a9c1ce03a222e02415b6b**. Tham khảo kết quả đã chạy ở docs/test-report.md, không lấy số liệu slide thay log thực thi.

AI đã dùng theo lịch sử nhóm: Stitch hỗ trợ thiết kế; Antigravity hỗ trợ code/tài liệu; Codex hỗ trợ triển khai, review và kiểm thử; ARTEMIS/Groq thử E2E. Kết quả thử cũ không chứng minh suite Final đã pass. Gemini Firebase AI Logic đã triển khai web; còn 3 output thật,1failure và Analytics proof.

### AI content assistant (Final)

Web uses `firebase_ai` **5.1.0** (Firebase AI Logic Gemini Developer API), not a direct Gemini REST key. In the CLB event form choose a controlled topic, preview, and explicitly apply before editing/saving. Local fallback defaults are disabled; cloud RC version6 is enabled with model gemini-3.5-flash-lite. Web Enterprise is configured; real Gemini outputs still need verification. Setup and honest evidence status: [docs/ai-feature.md](docs/ai-feature.md). No real Gemini execution evidence is claimed from unit tests.

## Chạy thật để chốt 5 mục

[Hướng dẫn từng bước](docs/final-live-verification.md) · [Rules matrix đã chạy](docs/security-rules-matrix.md) · [Nơi lưu bằng chứng thật](evidence/final-live/README.md).

```powershell
node tool/check-cloud.cjs
# Sau khi mở app Android debug trên thiết bị test:
node tool/register-android-appcheck.cjs emulator-5554
```

Các lệnh hỗ trợ dùng phiên đăng nhập Firebase CLI hiện có và thư viện trong firebase/tests/node_modules; cần npm ci --prefix firebase/tests nếu máy mới. Không phải custom backend và không chạy trên Hosting. Lệnh kiểm tra cloud chỉ đọc; lệnh register chỉ đăng ký debug token đúng app test, không in token.

### Cấp quyền đại diện CLB
Admin tạo CLB → Quản lý người dùng → Phân công bằng email → gửi link cổng CLB qua kênh của trường. Đại diện đăng nhập Google đúng email để kích hoạt; không cần tạo tài khoản mobile trước. [Hướng dẫn và kiểm thử](docs/club-onboarding.md).
