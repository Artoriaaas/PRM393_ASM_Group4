# Chạy thật toàn hệ thống Final — danh sách chốt sau main e5b15a4

Đây là kế hoạch xác nhận, không phải kết quả đã pass. Các lỗi source đã xác định đã được sửa; tiếp tục xác nhận trên cloud. Không thêm chức năng ngoài đề. Chủ dự án tự chạy app; agent đọc ảnh/log và sửa.

## 1. Cấu trúc

Đã có mobile/, web/, packages/core/, firebase/, e2e_test/, docs/, evidence/, report/, slides/. Hai client có main.dart Firebase; test doubles chỉ trong test/. Không custom server/Functions/Storage. Root firebase.json là config CLI, Rules/indexes ở firebase/; không cần di chuyển chỉ để đổi hình thức folder.

Giữ instrumentation Lab 3 vì Final kế thừa. PDF Final là local/native share + metadata Firestore. Giữ slide nhóm; report/slides/video phải chốt riêng theo đề. Cache/build gitignored không phải source.

## 2. Các lỗi source đã sửa — 13/11/2026

- S01: User chỉ xem published/public. Draft/pending/rejected giới hạn staff đúng CLB và Admin; staff không tự publish draft.
- W01–W03: Admin không tạo sự kiện. CLB chỉ tạo trong clubId phân công, gửi Admin duyệt. Bỏ fallback CLB đầu danh sách.
- W04: Sửa và gửi duyệt giữ coverKey/coverUrl.
- W05: Dashboard dùng Remote Config `web_dashboard_recent_limit` (4) và `web_dashboard_chart_limit` (5). Chỉ điều khiển trình bày, không điều khiển quyền.
- M01: Lịch/chi tiết/PDF chọn đăng ký canonical; fallback theo generation/thời gian, không ưu tiên approved cũ.
- M02: Tab lịch có vùng bấm >=48dp và tăng chiều cao theo cỡ chữ.

Analyze mobile/web sạch. Mobile 86/86; web 28/28; core 6/6; Rules emulator 12/12 nhóm đạt. Đây chưa phải bằng chứng chạy cloud liên ứng dụng.

## 3. Thiết lập trước chạy thật

- Một project eventhub-group4, ba tài khoản test: user mobile; staff có clubId trên web; admin web. Admin đầu tiên và danh sách demo cần chủ project xác nhận để ghi README; không gửi mật khẩu.
- Android config đã có local tại mobile/android/app/google-services.json; SHA/OAuth/Google provider phải đúng máy.
- **web/web_env.json đã có trên máy này**, lấy từ app EventHub Web của project qua Firebase CLI. File được Git bỏ qua; teammate lấy cấu hình riêng theo docs/firebase-setup.md. reCAPTCHA site key/App Check Console vẫn cần xác nhận.
- App Check Android debug token/Play Integrity và web reCAPTCHA site key/authorized domains cần xác nhận Console. Không bật enforcement khi một client chưa sẵn sàng.
- Rules/indexes đã deploy lên eventhub-group4 ngày 13/11/2026 sau kiểm thử emulator. Khi sửa tiếp, deploy từ ASM bằng tool/deploy-cloud.ps1. Không deploy Rules Lab 3 đè lên.
- Chuẩn bị ít nhất hai CLB để test chéo quyền; sự kiện mới do web tạo, published/public còn hạn và chỗ, clubId đúng. Không tự sửa activeCount/role từ mobile.

## 4. Mở app — chủ dự án chạy

Hai terminal riêng tại gốc ASM:

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter devices
flutter run -d emulator-5554 -t lib/main.dart
```

Thay emulator-5554 bằng thiết bị Android thật đang kết nối. Terminal web sau khi có config:

```powershell
cd web
flutter pub get --enforce-lockfile
flutter run -d chrome -t lib/main.dart --dart-define-from-file=web_env.json
```

Đây là hai client local dùng Firebase thật, chưa phải bằng chứng web deployment. Trước đo cross-role chính thức phải build/deploy Hosting và mở private window. Giữ terminal để gửi log lỗi, không đóng trong lúc test.

## 5. Thứ tự chạy một đợt

| Bước | Thao tác | Mong đợi / bằng chứng |
|---|---|---|
| 1 Auth/role | Login Google user mobile; user thử web; staff/admin thử mobile; cancel/login/logout/Back | Đúng role gate, lỗi có phản hồi; không mở dữ liệu private sai role |
| 2 Admin/staff web | Admin phân staff+CLB; staff tạo/sửa/gửi đề xuất; Admin duyệt hoặc từ chối, tìm kiếm và archive | Dữ liệu Firestore thật; sửa không mất cover; CLB khác bị chặn |
| 3 Mobile khám phá | Tìm sự kiện vừa publish, detail, search empty, Back/4tabs | Mới nhất và đúng nội dung; loading/empty/error/retry |
| 4 Pending | User gửi form guest/student | Pending, chưa QR/chưa giảm count; web queue nhận |
| 5 Review | Staff reject có lý do, user xem; gửi lại rồi approve | Mobile realtime/lý do/inbox; approved chiếm1 chỗ; không tự approve từ mobile |
| 6 Hủy/recovery | Hủy pending rồi approved theo điều kiện; ngắt mạng khi gửi và kiểm tra trạng thái | Count đúng, không trùng thao tác, lịch không chọn record cũ |
| 7 QR | Web mở/đóng/xoay QR; user approved quét; thử sai mã/chưa approved/quét lặp | Camera permission đúng; checkInAt server giữ gốc; web count cập nhật |
| 8 Announcements | Staff đăng club/event; admin global; đọc và đổi UID | Mobile inbox đúng scope, read receipt riêng, không lộ tin UID khác |
| 9 Dashboard | Xem ≥3 aggregation figures+chart; thay dữ liệu rồi refresh | Số liệu đối chiếu Firestore; loading/empty/error rõ |
| 10 PDF | Tạo và lưu, chia sẻ Android, thử mất mạng metadata rồi retry | PDF khớp preview; metadata UID-only; không upload/public URL; file giữ khi metadata lỗi |
| 11 Instrumentation | RC hai tham số mobile và web; Analytics trigger; FCM foreground/background/terminated; lỗi thật + test crash | Console/event params/keys/UID và ảnh trước-sau thật. Test crash chỉ trên thiết bị test |
| 12 Privacy/UI | Logout, UID khác; role đổi;360/412dp và chữ lớn | Không lộ lịch/inbox/file phiên trước; UI không tràn/cắt; traceability/Figma ghi đúng thay đổi |

Mỗi lỗi gửi: bước/role/màn, thao tác, ảnh hoặc log và kết quả mong đợi. Không cần gửi key/token. Sửa xong chạy lại bước lỗi và bước phụ thuộc, không phải làm lại mọi thứ vô điều kiện.

## 6. Còn thiếu để nộp, không thể giải quyết chỉ bằng test thủ công

- AI Gemini qua Firebase AI Logic chưa có; đề cho phép ở web hoặc mobile. Cần RC model/prompt/flag, App Check, no PII, JSON/Dart+confirm để đạt full,3 input/output thật+1 failure,3 events và demo RC off. Không thêm server.
- ARTEMIS mới:25ca×3 đều skipped do thiếu ARTEMIS_BASE_URL và ARTEMIS_TEST_ACCOUNT_EMAIL; có client_error NetworkError. Chưa có Final pass; cần cross-role/AI coverage và3 lượt thực mỗi ca.
- Cross-role trên deployment3 lần và measured latency; web checklist ảnh từng main action/error/empty; Console App Check/instrumentation Final.
- Matrix Rules allowed/denied từng role/collection còn phải chốt;11 nhóm test không đồng nghĩa đủ matrix. Bổ sung test cho các lỗi vừa tìm thấy.
- Code review mới cần đóng findings và có fix commits/bằng chứng; phần sửa local hiện chưa commit/push.
- README còn thiếu Admin đầu tiên/demo accounts/URL verified/video/ID theo mẫu đề; kiểm tra lịch sử Git tiếp nối Lab3 và đóng góp nhóm.
- Report Final10–15 trang, slides12–15, video live8–12 phút chưa chốt. Slide nhóm giữ nguyên, phải đối chiếu riêng độ dài/số liệu thực. Figma chưa xác nhận đồng bộ hết.

Chi tiết nguồn: docs/final-requirements.md, docs/test-report.md; đề PDF Final ở gốc repo. Không đánh dấu hoàn thành vì build/unit pass hoặc có tài liệu placeholder.
