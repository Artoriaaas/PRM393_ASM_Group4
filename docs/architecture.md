# Kiến trúc EventHub — Lab 3

Cập nhật 07/11/2026. Mobile là Flutter Android theo MVVM với Riverpod. CLB và admin dùng web riêng; app mobile không có quyền điều khiển web CLB.

## Luồng dữ liệu

```mermaid
flowchart LR
  UI[Flutter screens] --> VM[Riverpod ViewModels]
  VM --> I[Service contracts]
  I --> F[Firebase Auth / Firestore / FCM / Analytics / Crashlytics / Remote Config]
  I --> C[Cloudinary Free: PDF minh họa]
  I --> D[Camera và PDF local]
  W[Web CLB/admin: triển khai ở Final] --> F
```

## Cấu trúc và ranh giới lớp

| Thư mục | Trách nhiệm |
|---|---|
| `lib/models/` | Kiểu dữ liệu và trạng thái, không gọi SDK. |
| `lib/screens/` | Hiển thị và nhận thao tác; không truy cập Firebase/HTTP trực tiếp. |
| `lib/viewmodels/` | Điều phối trạng thái, kiểm tra dữ liệu nhập và nghiệp vụ màn hình. |
| `lib/services/contracts/` | Giao diện service để thay bằng fake trong test. |
| `lib/services/firebase/` | Firebase Auth, Firestore và các SDK cloud. |
| `lib/services/cloudinary/`, `lib/services/report/` | Upload PDF và tạo PDF từ dữ liệu đang xem. |
| `lib/app/` | Composition root, router, bootstrap và vòng đời ứng dụng; không được import từ ViewModel. |
| `lib/services/*providers.dart`, `cloud_service_provider.dart` | Cung cấp service qua contract; không import ViewModel hoặc UI. |
| `lib/theme/`, `lib/widgets/` | Token giao diện và widget dùng lại. |
| `lib/utils/` | Hàm thuần, không phụ thuộc UI. |

`session_viewmodel.dart` sở hữu phiên và UID; `event_data_providers.dart` sở hữu các stream AsyncValue; `cloud_state.dart` điều phối cloud theo phiên. Các provider service nằm trong `services/`; test override contract tại đó. Cách tổ chức này loại bỏ vòng import `app → ViewModel → app` mà không đổi route hoặc nghiệp vụ.

View phụ thuộc ViewModel và widget. ViewModel phụ thuộc service contract/model; Firebase và HTTP chỉ xuất hiện ở service hoặc lớp khởi tạo provider. Không đưa SDK vào `build()`.

| ViewModel | Service được inject | Luồng chính |
|---|---|---|
| `AuthViewModel`, `SessionViewModel` | Auth service | Đăng nhập, xác nhận email, đăng xuất và điều hướng theo phiên. |
| `EventFilterViewModel`, event/detail providers | Event service | Khám phá, tìm/lọc và chi tiết sự kiện. |
| `BookingViewModel` | Event service, pending-operation store | Đăng ký, hủy, điểm danh và tra kết quả chưa rõ. |
| `NotificationsViewModel` | Notification service | Hộp thư trong app và trạng thái đã đọc. |
| `ProfileViewModel` | Profile/Auth service | Xem và sửa hồ sơ. |
| `ExportViewModel` | Report service, report storage service | Tạo PDF, upload và hiển thị liên kết. |
| `CloudToolsViewModel` | Cloud services | FCM, Remote Config, Crashlytics thử nghiệm. |

Ví dụ trình tự F1 (chỉ hiện thành công khi Firestore xác nhận):

```mermaid
sequenceDiagram
  actor User as Người tham gia
  participant UI as RegistrationFormScreen
  participant VM as BookingViewModel
  participant Service as FirestoreEventService
  participant DB as Firestore + Rules
  User->>UI: Xác nhận đăng ký
  UI->>VM: submit(form)
  VM->>VM: Kiểm tra form, khóa gửi lặp, tạo operationId
  VM->>Service: execute(register, operationId)
  Service->>DB: Transaction: registration + activeCount
  DB-->>Service: Xác nhận hoặc từ chối theo Rules
  Service-->>VM: BookingResult
  alt Đã xác nhận
    VM-->>UI: Hiển thị A06
  else Lỗi hoặc kết quả chưa rõ
    VM-->>UI: Giữ form, cho kiểm tra trạng thái
  end
```

App dùng Firestore trực tiếp và Cloudinary; không có target prototype hoặc backend Functions.

## Nghiệp vụ Firestore hiện tại

- Đăng ký và hủy chạy qua transaction Firestore. Mỗi tài khoản/sự kiện có một ID đăng ký xác định. Cùng transaction thay đổi đăng ký và `events.activeCount`; Security Rules dùng `getAfter()` để kiểm tra hai bản ghi cùng thay đổi và chặn ghi số chỗ riêng lẻ. Rules dùng `request.time` cho hạn đăng ký, thời điểm bắt đầu và `serverTimestamp()` cho thời gian lưu.
- Mỗi lệnh có `operationId` lưu trong đăng ký. Khi mất phản hồi, app giữ lệnh cục bộ theo UID, hỏi server trước khi gửi lại cùng ID. Không suy ra thành công hay thất bại từ timeout. Mỗi người chỉ có một đăng ký hoạt động cho cùng sự kiện; re-register sau hủy tăng `generation`.
- Điểm danh: web CLB phải tạo QR ngẫu nhiên đủ dài, lưu SHA-256 vào `qrCredentials/{hash}` và mở `checkinSessions/{eventId}`. Mobile chỉ quét token, ghi hash và thời gian; Security Rules kiểm tra QR, event, session và đăng ký. Mobile không đọc danh sách QR hoặc tự mở session. Khi quét có thể get chính xác SHA-256 credential để phân biệt lỗi; chỉ chủ đăng ký active được get session cho sự kiện đó. Không nhận token gốc từ Firestore.
- Event và đăng ký chỉ hiện cho tài khoản có email đã xác nhận. Chủ user đọc đăng ký của mình. Việc tạo/sửa sự kiện, phiên QR, thông báo của người khác cần web/admin đáng tin cậy; không cấp quyền này cho mobile.
- Firestore trực tiếp thay thế Functions theo quyết định mới, nên chưa có `history`/operation ledger riêng. Recovery dựa trên `lastOperationId` của đăng ký hiện tại; nếu thiết bị khác của cùng tài khoản thay đổi đăng ký trong lúc lệnh cũ chưa rõ, app giữ trạng thái chưa xác định để kiểm tra thủ công. Cần E2E đa thiết bị trước khi chốt sản phẩm.

## PDF và Cloudinary

PDF chứa tên sự kiện, CLB, thời gian, địa điểm và trạng thái; không chứa email/số điện thoại. File được tạo cục bộ rồi upload bằng unsigned preset Cloudinary Free với `resource_type=raw`. `CLOUDINARY_CLOUD_NAME` và `CLOUDINARY_UPLOAD_PRESET` là cấu hình công khai truyền qua `--dart-define`, không phải secret. **Ai có URL đều có thể xem PDF.** Preset unsigned có thể bị lạm dụng; Console phải hạn chế định dạng PDF, dung lượng tối đa 5 MB, thư mục riêng. Không dùng Cloudinary cho dữ liệu nhạy cảm hoặc làm nguồn sự thật của đăng ký. Xem [hướng dẫn cấu hình](cloudinary-setup.md).

## Phần phải kiểm tra trên cloud

Emulator đã xác minh Rules cho đăng ký, hủy, QR hợp lệ và giả mạo. Cần chạy trên Android với project thật và ghi bằng chứng: Auth, Firestore transaction, QR/phiên fixture do người quản lý chuẩn bị qua Console cho Lab 3 (web CLB thuộc Final), PDF Cloudinary, FCM ba trạng thái, Analytics DebugView, Crashlytics, Remote Config trước/sau. ARTEMIS và AI review PR vẫn cần môi trường/tài khoản riêng. Bảng trạng thái hiện hành ở [lab3-readiness.md](lab3-readiness.md).

## Packages và tương thích sau merge

`packages/core/` chứa lớp dùng chung do teammate thêm; `web/` là package web riêng. Mobile vẫn dùng các model lib/models và một số widget/theme local; không tuyên bố toàn bộ đã migrate sang core. Root analyze kiểm mobile, từng package kiểm riêng. Rules giữ luồng Lab3 đăng ký trực tiếp cho event không có clubId và luồng web xét duyệt cho event có clubId; mobile không được tự bỏ clubId ở event. Không thêm workflow duyệt vào các event Lab3 đã chốt.
