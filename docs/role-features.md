# Đặc tả Vai trò và Tính năng Hệ thống EventHub

Tài liệu này tổng hợp đầy đủ các vai trò (`roles`), ranh giới quyền hạn, và danh mục tính năng của hệ thống **EventHub** khi hoàn thiện thành một hệ thống thống nhất trên Firebase (gồm **Flutter Mobile App** cho người tham gia và **Flutter Web Admin** cho Trưởng CLB & Quản trị viên).

---

## 1. Tổng quan Phân vai và Kiểm soát Truy cập

Hệ thống sử dụng chung một cơ sở dữ liệu **Cloud Firestore** và xác định vai trò thông qua trường `users/{uid}.role`. Không sử dụng máy chủ tùy chỉnh hay Cloud Functions; mọi ràng buộc phân quyền được thực thi trực tiếp bởi **Firestore Security Rules** kết hợp kiểm tra cổng đăng nhập trên từng client.

| Mã role (`users/{uid}.role`) | Tên vai trò | Client sử dụng | Phạm vi dữ liệu | Cách cấp quyền |
|---|---|---|---|---|
| `user` | **Sinh viên / Người tham gia** *(gồm cả sinh viên FPTU và khách ngoài trường khi khai biểu mẫu)* | **Mobile App** (Flutter Android) | Dữ liệu công khai (`events` đã publish, `clubs`, `announcements`) và dữ liệu cá nhân của chính `uid` (`registrations`, `notifications`, `devices`, metadata PDF) | Tự động khởi tạo `role = 'user'` ngay lần đăng nhập đầu tiên |
| `staff` | **Trưởng câu lạc bộ (CLB)** | **Web Admin** (Flutter Web trên Firebase Hosting) | Chỉ trong phạm vi CLB được gán tại `users/{uid}.clubId` (sự kiện của CLB, đơn đăng ký vào sự kiện CLB, phiên & mã QR của CLB, thông báo CLB) | Do `admin` cấp quyền `role = 'staff'` và gán `clubId` |
| `admin` | **Quản trị viên hệ thống** | **Web Admin** (Flutter Web trên Firebase Hosting) | Toàn hệ thống (quản lý `users` & `role`, quản lý danh mục `clubs`, giám sát/can thiệp mọi `events`, `registrations`, `announcements` và Dashboard tổng) | Tài khoản `admin` đầu tiên được thiết lập trên Firebase Console và ghi danh trong `README.md`; các `admin` sau do `admin` hiện hữu cấp |

### Quy tắc Bảo vệ Cổng Đăng nhập và Phân quyền (Role Gate)
1. **Bất biến quyền tự thân**: Chỉ `admin` mới được thay đổi `users/{targetUid}.role` và `clubId`. **Không ai (kể cả `admin`) được phép tự thay đổi `role` của chính mình** (`request.auth.uid != targetUid`).
2. **Chặn chéo trên Mobile App**: Mobile App chỉ phục vụ `role == 'user'`. Nếu tài khoản có `role` là `staff` hoặc `admin` đăng nhập vào Mobile App, ứng dụng chặn truy cập vào luồng nghiệp vụ, hiển thị thông báo rõ ràng hướng dẫn chuyển sang **Web Admin** và cung cấp nút Đăng xuất.
3. **Chặn chéo trên Web Admin**: Web Admin yêu cầu đăng nhập bằng **Google Sign-In** và chỉ cho phép `role in ['staff', 'admin']` (riêng `staff` phải có `clubId` hợp lệ). Nếu tài khoản `role == 'user'` đăng nhập vào Web Admin, giao diện lập tức hiển thị trạng thái **Từ chối quyền truy cập (Role Rejection)** kèm thông báo giải thích rõ lý do và nút đăng xuất/đổi tài khoản.

---

## 2. Chi tiết Tính năng theo Từng Vai trò

### 2.1. Role `user` — Sinh viên / Người tham gia (Mobile App)

Luồng tính năng của `user` kế thừa trọn vẹn thiết kế Lab 2 (`A01`–`A12`, các luồng `F1`, `F2`, `F4A`) và mã nguồn hiện có trong `lib/`, đồng thời nâng cấp trạng thái đăng ký sang cơ chế **chờ duyệt (`pending` → `approved` / `rejected`)** và mở rộng hộp thư nhận thông báo từ Web Admin.

#### A. Xác thực & Quản lý Phiên (`A01a–d` · `/auth/*`)
- **Đăng nhập đa phương thức** (`AuthScreen`): Hỗ trợ **Google Sign-In** và **Email/Mật khẩu**; xử lý đầy đủ trường hợp người dùng hủy hộp thoại chọn tài khoản Google, sai thông tin hoặc mất kết nối mạng.
- **Đăng ký & Xác minh Email**: Tạo tài khoản mới (`mode: 'register'`), gửi và kiểm tra trạng thái xác minh email (`mode: 'verify'`) trước khi cho phép thao tác dữ liệu, khôi phục mật khẩu qua email (`mode: 'reset'`).
- **Điều hướng bảo vệ phiên (`authRedirect`)**: Chặn người dùng chưa đăng nhập hoặc chưa xác minh email; ghi nhớ đích đến đang chờ (`pending destination`) để đưa người dùng vào đúng sự kiện sau khi đăng nhập thành công.
- **Đăng xuất an toàn**: Đóng các stream theo dõi dữ liệu cá nhân, xóa trạng thái nháp/bộ nhớ cục bộ theo UID và gỡ đăng ký thiết bị nhận push tại `users/{uid}/devices/{deviceId}`.

#### B. Khám phá, Tìm kiếm & Xem Chi tiết Sự kiện (`F1` · `A02`, `A03`, `A04`)
- **Khám phá sự kiện (`A02` · `/discover` · `EventListScreen`)**: Xem danh sách sự kiện gợi ý đang mở (`visibility == 'public'`, `status == 'published'`). Số lượng thẻ gợi ý và cờ bật/tắt khu vực gợi ý được điều khiển động qua **Firebase Remote Config** (`recommendation_limit`, `show_recommendations`) mà không cần cài đặt lại ứng dụng.
- **Tìm kiếm & Bộ lọc (`A03` · `/discover/search`)**: Tìm theo từ khóa và lọc theo Câu lạc bộ, chủ đề, ngày/trạng thái; giữ nguyên bộ lọc khi quay lại (`Back`); hiển thị đầy đủ các trạng thái `loading`, `empty` (kèm thao tác xóa bộ lọc) và `error` (kèm nút thử lại).
- **Xem chi tiết sự kiện (`A04` · `/events/:eventId` · `EventDetailScreen`)**:
  - Hiển thị đầy đủ tên sự kiện, CLB tổ chức, thời gian bắt đầu/kết thúc, hạn đăng ký, địa điểm, mô tả, đối tượng tham gia, danh sách hoạt động, yêu cầu chuẩn bị và số chỗ còn lại (`capacity - activeCount`).
  - Phân biệt rõ **Sự kiện cần đăng ký (`registrationMode == 'required'`)** và **Sự kiện tham gia tự do (`registrationMode == 'free'`)**: với sự kiện tự do, người dùng xem thông tin trực tiếp, không hiện nút đăng ký hay quét QR.
  - Tự động khóa thao tác đăng ký với nhãn giải thích rõ khi sự kiện đã hết chỗ, quá hạn đăng ký, đã bắt đầu hoặc bị CLB hủy.

#### C. Đăng ký Sự kiện (Chờ duyệt) & Phục hồi Mạng (`F1` · `A05`, `A06`)
- **Khai thông tin theo nhóm người tham gia (`A05` · `/events/:eventId/register` · `RegistrationFormScreen`)**:
  - Nhóm **Sinh viên (`student`)**: Bắt buộc nhập Họ tên, Email, Khóa K (`cohort`), SĐT tùy chọn.
  - Nhóm **Khách ngoài trường (`guest`)**: Tự động ẩn trường Khóa K, cho phép nhập Trường/Tổ chức (`organization`).
- **Gửi yêu cầu đăng ký chờ duyệt (`pending`)**: Tạo bản ghi `registrations/{uid}_{eventId}` với `status = 'pending'`. Màn hình `A06` (`/registrations/:registrationId/success`) xác nhận hệ thống đã tiếp nhận yêu cầu và đang chờ Trưởng CLB xét duyệt.
- **Chống gửi lặp & Phục hồi khi mất mạng (`BookingViewModel` + `SecurePendingBookingStore`)**: Mỗi thao tác gắn một `operationId` duy nhất lưu cục bộ theo UID; nếu mất mạng trước khi nhận phản hồi, ứng dụng giữ nguyên dữ liệu biểu mẫu và cho phép tra cứu lại kết quả máy chủ (`recover`) hoặc gửi lại cùng `operationId` mà không sinh bản ghi trùng.

#### D. Theo dõi Lịch Cá nhân, Hủy & Đăng ký lại (`F2` · `A07`, `A08`)
- **Lịch tham gia thời gian thực (`A07` · `/schedule` · `LiveScheduleScreen`)**: Tổ chức theo 3 phân mục (`Sắp tới`, `Đã kết thúc`, `Đã hủy`), tự động cập nhật realtime huy hiệu trạng thái đơn đăng ký: `Chờ duyệt` (`pending`), `Đã duyệt` (`approved`), `Bị từ chối` (`rejected`), `Đã điểm danh` (`checkInAt != null`), `Đã hủy đăng ký` (`cancelled`) hoặc `Sự kiện đã hủy`.
- **Chi tiết đơn đăng ký (`A08` · `/registrations/:registrationId` · `RegistrationDetailScreen`)**:
  - Xem lại thông tin người tham gia đã gửi, trạng thái xét duyệt hiện tại, hoặc **lý do từ chối (`reason`)** do Trưởng CLB phản hồi.
  - **Hủy đăng ký** (có hộp thoại xác nhận): Cho phép hủy khi đơn đang `pending` (chuyển sang `cancelled`, không đổi `activeCount`) hoặc khi đơn đã `approved` nhưng sự kiện chưa bắt đầu và chưa điểm danh (chuyển sang `cancelled` đồng thời giảm nguyên tử `events/{eventId}.activeCount - 1`).
  - **Đăng ký lại (`re-register`)**: Sau khi tự hủy hoặc bị từ chối (nếu đã khắc phục thông tin sai và sự kiện vẫn còn hạn/còn chỗ), người dùng có thể gửi đăng ký lại trên cùng tài liệu với `generation + 1` (đưa trạng thái về `pending`).

#### E. Điểm danh bằng Mã QR tại Sự kiện (`F4A` · `A11`, `A12`)
- **Quét mã QR (`A11` · `/registrations/:registrationId/scan` · `ScannerScreen`)**:
  - Chỉ mở cho đơn đã được duyệt (`status == 'approved'`) của sự kiện đang `published`.
  - Yêu cầu quyền Camera của hệ điều hành (hiển thị hướng dẫn mở Cài đặt nếu quyền bị từ chối).
  - Băm SHA-256 chuỗi QR quét được và ghi `checkInAt = serverTimestamp()`, `qrHash` vào `registrations/{uid}_{eventId}`; được Security Rules xác thực đối chiếu với phiên điểm danh đang mở (`checkinSessions/{eventId}.open == true`) và mã QR hợp lệ của sự kiện (`qrCredentials/{qrHash}`).
- **Xem biên nhận điểm danh bảo vệ quyền riêng tư (`A12` · `/registrations/:registrationId/check-in`)**: Hiển thị thời gian điểm danh chuẩn từ máy chủ và thông tin sự kiện, đồng thời **ẩn email và số điện thoại** để tránh lộ dữ liệu cá nhân khi xuất trình màn hình tại bàn điểm danh.

#### F. Hộp thư Thông báo (Inbox) & Push Notification (`A09`)
- **Inbox thời gian thực (`A09` · `/notifications` · `NotificationsTabScreen`)**:
  - Nhận thông báo cá nhân tại `users/{uid}/notifications/{id}` (khi Trưởng CLB duyệt/từ chối đơn đăng ký hoặc sự kiện đã đăng ký có thay đổi).
  - Nhận thông báo chung/thông báo CLB từ collection `announcements/{id}` do Trưởng CLB hoặc Admin phát hành từ Web Admin.
  - Đánh dấu đã đọc (`readAt`) và điều hướng trực tiếp tới màn hình chi tiết đăng ký (`A08`) hoặc chi tiết sự kiện (`A04`) tương ứng.
- **Thông báo đẩy FCM**: Xin quyền thông báo trên Android 13+, nhận và điều hướng từ thông báo đẩy ở cả 3 trạng thái (`foreground`, `background`, `terminated`).

#### G. Hồ sơ Cá nhân & Xuất Báo cáo PDF (`A10`, `L3-02`)
- **Quản lý hồ sơ (`A10` · `/account`, `/account/edit`)**: Xem thông tin tài khoản, chỉnh sửa tên hiển thị; hỗ trợ đổi email kèm xác thực lại đối với tài khoản mật khẩu (tài khoản Google hiển thị email chỉ đọc).
- **Xuất báo cáo PDF lịch tham gia (`/account/export` · `ExportScreen`)**: Tổng hợp lịch tham gia thực tế thành tệp PDF tiếng Việt (không chứa email/SĐT nhạy cảm), lưu/chia sẻ trực tiếp trên thiết bị và ghi nhận metadata xuất báo cáo lên Firestore.

---

### 2.2. Role `staff` — Trưởng Câu lạc bộ (Web Admin — Phạm vi CLB)

Mỗi tài khoản Trưởng CLB có `users/{uid}.role == 'staff'` và được gắn cố định với một CLB thông qua `users/{uid}.clubId`. Trưởng CLB làm việc trên **Flutter Web Admin** (giao diện màn hình rộng sử dụng lại hệ thống design tokens và components từ Lab 2) và **chỉ được thao tác trên dữ liệu thuộc CLB của mình**.

#### A. Đăng nhập & Kiểm tra Phạm vi CLB (`Sign-in` · `/login`)
- Đăng nhập bằng **Google Sign-In**.
- Kiểm tra tự động `users/{uid}`: chỉ cho vào không gian làm việc nếu `role == 'staff'` và đã được gán `clubId` hợp lệ; từ chối tài khoản `user` hoặc tài khoản chưa được phân công CLB bằng thông báo rõ ràng.

#### B. Quản lý Sự kiện CLB & Điều phối Điểm danh QR (`Management` · `/events`)
- **Danh sách & Tìm kiếm sự kiện CLB**: Xem, tìm kiếm theo từ khóa và lọc theo trạng thái (`draft`, `published`, `cancelled`, `archived`) toàn bộ sự kiện có `clubId == staff.clubId` (đầy đủ trạng thái `loading`, `empty`, `error`).
- **Tạo mới & Cập nhật sự kiện**: Khởi tạo sự kiện ở chế độ bản nháp (`draft`) hoặc công bố ngay (`published`); chỉnh sửa tiêu đề, mô tả, chủ đề, địa điểm, thời gian bắt đầu/kết thúc, hạn đăng ký (`deadline`), hình thức tham gia (`required` / `free`), sức chứa (`capacity`), hoạt động và lưu ý chuẩn bị.
- **Hủy hoặc Lưu trữ sự kiện (`Cancel` / `Archive`)**:
  - Chuyển sang `cancelled` khi sự kiện buộc phải dừng tổ chức (Mobile tự động khóa đăng ký/điểm danh và hiển thị nhãn *"Sự kiện đã hủy"*).
  - Chuyển sang `archived` để ẩn sự kiện cũ khỏi danh sách khám phá công khai mà **không xóa cứng bản ghi**, giữ nguyên toàn vẹn lịch sử cho sinh viên đã tham gia.
- **Điều khiển Phiên Điểm danh & Mã QR trực tiếp (Live Check-in Panel)**:
  - Mở / Đóng phiên điểm danh cho sự kiện của CLB (`checkinSessions/{eventId}.open = true / false`).
  - Sinh token QR ngẫu nhiên độ dài tối thiểu 32 ký tự, chỉ lưu mã băm SHA-256 lên `qrCredentials/{qrHash}` (`{eventId, clubId, enabled: true}`) và hiển thị mã QR kích thước lớn trên màn hình Web để chiếu tại hội trường.
  - Hỗ trợ làm mới (rotate) / vô hiệu hóa mã QR cũ và theo dõi **danh sách + số lượng sinh viên đã điểm danh cập nhật realtime** ngay khi sinh viên quét mã trên Mobile.

#### C. Hàng đợi Xét duyệt Đăng ký (`Review Queue` · `/reviews`)
- **Theo dõi hàng đợi thời gian thực**: Hiển thị trực tiếp các đơn đăng ký có `status == 'pending'` thuộc các sự kiện của CLB mình (`clubId == staff.clubId`), hỗ trợ lọc theo sự kiện, đối tượng (`student` / `guest`) và tìm kiếm người đăng ký.
- **Phê duyệt đăng ký (`Approve`)**:
  - Thực thi Firestore Transaction kiểm tra sự kiện vẫn còn chỗ (`activeCount < capacity`), cập nhật `registrations/{id}` từ `pending` → `approved` (lưu `reviewedBy`, `reviewedAt`, ghi chú phản hồi tùy chọn), tăng `events/{eventId}.activeCount + 1`, đồng thời ghi thông báo xác nhận vào `users/{uid}/notifications/{notifId}`.
- **Từ chối đăng ký kèm lý do (`Reject`)**:
  - Bắt buộc nhập **lý do từ chối (`reason`)** rõ ràng trước khi xác nhận; chuyển trạng thái đơn từ `pending` → `rejected` (không thay đổi `activeCount`) và gửi thông báo kèm lý do vào hộp thư của người đăng ký trên Mobile.

#### D. Bảng điều khiển Thống kê CLB (`Dashboard` · `/dashboard`)
- **Các chỉ số tổng hợp (`≥ 3` figures từ Firestore aggregation queries)** tính riêng cho `clubId` của Trưởng CLB:
  1. Tổng số sự kiện đang mở (`published`) của CLB.
  2. Tổng số đơn đăng ký đang chờ duyệt (`pending`) cần xử lý.
  3. Tổng số lượt đăng ký đã duyệt (`approved`) và tổng số lượt đã điểm danh (`checkInAt != null`).
- **Biểu đồ trực quan (`≥ 1` chart)**: Biểu đồ cột so sánh *Sức chứa — Đã duyệt — Đã điểm danh* qua các sự kiện của CLB (hoặc lượng đơn đăng ký theo thời gian).

#### E. Phát hành Thông báo CLB / Sự kiện (`Announcement Form` · `/announcements`)
- Soạn và đăng thông báo mới vào collection `announcements/{id}` gắn với CLB (`clubId = staff.clubId`) hoặc một sự kiện cụ thể của CLB (`eventId`).
- Thông báo vừa đăng xuất hiện ngay lập tức trong tab **Thông báo (Inbox)** trên Mobile App của sinh viên.

---

### 2.3. Role `admin` — Quản trị viên Hệ thống (Web Admin — Toàn hệ thống)

Tài khoản Quản trị viên có `users/{uid}.role == 'admin'`, đăng nhập trên cùng ứng dụng **Flutter Web Admin** nhưng mở khóa phạm vi quản trị toàn trường.

#### A. Đăng nhập Quản trị (`Sign-in` · `/login`)
- Đăng nhập bằng **Google Sign-In** và xác nhận `users/{uid}.role == 'admin'`.

#### B. Quản trị Người dùng, Phân quyền & Danh mục Hệ thống (`Management` · `/users`, `/clubs`, `/events`)
- **Quản lý Người dùng & Cấp quyền (`users/{uid}`)**:
  - Xem danh sách, tìm kiếm tài khoản theo tên hiển thị/email và lọc theo vai trò (`user`, `staff`, `admin`).
  - Thay đổi `role` cho người dùng khác và **gán `clubId`** khi bổ nhiệm Trưởng CLB (`staff`).
  - Hệ thống khóa hoàn toàn thao tác tự sửa `role` của chính tài khoản `admin` đang đăng nhập ở cả giao diện lẫn Firestore Security Rules.
- **Quản lý Danh mục Câu lạc bộ (`clubs/{clubId}`)**:
  - Danh sách, tìm kiếm, tạo mới, chỉnh sửa thông tin CLB (tên CLB, mô tả, lĩnh vực) và lưu trữ (`archived`) CLB ngừng hoạt động — dữ liệu này đồng bộ trực tiếp sang bộ lọc CLB trên Mobile App và danh sách gán quyền `staff`.
- **Giám sát & Can thiệp Sự kiện Toàn trường (`events/{id}`)**:
  - Tra cứu tất cả sự kiện của mọi CLB; có quyền chỉnh sửa hoặc chuyển trạng thái `cancelled` / `archived` đối với sự kiện sai phạm hoặc khi CLB cần hỗ trợ khẩn cấp.

#### C. Giám sát Hàng đợi Duyệt Toàn hệ thống (`Review Queue` · `/reviews`)
- Theo dõi toàn bộ đơn đăng ký `pending` trên tất cả các CLB (có bộ lọc theo từng CLB và từng sự kiện).
- Có quyền phê duyệt (`approved`) hoặc từ chối kèm lý do (`rejected`) để xử lý tồn đọng khi một CLB tạm khuyết Trưởng CLB.

#### D. Bảng điều khiển Toàn hệ thống (`Dashboard` · `/dashboard`)
- **Các chỉ số tổng hợp cấp hệ thống (`≥ 3` figures từ aggregation queries)**:
  1. Tổng số sự kiện đang hoạt động (`published`) trên toàn trường.
  2. Tổng số đơn đăng ký chờ duyệt (`pending`) và đã duyệt (`approved`) toàn hệ thống.
  3. Tổng số CLB đang hoạt động và cơ cấu người dùng theo vai trò (`user` / `staff` / `admin`).
- **Biểu đồ tổng quan (`≥ 1` chart)**: Biểu đồ thống kê số lượng sự kiện và lượt đăng ký được duyệt phân theo từng Câu lạc bộ.

#### E. Phát hành Thông báo Toàn trường (`Announcement Form` · `/announcements`)
- Đăng thông báo cấp toàn hệ thống (`scope = 'global'`) hoặc thông báo chỉ định theo CLB/sự kiện vào `announcements/{id}`, hiển thị realtime trong hộp thư Inbox trên Mobile App của tất cả người dùng.

---

## 3. Ma trận Đối chiếu Quyền hạn theo Nghiệp vụ

| Nhóm chức năng / Dữ liệu | `user` (Mobile App) | `staff` — Trưởng CLB (Web Admin) | `admin` — Quản trị viên (Web Admin) |
|---|---|---|---|
| **Đăng nhập Mobile App** | Cho phép | Từ chối (hướng dẫn sang Web) | Từ chối (hướng dẫn sang Web) |
| **Đăng nhập Web Admin (Google)** | Từ chối (*Role rejection*) | Cho phép (khi có `clubId`) | Cho phép |
| **Quản lý `users/{uid}.role` & `clubId`** | Chỉ đọc hồ sơ của mình, sửa `displayName` | Chỉ đọc hồ sơ của mình (và thông tin `participant` trong đơn thuộc CLB) | Xem danh sách; đổi `role` & `clubId` cho người khác (**không tự đổi role của mình**) |
| **Danh mục CLB (`clubs`)** | Đọc các CLB đang hoạt động | Đọc thông tin CLB | Tạo, sửa, tìm kiếm, lưu trữ (`archive`) mọi CLB |
| **Sự kiện (`events`)** | Đọc sự kiện `published` & `public` | Tạo, sửa, hủy, `archive` sự kiện thuộc `clubId` của mình | Xem, tìm kiếm, sửa, hủy, `archive` sự kiện của mọi CLB |
| **Đăng ký sự kiện (`registrations`)** | Tạo đơn (`pending`), xem đơn của mình, tự hủy (`cancelled`), đăng ký lại | Xem đơn thuộc sự kiện CLB mình; duyệt (`approved`) hoặc từ chối kèm lý do (`rejected`) | Xem toàn bộ; có quyền duyệt / từ chối kèm lý do khi cần can thiệp |
| **Phiên & Mã QR (`checkinSessions`, `qrCredentials`)** | Không đọc danh sách QR; chỉ gửi lệnh quét QR điểm danh cho đơn `approved` của mình | Mở/đóng phiên, phát & xoay mã QR, xem kết quả điểm danh realtime cho sự kiện CLB mình | Giám sát trạng thái phiên và số liệu điểm danh; đóng phiên khi cần |
| **Thông báo chung (`announcements`)** | Đọc realtime trong Mobile Inbox | Tạo thông báo trong phạm vi CLB / sự kiện của CLB mình | Tạo thông báo toàn trường (`global`) hoặc bất kỳ CLB nào |
| **Thông báo cá nhân (`users/{uid}/notifications`)** | Đọc và đánh dấu `readAt` thông báo của mình | Tạo thông báo kết quả duyệt/từ chối cho người đăng ký sự kiện CLB mình | Tạo thông báo hệ thống/xét duyệt cho người dùng khi xử lý đơn |
| **Dashboard thống kê** | Không áp dụng (xem Lịch cá nhân & xuất PDF) | Xem số liệu aggregation & biểu đồ trong phạm vi CLB mình | Xem số liệu aggregation & biểu đồ toàn hệ thống |

---

## 4. Ghi chú Mở cho Tính năng AI (Gemini — Firebase AI Logic)

Nhóm tạm thời **chưa khóa cứng vị trí đặt tính năng AI** ở bước đặc tả vai trò này để ưu tiên chốt luồng nghiệp vụ cốt lõi trước. Khi triển khai giai đoạn tích hợp AI (đặc tả chi tiết tại `docs/ai-feature.md`), tính năng Gemini (gọi qua Firebase AI Logic có App Check, Remote Config model/prompt/kill-switch, không gửi PII, cho phép người dùng chỉnh sửa kết quả) sẽ được gắn vào một trong các điểm chạm thuộc các vai trò trên (ví dụ: hỗ trợ gợi ý/lập kế hoạch sự kiện cho `user` trên Mobile hoặc hỗ trợ phân loại đơn `Review Queue` / soạn nháp nội dung sự kiện & thông báo có cấu trúc cho `staff` trên Web).
