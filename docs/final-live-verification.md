# Chạy thật để chốt 5 mục Final

Source hiện đã có. Không ghi pass chỉ từ config, unit test hoặc Hosting HTTP200. Làm theo thứ tự; gửi ảnh/log của bước lỗi, không gửi API key/token/secret. AI dùng hạn mức chung project: mỗi lần Gợi ý/Tạo lại là 1 yêu cầu, xem trước/áp dụng/lưu không gọi AI.

## 1. Bản chạy cố định trên điện thoại thật

Từ gốc repo, build trên máy nhóm (agent không tự build/cài Android):

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter build apk --release -t lib/main.dart
```

APK: mobile/build/app/outputs/flutter-apk/app-release.apk. Cài đè bản cũ bằng cùng khóa ký nhóm, không xóa dữ liệu điện thoại. Release dùng Play Integrity; không cần App Check debug token. Web: https://eventhub-group4.web.app, chờ workflow của commit mới nhất thành công rồi tải lại. Kiểm tra user mobile, staff đúng clubId và Admin riêng; không nâng user lên Admin để vượt lỗi.

Chỉ dùng USB nếu nhóm muốn chiếu màn hình/chạy ARTEMIS; APK cài bằng file vẫn kết nối cùng Firestore với web. Nếu chạy debug để sửa lỗi thì dùng device ID của điện thoại thật và đăng ký debug token riêng, không dùng emulator làm bằng chứng Final theo yêu cầu giảng viên của nhóm.

## 2. Xác nhận cloud trước khi bật enforcement Firestore

Chạy tại gốc:

```powershell
node tool/check-cloud.cjs
```

Đọc timestamp và kết quả trong evidence/cloud-readiness/config-status.json. Lần kiểm tra 14/11 đã thấy Android Firestore VALID và web AI Logic VALID. Chưa có hàng Firestore web VALID trong cửa sổ quan sát, nên chưa bật enforcement Firestore. Registered không thay thế request thực tế. Mở web thực hiện đọc dữ liệu, kiểm tra lại; chỉ bật khi hai client dự định nộp đều có request hợp lệ, sau đó thử lại.

AI Logic đang ENFORCED; không tắt để vượt lỗi. Release dùng Play Integrity, debug provider chỉ dùng bản debug. Kiểm tra cloud không gọi Gemini hoặc ghi dữ liệu nghiệp vụ.

## 3. AI — 3 kết quả thật, một lỗi và RC-off

Trên web staff → Sự kiện → Tạo/sửa sự kiện → nhập Ý tưởng cần AI hỗ trợ (chỉ mô tả hoạt động chung, không tên người/thông tin cá nhân):

1. Workshop Flutter và Firebase → Gợi ý → chụp bản xem trước → Áp dụng → chỉnh lại một câu. Chưa bắt buộc lưu nếu chỉ kiểm tra AI.
2. Workshop thiết kế UI/UX → lặp lại, chụp JSON/output thể hiện trên UI và Analytics.
3. Giao lưu âm nhạc → lặp lại.

Nếu lỗi: chụp nguyên thông báo; không bấm liên tục. Ý tưởng là input người dùng; chỉ output Gemini thật mới được tính. Không gửi tên thật để kiểm tra bộ lọc: dùng dữ liệu giả cho kiểm thử local, không ghi thông tin cá nhân vào ảnh/Analytics. Lưu model/RC version và evidence vào docs/ai-feature.md.

Lỗi thực tế: sau khi mở form, ngắt mạng trên máy test rồi yêu cầu AI; ghi thông báo lỗi/form còn nguyên, bật mạng lại. Đây là lỗi kết nối, không gán là quota nếu không có bằng chứng. Để thử Remote Config tắt không tốn lượt model: Firebase Console → Remote Config → ai_feature_enabled=false → Publish. Trên form bấm Gợi ý, phải thấy AI tắt và vẫn nhập/sửa/lưu form bình thường. Sau chụp ảnh đổi true và Publish trở lại. Không đổi model/prompt hoặc các tham số khác khi không cần.

Analytics DebugView cho web: bật Google Analytics Debugger extension trong Chrome, tải lại trang Hosting và mở Firebase Analytics > DebugView; cần session debug hợp lệ của trình duyệt. Nếu chưa xuất hiện event, báo để bật debug cho session; không suy từ Console version rằng ai_request đã xảy ra. Cần ai_request, ai_result_accepted (khi Áp dụng) và ai_error (RC off/lỗi). Không gửi prompt/PII vào Analytics.

## 4. Cross-role — 3 lượt trên deployment

CLB tạo một sự kiện required, còn hạn/chỗ, thời gian tương lai → gửi Admin → Admin phê duyệt. Quay mobile và web cùng lúc.

Mỗi lượt:

1. User mở sự kiện → Đăng ký → Xác nhận. Mobile pending; web CLB Review Queue phải nhận đơn, chưa chiếm chỗ.
2. CLB phê duyệt. Mobile Lịch/Chi tiết và Thông báo cập nhật; activeCount tăng1, đã approved mới được quét QR.
3. Ghi thời gian từ thao tác phía gửi đến cập nhật phía nhận bằng video/stopwatch; nêu sai số, không nhận millisecond chính xác nếu đo bằng tay.
4. Để lặp với cùng account, user tự hủy đăng ký còn điều kiện, kiểm tra count giảm1 rồi đăng ký lại. Hoặc dùng tài khoản test khác; không xóa record hay sửa count trong Console để tạo pass.

Thực hiện đủ 3 lượt, điền docs/cross-role-flow.md (có cột đường dẫn evidence và độ trễ). Tin CLB/admin tạo trong Announcement form phải xuất hiện mobile inbox đúng scope. Chụp ảnh/tin và trạng thái đã đọc.

## 5. Kiểm tra chức năng/states và lưu bằng chứng

- Web sign-in: user bị chặn; staff/admin đúng role. Management: list/search/create/edit/archive (CLB tạo, Admin duyệt). Review: approve và reject có lý do. Dashboard: đối chiếu >=3 số tổng hợp và chart. Announcement: đăng và đọc ở mobile.
- Mobile: auth/Back/logout; khám phá/search/detail; free/full/expired/cancelled; form validation; pending/rejected/resubmit/approved/cancel; QR permission/sai QR/quét lặp; profile; PDF local/native share + metadata UID-only; inbox.
- Empty: dùng từ khóa không tồn tại hoặc tài khoản mới chưa đăng ký; không seed fake trong app.
- Loading: ghi lại lúc tải thật; mạng chậm từ công cụ test nếu cần, không thay bằng ảnh fixture.
- Error/retry: ngắt mạng trên thiết bị test, thử thao tác cần server như gửi đăng ký/lưu metadata, phục hồi mạng và thử lại. Firestore có thể giữ snapshot trong RAM nên ngắt mạng không nhất thiết lập tức hiện error; không gọi snapshot cũ là bug hoặc tự chế ảnh lỗi.
- FCM ba trạng thái, Crashlytics, RC/Analytics cả hai client: giữ bằng chứng Console gắn bản Final; ảnh Lab3 không tự chứng minh binary Final.

Bảng bằng chứng: evidence/final-live/README.md. Chỉ chuyển từ Chưa chạy sang Đạt khi thực hiện và lưu file thật. Các test Rules tại docs/security-rules-matrix.md đã hoàn tất tự động; không cần tự thao tác từng Rule trên production.
