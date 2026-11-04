# Kế hoạch thực hiện EventHub — Lab 3

Ngày lập: 30/10/2026. Nguồn: đề PDF Lab 3 gồm 18 trang, mục 3–11 và phụ lục A–C. Các lựa chọn áp dụng riêng cho EventHub dưới đây là đề xuất triển khai, không phải yêu cầu nguyên văn của thầy.

## Cách làm để không bị rối

Cập nhật theo ưu tiên của nhóm ngày 31/10/2026: dựng trước [UI prototype tương tác](docs/ui-prototype.md) để chia việc cho teammate. Đây là công việc frontend song song; các bước 4–9 chỉ hoàn thành khi đã nối dịch vụ thật và có bằng chứng. Không dùng state demo thay cho yêu cầu dữ liệu thật của bản nộp.

Làm lần lượt 12 bước. Chỉ đánh dấu xong khi có đầu ra và đã đạt điều kiện kiểm tra; hoàn thành code không đồng nghĩa đã có bằng chứng. Mỗi đợt làm lưu commit có ý nghĩa, ảnh/log vào `evidence/` và cập nhật README. Không dồn Git thành một lần upload cuối. Giữ thiết kế và app đồng bộ qua `docs/design-traceability.md`.

## 1. Đối chiếu Lab 2 và chốt phạm vi triển khai

**Làm:** đọc Final UI, Prototype, persona, user-flow, screen-spec và handoff đã chốt. Lập bảng từng màn A01–A12 (kể cả biến thể A01a–d), từng flow F1/F2/F4A và từng component → route Flutter → widget → nguồn dữ liệu → trạng thái thực hiện. Bao phủ mọi màn trên Final UI, không dừng ở 8 màn nếu thiết kế có nhiều hơn.

Ghi thay đổi bắt buộc của Lab 3: bổ sung Google Sign-In và điều hướng theo phiên; không tự xóa đăng nhập email/mật khẩu khi chưa có quyết định. Ghi cách xử lý truy cập khách của Lab 2 vì rubric Lab 3 chặn người chưa đăng nhập vào màn app. Bổ sung khu demo Firebase, xuất/upload file vào thiết kế; mọi thay đổi cần lý do và cập nhật Figma.

**Đầu ra:** `docs/design-traceability.md`, danh sách quyết định thay đổi và Figma tương ứng.

**Xong khi:** mỗi màn/flow/component đều có dòng đối chiếu; các khác biệt đã được ghi rõ. Đây là bước thực hiện tiếp theo.

## 2. Thiết kế kiến trúc, dữ liệu và theme

**Làm:** chọn MVVM + Provider hoặc Riverpod (đề xuất Riverpod). Tách View, ViewModel, service, model; mọi SDK/API đi qua service, được inject. Mỗi màn tải dữ liệu có state loading/empty/error/data. Logic không nằm trong `build()`.

Đề xuất EventHub dùng Firestore cho sự kiện, đăng ký, trạng thái phiên điểm danh và thông báo. Chốt quyền đọc/ghi, chống đăng ký trùng, sức chứa và thời gian theo máy chủ. Xác định cách CLB trên web riêng cập nhật sự kiện/mở phiên/hiển thị QR; mobile chỉ quét, không có quyền quản trị web. Chuẩn bị nguồn sự kiện thật và cách cấp dữ liệu cho demo.

Lập mapping token → `ThemeData` và component → widget; màu, chữ, spacing, radius, elevation tập trung tại `lib/theme/`.

**Đầu ra:** `docs/architecture.md` gồm cấu trúc thư mục, sơ đồ lớp, một sequence diagram trọn flow, bảng ViewModel–service và thiết kế dữ liệu/quyền.

**Xong khi:** kiến trúc và nguồn dữ liệu đủ rõ để triển khai; chưa cần viết tính năng trước khi tài liệu này xong.

## 3. Chuẩn bị môi trường và nền ứng dụng

**Làm:** tạo project Flutter Android, Git/repo, ghi phiên bản Flutter/Dart/packages; dựng theme, widget dùng lại và routing theo tài liệu. Kiểm tra sớm Android/ADB, Python 3.12+, uv và khả năng dùng API model cho ARTEMIS để phát hiện trở ngại công cụ.

**Đầu ra:** project chạy được trên Android, cấu trúc MVVM, theme và component states. README có lệnh cài/chạy.

**Xong khi:** app mở được; UI nền kiểm tra tại 360 và 412 dp, body ≥14 sp, vùng chạm ≥48 dp, không overflow. Không ghi nhận dữ liệu tạm lúc phát triển là dữ liệu thật của bản nộp.

## 4. Firebase và Google Sign-In

**Làm:** tạo Firebase project, cấu hình FlutterFire, Google Sign-In, auth-state routing, đăng xuất/xóa dữ liệu phiên; xử lý hủy đăng nhập, mất mạng và lỗi. Thiết lập Firestore/security rules theo kiến trúc. Xác minh điều kiện gói dịch vụ thực tế, đặc biệt Storage; nếu công cụ/dịch vụ không dùng được, trao đổi với thầy trước khi thay thế.

**Đầu ra:** auth service/ViewModel/UI, cấu hình Firebase, rules và ảnh trạng thái đăng nhập/đăng xuất cùng Users console.

**Xong khi:** tài khoản Google test đăng nhập được; hủy có thông báo; đăng xuất không để lộ dữ liệu phiên cũ. Không commit secret, service-account key, keystore hoặc API key của model. Đề cho phép commit Android `google-services.json`.

## 5. F1 — Khám phá và đăng ký

**Làm:** A02 → A03 → A04 → A05 → A06 → A07, nối xác thực theo quyết định bước 1. Làm lọc/tìm kiếm, không kết quả, tham gia tự do, hết chỗ/hạn/hủy, đã đăng ký, lỗi form, đang gửi và phục hồi khi chưa rõ kết quả. Dùng dữ liệu Firestore/API thật, không hard-code danh sách trong bản nộp.

**Đầu ra:** F1 chạy trọn đường chính và các nhánh đã thiết kế; ảnh/log lưu trong `evidence/`.

**Xong khi:** không gửi đăng ký lặp; chỉ báo thành công sau xác nhận máy chủ; Back và giữ dữ liệu đúng. Khách ngoài trường không bị buộc nhập khóa K; sự kiện tự do không có đăng ký/QR.

## 6. F2 — Theo dõi và hủy đăng ký

**Làm:** A07/A08 và các màn liên quan A09/A10 theo Final UI; tab lịch, chi tiết, dialog hủy, trạng thái đang hủy/chưa rõ kết quả, cập nhật lịch. Phân biệt người dùng hủy đăng ký với CLB hủy sự kiện. Phần nhận push hoàn thiện ở bước 9.

**Đầu ra:** F2 hoàn chỉnh; tài khoản/thông báo có màn và nguồn dữ liệu tương ứng, không bỏ sót vì nằm ngoài happy path.

**Xong khi:** hủy thành công cập nhật dữ liệu thật; lỗi giữ trạng thái đúng; mọi đích điều hướng có thể tới và quay lại.

## 7. F4A — Điểm danh QR

**Làm:** A08 → A11 → A12; quyền camera/cài đặt, QR sai/sai sự kiện, đăng ký không hợp lệ, phiên đóng, sự kiện hủy, đang xử lý, mạng lỗi và tra kết quả. Kiểm tra điều kiện và ghi nhận phía máy chủ, không dùng đồng hồ/client làm nguồn xác nhận duy nhất.

**Đầu ra:** quét QR thực do web CLB hiển thị, lưu kết quả và giờ điểm danh thật.

**Xong khi:** quét lại không tạo lượt trùng; mất phản hồi không tự báo thất bại/thành công; A12 xem lại được. App không mở hoặc điều khiển web CLB.

## 8. Xuất file và upload Cloudinary Free (thay Firebase Storage)

**Làm:** tạo PDF lịch tham gia từ dữ liệu hiện người dùng đang xem, không chứa email/số điện thoại; upload qua preset Cloudinary Free giới hạn PDF/5 MB. Hiển thị trạng thái, lỗi/thử lại và URL. Đây là liên kết chia sẻ được, không có quyền truy cập riêng theo UID.

**Đầu ra:** chức năng sinh file thật, upload, ảnh Cloudinary Media Library và kết quả trên app. Ghi rõ trong báo cáo thầy đã chấp nhận thay Storage.

**Xong khi:** PDF khớp dữ liệu hiện tại; upload thật có phản hồi; UI cảnh báo người có URL có thể xem. Không đưa dữ liệu nhạy cảm lên dịch vụ này.

## 9. Đo lường và các dịch vụ Firebase còn lại

Viết `docs/analytics-plan.md` trước khi thêm tracking: ≥7 events, mỗi event có trigger, tham số/kiểu, câu hỏi sản phẩm và bước flow. Có login/logout, tìm kiếm hoặc hành động chính, từng loại detail, export/upload; không gửi tên/email cá nhân. Chụp DebugView cho từng event và gắn user ID sau đăng nhập.

Crashlytics: ghi một lỗi non-fatal từ nhánh lỗi thật và một test crash, kèm user ID và ít nhất một custom key; lưu bằng chứng dashboard.

Remote Config: ≥2 tham số đổi hành vi nhìn thấy được, có defaults. Ví dụ giới hạn số sự kiện gợi ý và bật/tắt gợi ý; không dùng để bỏ kiểm tra quyền/nghiệp vụ. Lưu `firebase/remote-config-defaults.json`, ảnh trước/sau và console.

FCM: xin quyền Android 13+, nhận foreground/background/terminated, lưu danh sách thông báo trong app, chạm mở đúng đích. Lưu bằng chứng cả ba trạng thái.

**Xong khi:** đủ sáu dịch vụ Firebase hoạt động và có xử lý lỗi; khu demo Firebase trong Tài khoản truy cập được các chức năng yêu cầu.

## 10. Kế hoạch test và ARTEMIS

**Làm:** `docs/test-plan.md` có ≥10 ca: ID, flow, tiền điều kiện, chỉ dẫn, kết quả mong đợi. Bao phủ mọi flow Lab 2 và nhánh thay thế/lỗi, auth, tìm kiếm/hành động chính, mọi tab, mỗi loại detail, export/upload, Remote Config và logout; ít nhất một tương tác native.

Tạo `e2e_test/conftest.py`, `pyproject.toml`, các `test_*.py` bằng pytest + ArtemisClient. Pin commit ARTEMIS trong README; dùng Flash cho regression. Assertion kiểm tra giá trị agent báo thấy, không chỉ `SUCCESS`; thêm Semantics cho widget quan trọng. Test độc lập, dùng Google test account và biến môi trường cho thông tin nhạy cảm.

Chạy mỗi test ≥3 lần; lưu command, trace ID/ảnh/replay từng lần, bảng pass rate/thời gian trung bình và nguyên nhân test flaky/failed/skipped. Ít nhất một ca kiểm tra analytics event. Chạy một exploratory session Pro 15–30 phút, ghi vấn đề phát hiện.

**Xong khi:** có kết quả thực và bằng chứng, giải thích mọi test chưa đạt; sửa và chạy lại ca liên quan, không tự ghi pass.

## 11. AI code review và sửa lỗi

**Làm:** review PR bằng ít nhất một công cụ AI; lưu đầu ra. Trong `docs/code-review.md` ghi ≥5 findings có file:dòng, thuộc ≥2 nhóm lỗi; mỗi finding có quyết định accepted/modified/rejected và lý do gắn yêu cầu/tác động thực tế.

**Đầu ra:** ≥3 sửa lỗi được chấp nhận, mỗi sửa một commit ghi ID finding và có link; khai báo mọi AI đã dùng.

**Xong khi:** sửa lỗi có thể truy vết, kiểm tra lại phần bị ảnh hưởng và cập nhật bằng chứng test khi cần.

## 12. Báo cáo, slide, video và bàn giao

- Repo: `PRM393_Lab03_<StudentID>`; xác nhận với thầy nếu làm nhóm. README có chủ đề, nguồn dữ liệu, cách chạy app/test, phiên bản pin, AI đã dùng, bản đồ tài liệu và video.
- Báo cáo: `report/Lab03_<StudentID>.pdf`, 8–12 trang; đầy đủ thiết kế/độ lệch, kiến trúc/theme, từng dịch vụ Firebase và lỗi, analytics, test, code review, khó khăn/bài học và AI disclosure.
- Slide: `slides/Lab03_<StudentID>_slides.pdf`, 12–15 slide; có Figma so với app, kiến trúc, theme/widget, từng dịch vụ Firebase, bằng chứng test/review.
- Video 5–10 phút: đăng nhập, ba flow kèm lỗi, export/upload, push, Remote Config không rebuild, Crashlytics, chạy ARTEMIS, một finding và bản sửa; hiện console khi cần chứng minh.
- Kiểm tra repo/PDF/video truy cập được bằng cửa sổ riêng tư. Chuẩn bị giải thích một ViewModel, một quyết định review, chạy test và đổi Remote Config trực tiếp.

**Xong khi:** mọi tuyên bố có ảnh/log/link bằng chứng và các link nộp mở được.

## Những điểm cần xác nhận, không tự suy đoán

Đề còn placeholder `[date]` và `[N]` cho hạn đổi đề tài, số commit và số ngày; cần hỏi thầy giá trị cụ thể. Làm cá nhân trừ khi thầy cho phép nhóm. Nội dung yêu cầu ARTEMIS dù tên PDF/footer ghi Patrol. Google Sign-In là yêu cầu bổ sung; không mặc định nó bắt buộc xóa email/password. Lab 3 chưa triển khai chỉ vì Lab 2 đã hoàn thành.

## Tiến độ triển khai ngày 31/10/2026

Đã có cấu hình `eventhub-group4`, chủ dự án xác nhận Google Sign-In và đã tạo Firestore. Đã code backend transaction cho F1/F2/F4A, các màn dữ liệu liên quan và notification feed trong app; test local/emulator xem `evidence/backend/validation.md`. **Chưa đánh dấu bước 4–7 hoàn thành toàn bộ**: còn deploy, nguồn CLB thật, camera/QR và nhánh cloud. Chưa bật billing; Functions/Storage cần quyết định của nhóm. A10/edit, export/upload, instrumentation, ARTEMIS, AI review PR và bộ báo cáo/video vẫn còn phải triển khai/thu bằng chứng theo từng bước.


Cập nhật 01/11/2026: A10/edit, export/upload và instrumentation đã có code/test local. ARTEMIS có 25 kịch bản nhưng chưa chạy host thật. Firestore Rules/indexes và Remote Config đã deploy; Functions/Storage chưa deploy. Xem docs/lab3-readiness.md cho trạng thái hiện hành thay cho ghi chú tiến độ cũ.

**Cập nhật 04/11/2026:** Các đoạn tiến độ 31/10–01/11 trên là lịch sử. App hiện dùng Firestore transaction + Security Rules trực tiếp cho F1/F2/F4A; Rules/indexes mới đã deploy. Không dùng Functions/Firebase Storage. PDF dùng Cloudinary Free, còn chờ tài khoản/preset và test cloud. [Bảng tiến độ](docs/lab3-readiness.md) là nguồn trạng thái hiện hành; không cộng test lịch sử vào kết quả hiện tại.
