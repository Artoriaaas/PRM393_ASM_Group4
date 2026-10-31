# Backend giao dịch EventHub — F1/F2/F4A

Ngày cập nhật: 31/10/2026. Project nhóm: `eventhub-group4`. Chủ dự án xác nhận Google Sign-In chạy thành công và đã tạo Firestore. Backend dưới đây đã được kiểm tra bằng emulator; **Firestore Rules/indexes đã deploy lên project nhóm; Functions/Storage chưa deploy và flow cloud chưa kiểm thử đầy đủ**.

## Đã có trong code

- `bookingCommand`: đăng ký, hủy, điểm danh; mỗi thao tác có operation ID cố định, request hash và transaction nguyên tử.
- `bookingStatus`: tra kết quả từ máy chủ. Không tìm thấy operation trả `unknown`, không coi là thất bại.
- Kiểm tra Auth + email verified, sức chứa, hạn/thời gian máy chủ, trạng thái sự kiện, chủ đăng ký và generation.
- QR là opaque token; backend so hash với `qrCredentials`, đối chiếu event và phiên mở. Mobile chỉ quét. CLB/admin thao tác trên web riêng; chưa có web CLB vận hành trong repo này.
- History giữ snapshot theo generation; đăng ký lại không ghi đè lịch sử cũ. Điểm danh lại giữ thời gian gốc.
- Notification trong app được tạo cùng transaction cho đăng ký/hủy/điểm danh. Đã có mã trigger FCM và thông báo đổi lịch/CLB hủy sự kiện; chưa deploy Functions nên chưa xác minh giao tin thật.
- Firestore Rules: chỉ người đã xác minh đọc sự kiện public; chủ tài khoản đọc đăng ký/thông báo; client không viết sức chứa/đăng ký/check-in/QR credentials. Đánh dấu read chỉ thay `readAt` bằng server timestamp.

## Chạy kiểm tra local (không cần billing)

Cần Node 22 cho môi trường tương ứng runtime deploy; máy tác giả chạy Node 24.21.0 (npm báo khác engine, test vẫn pass), Java 21 từ Android Studio. Backend dependencies pin trong `functions/package.json` và lockfile. Firebase CLI dùng 15.34.2.

```powershell
cd D:\Ky8\prmlab3
npm ci --prefix functions
npm test --prefix functions
npm exec --yes --package=firebase-tools@15.34.2 -- firebase emulators:exec --project demo-eventhub --only firestore "npm run test:integration --prefix functions"
```

`demo-eventhub` tách khỏi cloud nhóm; integration tests ghi/xóa dữ liệu chỉ trên emulator. Các dòng `PERMISSION_DENIED` trong ca rules là kết quả từ chối được mong đợi.

Seed tùy chọn chỉ khi emulator đang chạy: đặt `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080`, `GCLOUD_PROJECT=demo-eventhub`, chạy `npm run seed --prefix functions`. Script cố ý từ chối chạy nếu không có biến emulator. Dữ liệu này là fixture để kiểm tra, không phải dữ liệu CLB thật của bản nộp. Không reset emulator đang dùng để chia sẻ dữ liệu với người khác.

## Điều kiện trước khi chạy cloud

1. Chủ project xác minh gói Spark/Blaze và quyết định billing. Cloud Functions cần Blaze; Cloud Storage theo chính sách hiện tại cũng cần billing. Functions là lựa chọn kiến trúc bổ sung của EventHub, không phải một trong sáu dịch vụ bắt buộc của đề; Storage là yêu cầu của đề. Dòng “Spark plan is sufficient” trong đề cần đối chiếu chính sách Storage hiện hành với thầy nếu nhóm không có billing. Không bật gói/deploy thay chủ project khi chưa có quyết định.
2. Người deploy có quyền trên `eventhub-group4`; đăng nhập Firebase CLI bằng tài khoản đó. Không chia sẻ mật khẩu hoặc service-account key.
3. Database Standard và location đã được chủ dự án tạo. Functions chọn `asia-southeast1`; xác nhận region thực trước deploy.
4. Review Rules trước khi áp dụng lên một project đã có app/web khác. Rules hiện chưa cấp client organizer quyền ghi; web CLB phải dùng backend đáng tin cậy.
5. Chốt nguồn sự kiện thật được phép sử dụng. Người quản trị nhập từ web/backend/console; không nhúng dữ liệu mẫu vào app.

Sau khi các điều kiện trên được xác nhận, người deploy dùng:

```powershell
npm exec --yes --package=firebase-tools@15.34.2 -- firebase login
npm exec --yes --package=firebase-tools@15.34.2 -- firebase deploy --only firestore:rules,firestore:indexes,functions:eventhub --project eventhub-group4
flutter run -d emulator-5554 -t lib/main.dart
```

Chỉ Firestore Rules/indexes và Remote Config đã được deploy; các lệnh Functions/Storage dưới đây vẫn là hướng dẫn chưa thực hiện. Nếu không dùng được billing/dịch vụ bắt buộc, trao đổi với thầy theo đề trước khi chọn giải pháp tương đương. Emulator pass không thay bằng chứng console thật.

## Schema event thực tế

`events/{eventId}` (ID chỉ chữ/số/underscore/hyphen):

| Trường | Kiểu / ý nghĩa |
|---|---|
| visibility | string `public` để app query; không có quyền sửa từ mobile |
| status | string `published` hoặc `cancelled` |
| title, clubName, location, description | string, nội dung được CLB phê duyệt |
| startsAt, endsAt | Firestore Timestamp UTC, bắt buộc; UI hiển thị UTC+7 |
| registrationMode | `required` hoặc `free` |
| deadline | Timestamp bắt buộc với required |
| capacity, activeCount | integer; activeCount khởi tạo đúng dữ liệu hiện tại, chỉ backend cập nhật |
| topic, audience, preparation | string tùy chọn |
| activities | array of string |
| coverKey | `ux-workshop`/`acoustic` cho artwork Lab 2 tương ứng; bỏ trống dùng cover theo nội dung thật |

`registrations/{sha256(uid,eventId)}`: uid, eventId, generation, status, participant snapshot, createdAt, cancelledAt, checkInAt. Các thời điểm là Timestamp, không dùng chuỗi ngày tháng. `operations` và `history` chỉ do backend ghi; không xóa ledger đang có request in-flight.

## Kiểm tra trên cloud còn bắt buộc

- Xác minh Auth Users console, hủy picker, logout và hai tài khoản.
- F1 với dữ liệu CLB thật: tìm/lọc/empty/error/free/full/expired/cancelled, lỗi form, registration confirmed/existing, ngắt mạng và recovery.
- F2: hủy dialog, lịch chuyển sang Đã hủy, phân biệt CLB hủy sự kiện; thông báo đọc/đích hiện tại.
- F4A: quyền camera, mở Android Settings, QR thật do web CLB hiển thị, sai event/token/phiên đóng, lặp và recovery.
- Chụp app + dữ liệu console liên quan; không đưa dữ liệu cá nhân người khác vào ảnh nộp.

Nguồn API chính thức: https://firebase.google.com/docs/functions/callable ; https://firebase.google.com/docs/firestore/manage-data/transactions ; https://firebase.google.com/docs/firestore/security/rules-query .
