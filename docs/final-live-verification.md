# Chạy thật để chốt 5 mục Final

Source hiện đã có. Không ghi pass chỉ từ config, unit test hoặc Hosting HTTP200. Làm theo thứ tự; gửi ảnh/log của bước lỗi, không gửi API key/token/secret. AI dùng hạn mức chung project: mỗi lần Gợi ý/Tạo lại là 1 yêu cầu, xem trước/áp dụng/lưu không gọi AI.

## 1. Mở mobile và web

Terminal tại gốc ASM:

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter devices
flutter run -d emulator-5554 -t lib/main.dart
```

Thay device ID theo flutter devices. Máy thật Android dùng USB debugging; bản debug dùng App Check debug provider. Không cần xóa tài khoản hay dữ liệu điện thoại. Web chạy thật: https://eventhub-group4.web.app, Ctrl+F5 rồi đăng nhập staff/admin. Key Enterprise hiện chỉ cho hai domain Hosting, không dùng localhost để chốt AI/App Check.

Cần 3 role: user mobile; staff có clubId được phân công; admin web. Không cấp role admin cho tài khoản user chỉ để vượt lỗi.

## 2. App Check Android — cần làm trước enforcement Firestore

Hiện chưa có debug token Android đăng ký. Mở app debug, đăng nhập user để có kết nối Firebase. Terminal khác tại gốc ASM:

```powershell
node tool/register-android-appcheck.cjs emulator-5554
```

Lệnh đọc debug secret từ log của đúng tiến trình com.eventhub.app và đăng ký thiết bị test vào project chung. Không mở/đóng app, không in/lưu secret, không dùng token này cho release. Nếu không thấy token, khởi động app lại bằng thao tác của bạn rồi thử lại. Sau đăng ký, khởi động lại app bình thường và mở Khám phá/Lịch.

Sau khi mở web và mobile thực tế, chạy:

```powershell
node tool/check-cloud.cjs
```

Kết quả cập nhật evidence/cloud-readiness/config-status.json. Cần request hợp lệ từ cả Web và Android, không chỉ cấu hình registered. Monitoring có thể cập nhật chậm. Gửi kết quả đã lọc này để chốt enforcement Firestore; không bật khi mobile chưa được xác minh. Release APK dùng Play Integrity, cần xác nhận riêng trên thiết bị/bản phân phối dự định nộp.

AI Logic đã ENFORCED theo cấu hình service firebaseml.googleapis.com (định danh App Check của Firebase AI Logic); Firestore hiện UNENFORCED. Không hạ enforcement AI để vượt lỗi.

## 3. AI — 3 kết quả thật, một RC-off

Trên web staff → Sự kiện → Tạo/sửa sự kiện → chọn Chủ đề gửi AI:

1. Workshop Flutter và Firebase → Gợi ý → chụp bản xem trước → Áp dụng → chỉnh lại một câu. Chưa bắt buộc lưu nếu chỉ kiểm tra AI.
2. Workshop thiết kế UI/UX → lặp lại, chụp JSON/output thể hiện trên UI và Analytics.
3. Giao lưu âm nhạc → lặp lại.

Nếu lỗi: chụp nguyên thông báo; không bấm liên tục. Nội dung định sẵn được chọn làm input không phải output giả: chỉ kết quả thật từ Gemini mới tính bằng chứng. Lưu model/RC version và evidence vào docs/ai-feature.md.

Để thử fallback không tốn lượt model: Firebase Console → Remote Config → ai_feature_enabled=false → Publish. Trên form bấm Gợi ý, phải thấy AI tắt và vẫn nhập/sửa/lưu form bình thường. Sau chụp ảnh đổi true và Publish trở lại. Không đổi model/prompt hoặc các tham số khác khi không cần.

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
