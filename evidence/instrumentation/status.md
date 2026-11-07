# Instrumentation evidence — 07/11/2026

Trạng thái hiện tại sau kiểm thử Android do người dùng thao tác và agent lưu ảnh. Ảnh gốc nằm trong các thư mục dưới đây; không tạo kết quả Console giả. Các kết quả trước khi khôi phục Console không còn là trạng thái hiện tại.

| Hạng mục | Đã xác minh | Còn thiếu |
|---|---|---|
| Remote Config | Console và app: limit 1/true → ẩn gợi ý với false → khôi phục 10/true; fetch trên app đang chạy | Không dùng Fetch % = 0 làm bằng chứng Analytics |
| Analytics | 8 tên event trên DebugView; 7 event có tham số riêng đã mở | view_screen chưa mở tham số; các event còn lại trong analytics-plan chưa có đủ ảnh |
| Crashlytics | Native test crash, manual non-fatal, lỗi upload thực report_upload_failed; User ID và app_flow=eventhub | Không suy ra lỗi unhandled_platform_error cũ đã được sửa |
| FCM | Foreground, background và terminated: nhận tin, lưu inbox; chạm tin mở tab Thông báo đúng | Tin Console chung chưa xác minh deep link tới sự kiện cụ thể, trạng thái đã đọc hoặc hộp thoại quyền lần đầu |

## Remote Config

Ảnh tại [remote-config/](remote-config/): baseline-console.png (10/true); limit-1-console-and-app.png (Version 2, 1/true, một thẻ); recommendations-false-console.png (Version 3, false); recommendations-hidden-app.png (ẩn thẻ, giữ tiêu đề và lời giải thích); restored-10-true-console-and-app.png (Version 5, nhiều thẻ). Người dùng fetch trong app đang chạy, không yêu cầu rebuild trong chuỗi thử này. Baseline app được bổ sung bằng ảnh khôi phục sau thử.

## Analytics

Ảnh tại [analytics/](analytics/). Property eventhub-group4 trên Google Analytics DebugView đã hiển thị event; trang nhúng Firebase Console trước đó trống. Không dùng lời gọi SDK hoặc HTTP 204 thay cho bằng chứng DebugView.

| Event | Tham số nhìn thấy trong ảnh |
|---|---|
| search | query_length=8 |
| view_event_detail | screen_code=A04 |
| view_registration_detail | screen_code=A08 |
| booking_submit | action=register |
| booking_result | action=register; result=confirmed |
| export_generate | row_count=2 |
| export_upload | byte_count=13803 |
| view_screen | Có trên timeline/overview; chưa mở giá trị tham số |

Log đã lọc chỉ event nghiệp vụ và upload response: analytics-search-detail-logcat.txt. Không lưu raw log chứa token/định danh thiết bị vào file này. Các ảnh gốc có thể chứa tài khoản test và UID; cần rà dữ liệu cá nhân trước khi dùng trong bài trình bày công khai.

## Crashlytics

Ảnh tại [crashlytics/](crashlytics/):

- native-test-crash-dashboard.png, test-crash-user-and-time.png, test-crash-custom-keys.png: FirebaseCrashlyticsTestCrash lúc 06:28:18, UID có giá trị, app_flow=eventhub.
- nonfatal-dashboard.png, nonfatal-custom-keys.png, nonfatal-user-and-time.png: manual_non_fatal_test riêng, lúc 06:28:00.
- real-upload-error-app.png và real-upload-error-{dashboard,custom-keys,user-and-time}.png: thao tác upload PDF khi offline được xử lý, app không đóng; Console nhận report_upload_failed lúc 06:38:45 (bốn event, một user), có UID/key.
- crashes-dashboard.png là ảnh đầu tiên chỉ thấy unhandled_platform_error cũ; không phải bằng chứng native test crash và không xác nhận lỗi cũ đã được xử lý.

## FCM và các bản sửa đã kiểm thử

Ảnh tại [fcm/](fcm/):

- foreground-console-and-receipt.png, foreground-inbox.png: app đang mở có snackbar và lưu tin.
- background-system-notifications.png: thông báo chạy nền hiển thị trong notification shade.
- background-open-inbox-before-tab-fix.png: lỗi tab Khám phá vẫn được chọn khi mở Thông báo từ push.
- background-open-inbox-tab-fixed.png: sau sửa router.go cho /notifications, tab Thông báo được chọn và có lịch sử.
- terminated-system-notification.png, terminated-open-inbox.png: trước gửi đã Home + am kill và pidof không còn process; không force-stop. Tin app đóng hiển thị và chạm mở đúng inbox. Body còn câu chạy nền từ composer trước; tiêu đề và trạng thái tiến trình trước gửi phân biệt ca.

Sửa adapter: dùng getToken/onTokenRefresh/deleteToken để tương thích FCM token của Console thay vì chờ onRegistered trả installation FID. Các API cũ còn được hỗ trợ trong SDK khóa 17.0.1 nhưng deprecated; scoped ignores ghi rõ lựa chọn tương thích. Field Firestore fid được giữ theo schema/Rules hiện có, chứa FCM token, không phải document ID. Không đăng token vào bằng chứng. Có guard token rỗng và đổi phiên đăng nhập.

Lỗi môi trường emulator: device_provisioned=0 và user_setup_complete=0 khiến DeviceProvisionedCoordinator lọc tất cả thông báo. Đã đặt hai giá trị về 1; ảnh notification shade sau sửa xác nhận hiển thị. Không thay quyền tài khoản cloud.

Validation: flutter analyze sạch; 5 cloud_features tests qua sau sửa token; APK debug build/install thành công. Sửa tab tiếp theo cũng analyze/build thành công và được người dùng xác minh bằng ảnh.

## Các mục tách biệt chưa hoàn thành

ARTEMIS chưa có bộ regression đạt. Cloudinary tạo/upload PDF đã chạy thật nhưng URL public chưa đạt owner-only/per-user access. Ảnh export còn lịch sử sự kiện có chữ (Mẫu); cần giải quyết dữ liệu cũ. Các ảnh này không chứng minh toàn bộ Lab 3 hoàn tất.
