# Kế hoạch kiểm thử EventHub — Final

Ngày 31/10/2026. Nguồn persona: Lab 2 `ux/persona.md`: P01 Nguyễn Minh Anh (sinh viên đăng ký/điểm danh), P02 Gia Linh (khách ngoài trường), P03 Việt Khoa (xem sự kiện tự do). Lab 3 thêm auth gate cho cả ba; không cấp quyền web CLB/admin cho mobile.

## Môi trường và trạng thái thực

- Android emulator API 35, Flutter tests với service inject và Firestore Rules emulator.
- Cloud dùng chung `eventhub-group4`; mobile chỉ role user. Staff/admin thao tác trên web. Cấu hình App Check và chạy cloud cần xác nhận, không suy từ kết quả Lab 3.
- ARTEMIS pin `351ca8422f7b5b54e80a9c1ce03a222e02415b6b`; regression Flash. Chưa chạy lại suite Final, không tính collect/skipped là pass.
- PDF lưu/chia sẻ trên thiết bị, metadata Firestore; không Cloudinary, Storage, Functions hay custom server.

## Ma trận ca độc lập

Mỗi ca phải dùng tài khoản test riêng đã thêm vào Android; đưa app về trạng thái đầu phù hợp, không phụ thuộc ca trước. Các fixture state chỉ do backend/web CLB tin cậy chuẩn bị; agent không tự sửa quyền, ghi console hoặc tạo kết quả giả.

| ID | Flow / persona / màn | Tiền điều kiện và thao tác | Kết quả mong đợi |
|---|---|---|---|
| TC01 | Auth, cả ba, A01→A02 | Chọn Google test account trên native picker | Đăng nhập thật, mở A02 |
| TC02 | Auth, A01 | Mở rồi hủy native picker | Vẫn A01, thông báo hủy, không có phiên giả |
| TC03 | F1, P01/P02, A03 | Signed-in, tìm chuỗi không có kết quả | Empty + đổi/xóa bộ lọc |
| TC04 | F1, P01/P02, A02→A04 | Fixture event hợp lệ; tìm và mở | Đúng detail, giờ/địa điểm mới nhất |
| TC05 | F1, P01, A05 | Chưa đăng ký, event còn hạn/chỗ; bỏ khóa K | Lỗi tại K, dữ liệu khác giữ nguyên |
| TC06 | F1, P02, A05→A06 | Chưa active, khách nhập form hợp lệ không K | Firestore tạo pending, màn Chờ duyệt; không bắt thông tin sinh viên, chưa giảm count |
| TC07 | F2, P01/P02, A07 | Dữ liệu lịch chuẩn bị riêng; mở ba tab | Sắp tới/ended/cancelled rõ, free không vào lịch |
| TC08 | F2, A08 | Đơn pending/approved có thể hủy; dialog hủy→Giữ | Không hủy, trạng thái đơn giữ nguyên |
| TC09 | F2, A08→A07 | Pending hoặc approved chưa check-in/chưa bắt đầu; xác nhận hủy | Pending giữ count; approved giảm count nguyên tử, hiện Đã hủy đăng ký |
| TC10 | F2, A09→detail | Có/không notification; mở rồi quay lại | Đã đọc và đúng đích hiện tại; empty vẫn dùng được |
| TC11 | A10/edit, cả ba | Google user; mở hồ sơ sửa | Name edit; email Google chỉ đọc và nhãn rõ |
| TC12 | F4A, P01/P02, A11 | Đơn approved bởi web, phiên QR mở, camera chưa cấp quyền | Permission đúng; scanner, không điều khiển web CLB |
| TC13 | F4A, A12 | Web CLB tạo QR/phiên; app ghi check-in | Xem giờ gốc, không lộ email/điện thoại |
| TC14 | LAB3_EXPORT | Có đăng ký Firestore | PDF khớp preview, lưu local, metadata owner-only và mở native share sheet theo thao tác |
| TC15 | LAB3_FIREBASE/Remote Config | Có template đúng hai tham số | Fetch/activate, số lượng/hiện gợi ý tác động UI |
| TC16 | LAB3_FIREBASE/FCM | Android13+, fixture thiết bị riêng | Native notification permission, trạng thái đúng |
| TC17 | Auth/logout | Đã đăng nhập, mở private data rồi logout/Back | A01, không hiện dữ liệu phiên cũ |
| TC18 | Analytics | Debug flag + FA log; fetch config | Event remote_config_fetch được ghi; cần thêm DebugView |
| TC19 | F1, P03, A04 free | Fixture free; xem giờ/địa điểm | Không có đăng ký/QR, đọc thông tin nhanh |
| TC20 | F1, A04 full | Chưa active; fixture đầy chỗ | Hết chỗ, không tạo đăng ký |
| TC21 | F1, A04 expired | Chưa active; server đã quá hạn | Hết hạn, không gửi mới |
| TC22 | F1/F2, A04 cancelled | CLB hủy fixture | Trạng thái và thông tin hiện tại; không đăng ký mới |
| TC23 | F1 recovery, A05 | Mạng test có thể ngắt trong request | Unknown giữ form/op ID; không suy ra thất bại/thành công |
| TC24 | F4A, A11 wrong event | QR khác sự kiện do web fixture hiển thị | Không ghi check-in; có quét lại |
| TC25 | F4A, A11 permission denied | Reset quyền camera trên thiết bị test | Từ chối có hướng dẫn Cài đặt và quay lại |

Unit/emulator tests cũ của Functions chỉ là lịch sử thử nghiệm, không còn chứng minh kiến trúc hiện tại. Firestore Rules emulator đã kiểm tra register/cancel nguyên tử, chặn ghi count riêng lẻ và QR giả, cho QR hợp lệ một lần. Cần bổ sung E2E cạnh tranh hai tài khoản, re-register và recovery trên cloud.

## Quy trình chạy và báo cáo

1. Chốt fixtures/cloud/host trước. Xem `e2e_test/README.md` cho biến môi trường và lệnh.
2. Chạy từng ca ≥3 lần độc lập; lưu command, trace/replay/screenshot thật trong `evidence/artemis`.
3. Lập bảng từng TC: pass/fail/skipped mỗi lần, pass rate, thời gian trung bình chỉ tính lần thực chạy, lý do flaky/fail/skip và link bằng chứng. Hiện chưa có bảng số liệu thực; không điền 100% từ unit tests.
4. Một phiên Pro 15–30 phút thật, script `explore.py` yêu cầu opt-in và ghi thời gian; chưa chạy hoặc tiêu phí model. Không kéo dài thời gian bằng sleep rồi gọi là exploration.
5. Dashboard proof riêng: từng analytics event DebugView, Crashlytics non-fatal từ nhánh lỗi thật + test crash, Remote Config trước/sau, FCM foreground/background/terminated, PDF local/native share và metadata Firestore và Auth Users.
6. Sau sửa lỗi chạy lại ca liên quan, giữ bằng chứng cũ để truy vết. Chỉ kiểm tra layout mới tại 360/412dp, text150% và native thật; không lấy ảnh fixture làm bằng chứng cloud.

## Xác nhận riêng cho Final

- Mobile tạo pending, không tự chuyển approved. Staff duyệt/từ chối trên web; mobile hiện lý do và cập nhật realtime. Thực hiện trên deployment 3 lần, lưu bằng chứng và thời gian ở docs/cross-role-flow.md.
- Web tạo announcement all/club/event; kiểm tra đúng phạm vi, đọc tin và đổi tab đúng; user khác không đọc tin riêng.
- Đăng nhập user/staff/admin; mobile chỉ cho user vào dữ liệu riêng, role đổi khi đang chạy phải bị chặn.
- PDF: empty/error/retry; tạo local; metadata fail giữ file và retry cùng ID; share sheet; logout không lộ file/preview tài khoản trước.
- App Check: đăng ký Android debug token ở Console, xác nhận verified request; phối hợp web trước enforcement. Không commit token.
- Giữ các mã analytics LAB3_EXPORT/LAB3_FIREBASE để không đứt đối chiếu lịch sử; chức năng hiện hành tuân thủ Final.
- ARTEMIS: cần bổ sung ca liên vai trò có người chạy web chuẩn bị độc lập và ca AI khi tính năng AI được triển khai; chưa tuyên bố đủ coverage Final.
