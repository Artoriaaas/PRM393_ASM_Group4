# Kế hoạch kiểm thử EventHub — Lab 3

Ngày 31/10/2026. Nguồn persona: Lab 2 `ux/persona.md`: P01 Nguyễn Minh Anh (sinh viên đăng ký/điểm danh), P02 Gia Linh (khách ngoài trường), P03 Việt Khoa (xem sự kiện tự do). Lab 3 thêm auth gate cho cả ba; không cấp quyền web CLB/admin cho mobile.

## Môi trường và trạng thái thực

- Android emulator API 35, Flutter tests với service inject và Firebase Firestore/Storage emulators riêng `demo-eventhub`.
- Cloud nhóm `eventhub-group4`: Google Sign-In chủ dự án xác nhận; Rules/indexes Firestore đã deploy qua CLI sau khi chủ dự án đăng nhập. Nghiệp vụ callable/Storage cloud chưa deploy vì chưa có quyết định billing; nguồn event/QR CLB thật còn chờ.
- ARTEMIS remote SDK pin commit `351ca8422f7b5b54e80a9c1ce03a222e02415b6b`; regression dùng Flash. `e2e_test` có 25 ca, Python 3.12.14 + pytest 8.4.2 đã collect được 25; kiểm tra khi thiếu host/account cho 25 skipped, **không phải 25 pass E2E**.
- Chưa có ARTEMIS_BASE_URL, host/model hoặc fixtures cloud đủ để chạy thiết bị. Thông tin nhạy cảm chỉ qua biến môi trường, không commit.

## Ma trận ca độc lập

Mỗi ca phải dùng tài khoản test riêng đã thêm vào Android; đưa app về trạng thái đầu phù hợp, không phụ thuộc ca trước. Các fixture state chỉ do backend/web CLB tin cậy chuẩn bị; agent không tự sửa quyền, ghi console hoặc tạo kết quả giả.

| ID | Flow / persona / màn | Tiền điều kiện và thao tác | Kết quả mong đợi |
|---|---|---|---|
| TC01 | Auth, cả ba, A01→A02 | Chọn Google test account trên native picker | Đăng nhập thật, mở A02 |
| TC02 | Auth, A01 | Mở rồi hủy native picker | Vẫn A01, thông báo hủy, không có phiên giả |
| TC03 | F1, P01/P02, A03 | Signed-in, tìm chuỗi không có kết quả | Empty + đổi/xóa bộ lọc |
| TC04 | F1, P01/P02, A02→A04 | Fixture event hợp lệ; tìm và mở | Đúng detail, giờ/địa điểm mới nhất |
| TC05 | F1, P01, A05 | Chưa đăng ký, event còn hạn/chỗ; bỏ khóa K | Lỗi tại K, dữ liệu khác giữ nguyên |
| TC06 | F1, P02, A05→A06 | Chưa active, khách nhập form hợp lệ không K | Server confirmed; không bắt thông tin sinh viên |
| TC07 | F2, P01/P02, A07 | Dữ liệu lịch chuẩn bị riêng; mở ba tab | Sắp tới/ended/cancelled rõ, free không vào lịch |
| TC08 | F2, A08 | Đăng ký active cancellable; dialog hủy→Giữ | Không hủy, trạng thái active giữ nguyên |
| TC09 | F2, A08→A07 | Active chưa check-in/chưa bắt đầu; xác nhận hủy | Backend cập nhật, hiện Đã hủy đăng ký |
| TC10 | F2, A09→detail | Có/không notification; mở rồi quay lại | Đã đọc và đúng đích hiện tại; empty vẫn dùng được |
| TC11 | A10/edit, cả ba | Google user; mở hồ sơ sửa | Name edit; email Google chỉ đọc và nhãn rõ |
| TC12 | F4A, P01/P02, A11 | Active reg, camera native quyền chưa cấp | Permission đúng; scanner, không điều khiển web CLB |
| TC13 | F4A, A12 | Backend/web đã ghi check-in fixture | Xem giờ gốc, không lộ email/điện thoại |
| TC14 | L3-02 | Lịch thật, Storage đã cấu hình | PDF có nội dung hiện tại, progress/URL hoàn tất |
| TC15 | L3-01/Remote Config | Có template đúng hai tham số | Fetch/activate, số lượng/hiện gợi ý tác động UI |
| TC16 | L3-01/FCM | Android13+, fixture thiết bị riêng | Native notification permission, trạng thái đúng |
| TC17 | Auth/logout | Đã đăng nhập, mở private data rồi logout/Back | A01, không hiện dữ liệu phiên cũ |
| TC18 | Analytics | Debug flag + FA log; fetch config | Event remote_config_fetch được ghi; cần thêm DebugView |
| TC19 | F1, P03, A04 free | Fixture free; xem giờ/địa điểm | Không có đăng ký/QR, đọc thông tin nhanh |
| TC20 | F1, A04 full | Chưa active; fixture đầy chỗ | Hết chỗ, không tạo đăng ký |
| TC21 | F1, A04 expired | Chưa active; server đã quá hạn | Hết hạn, không gửi mới |
| TC22 | F1/F2, A04 cancelled | CLB hủy fixture | Trạng thái và thông tin hiện tại; không đăng ký mới |
| TC23 | F1 recovery, A05 | Mạng test có thể ngắt trong request | Unknown giữ form/op ID; không suy ra thất bại/thành công |
| TC24 | F4A, A11 wrong event | QR khác sự kiện do web fixture hiển thị | Không ghi check-in; có quét lại |
| TC25 | F4A, A11 permission denied | Reset quyền camera trên thiết bị test | Từ chối có hướng dẫn Cài đặt và quay lại |

Unit/emulator tests còn kiểm tra cùng operation ID, request hash conflict, hai người tranh chỗ cuối, generation sau hủy/đăng ký lại, phiên đóng, QR không hợp lệ, registration inactive và server-owned timestamps. Chúng bổ sung chứ không thay E2E.

## Quy trình chạy và báo cáo

1. Chốt fixtures/cloud/host trước. Xem `e2e_test/README.md` cho biến môi trường và lệnh.
2. Chạy từng ca ≥3 lần độc lập; lưu command, trace/replay/screenshot thật trong `evidence/artemis`.
3. Lập bảng từng TC: pass/fail/skipped mỗi lần, pass rate, thời gian trung bình chỉ tính lần thực chạy, lý do flaky/fail/skip và link bằng chứng. Hiện chưa có bảng số liệu thực; không điền 100% từ unit tests.
4. Một phiên Pro 15–30 phút thật, script `explore.py` yêu cầu opt-in và ghi thời gian; chưa chạy hoặc tiêu phí model. Không kéo dài thời gian bằng sleep rồi gọi là exploration.
5. Dashboard proof riêng: từng analytics event DebugView, Crashlytics non-fatal từ nhánh lỗi thật + test crash, Remote Config trước/sau, FCM foreground/background/terminated, Storage console/file và Auth Users.
6. Sau sửa lỗi chạy lại ca liên quan, giữ bằng chứng cũ để truy vết. Chỉ kiểm tra layout mới tại 360/412dp, text150% và native thật; không lấy ảnh fixture làm bằng chứng cloud.
