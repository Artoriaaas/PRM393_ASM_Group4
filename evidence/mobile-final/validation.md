## Sửa lỗi Final — 13/11/2026

Analyze mobile/web sạch. Mobile 86/86 tests, web 28/28, core 6/6, Firestore emulator 12/12 nhóm đạt. Rules/indexes đã triển khai lên eventhub-group4.

Đã sửa phân quyền tạo/gửi/duyệt sự kiện, giữ ảnh bìa, Remote Config dashboard, chọn đăng ký mới nhất và vùng bấm tab lịch. Đây là kết quả tự động, chưa thay thế chạy cloud liên ứng dụng. AI và ARTEMIS vẫn để sau theo yêu cầu. Slides nhóm không sửa.

# Mobile Final validation — 13/11/2026

Phạm vi: hoàn thiện mobile theo Final, AI và ARTEMIS được hoãn theo yêu cầu. Máy Windows, Flutter 3.47.4 / Dart 3.13.3.

| Kiểm tra | Kết quả quan sát |
|---|---|
| Mobile flutter analyze --no-pub lib test | Không có lỗi |
| Mobile flutter test --no-pub | 84/84 đạt; bao gồm role gate, scope announcement, PDF UID isolation, explicit sharing adapter, metadata retry, stale completion, existing Lab 2 states |
| Shared core tests | 3/3 đạt |
| Web tests sau khi chuyển service/component vào core | 23/23 đạt |
| Rules emulator | 11/11 đạt, project demo-direct-booking; không phải test trên dữ liệu production |
| Mobile APK debug | Build thành công; package assets font/icon dùng chung có trong APK |
| Web build | Build thành công; không deploy Hosting trong hạng mục mobile |
| Rules deploy | Firebase CLI deploy --only firestore:rules --project eventhub-group4 --non-interactive thành công, rules compiled và released |

## Chưa xác nhận, không được tính là pass

- App Check đăng ký app/debug token, Play Integrity và verified metrics/enforcement trên Console. Người dùng xác nhận chưa đăng ký/chưa rõ; code đã thêm provider.
- Native Android share sheet bằng thao tác thật. Test local kiểm tra file và adapter chia sẻ, không giả lập kết quả gửi sang ứng dụng khác.
- Cross-role trên hệ thống deploy 3 lần, đo độ trễ realtime và ảnh/video.
- Google login/role-change với tài khoản thật trên APK Final sau refactor; không lấy login Lab 3 làm bằng chứng cho phiên bản mới.
- AI và ARTEMIS Final chưa làm/chưa chạy lại theo yêu cầu; Figma chưa được chỉnh.

Source test fixtures chỉ nằm trong test/tool, không có mobile mock entrypoint hoặc dữ liệu sự kiện hard-coded trong service production. Giao diện runtime đọc Firestore; tài liệu lịch sử/ảnh Lab 3 không đại diện bằng chứng Final.

## Đợt chuẩn hóa mobile Final

- Suite mobile chạy lại: 84/84 đạt, gồm missing-event export phải báo lỗi để không tạo PDF thiếu dữ liệu.
- Kịch bản ARTEMIS sửa pending approval/PDF local/định danh màn; chưa chạy E2E Final.
- Tài liệu hiện hành bỏ hướng dẫn Cloudinary/upload/direct-confirm; slide nhóm và repo Lab 3 không sửa.

## Dọn repo theo Final

- Web analyze lib/test: không có lỗi sau chuyển test doubles ra web/lib.
- Web regression: 23/23 đạt sau bỏ mock entrypoints và toàn bộ HTTP bridge/polling trong fake tests.
- Không sửa slides/ hoặc Slide_Template_Spec_CamVangHong.md; không tác động repo Lab 3 hoặc dữ liệu Firebase cloud.
- Không xóa bằng chứng thật cũ; evidence/README phân loại kế thừa và Final. Không tính ảnh upload cũ thành local/share proof.
- Web production build `flutter build web --no-pub -t lib/main.dart` (kèm config local nếu có): thành công 114.7s sau dọn repo, không deploy.
- 55 liên kết tài liệu hiện hành được kiểm tra: 0 broken; launch chỉ Firebase main.dart; không bridge/mock trong runtime; slides không đổi.
- Cache/build sinh tự động ở gốc vẫn gitignored; lệnh dọn chúng bị automatic approval review chặn với lý do blocked by policy. Không ảnh hưởng cây source được theo dõi.

## Kiểm tra sau pull main e5b15a4

Mobile analyze sạch và84/84 test đạt; web analyze sạch nhưng22/23 tests đạt (Admin create assertion cũ fail); core3/3; Rules11/11 nhóm đạt qua emulator có sẵn8085, không deploy production. Các kết quả23/23 web bên trên là trước pull.

Finding còn mở: Admin form tạo vẫn readOnly, staff publish đi vào admin-only handler, dedup lịch bỏ qua generation/createdAt, tab lịch touch target dưới48dp. Xem docs/test-report.md. ARTEMIS mới vẫn skipped/client_error, không tính đã đạt.
