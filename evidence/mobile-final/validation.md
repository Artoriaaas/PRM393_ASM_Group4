# Mobile Final validation — 13/11/2026

Phạm vi: hoàn thiện mobile theo Final, AI và ARTEMIS được hoãn theo yêu cầu. Máy Windows, Flutter 3.47.4 / Dart 3.13.3.

| Kiểm tra | Kết quả quan sát |
|---|---|
| Mobile flutter analyze --no-pub lib test | Không có lỗi |
| Mobile flutter test --no-pub | 83/83 đạt; bao gồm role gate, scope announcement, PDF UID isolation, explicit sharing adapter, metadata retry, stale completion, existing Lab 2 states |
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
