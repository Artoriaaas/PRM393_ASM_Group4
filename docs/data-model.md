> Bổ sung Final 13/11/2026: users/{uid}/reports/{id} có fileName(string), mimeType='application/pdf', byteCount(int 1..20MB), rowCount(int 1..10000), createdAt(server timestamp). User chỉ tạo/đọc của mình; staff/admin không đọc/ghi file metadata người khác; không update/delete. Không lưu URL/path/file bytes. users/{uid}/announcementReads/{announcementId}: readAt(server timestamp), user đọc/tạo/cập nhật của mình khi announcement tồn tại; không delete. Hai collection dùng ExportScreen và NotificationsTabScreen. New registrations chỉ tạo pending; active cũ được giữ lịch sử/hủy/check-in có điều kiện, không tạo active mới.

# Mô hình Dữ liệu Cloud Firestore (`docs/data-model.md`)

> **Căn cứ yêu cầu**: Đề Final Assignment — Mục 6 (Backend requirements) & Phụ lục A (Appendix A — Data model template).  
> **Nguyên tắc hệ thống**: Hệ thống không sử dụng custom server hay Cloud Functions; toàn bộ việc phân quyền, kiểm tra tính toàn vẹn dữ liệu và chuyển đổi trạng thái được kiểm soát trực tiếp bởi **Firestore Security Rules** (`firebase/firestore.rules`) kết hợp logic client (`mobile/`, `web/`, `packages/core/`).

---

## 1. Hệ thống Phân vai & Nguyên tắc Truy cập (`Roles & Access Control`)

Vai trò người dùng được lưu trữ tại trường `role` của tài liệu `users/{uid}`.
- `user`: Sinh viên / Người tham gia sự kiện (chỉ sử dụng **Mobile App**).
- `staff`: Trưởng Câu lạc bộ (sử dụng **Web Admin**, phạm vi thao tác bị giới hạn bởi `users/{uid}.clubId`).
- `admin`: Quản trị viên hệ thống (sử dụng **Web Admin**, có toàn quyền quản trị và phân vai).

### Nguyên tắc Bất biến (`Invariants`)
1. Tài khoản Admin đầu tiên được khởi tạo trực tiếp trên Firebase Console và ghi rõ trong `README.md`.
2. Chỉ `admin` mới có quyền thay đổi `role` và `clubId` của người khác.
3. Không ai (kể cả `admin`) được phép tự thay đổi `role` của chính mình (`request.auth.uid != targetUid`).
4. Khách vãng lai (`guest`) và sinh viên (`student`) dùng chung role `user`; sự khác biệt nằm ở trường tự khai `participant.group` trong từng đơn đăng ký.

---

## 2. Bảng Đặc tả Collection Firestore (Chuẩn Appendix A)

| Collection / Sub-collection | Các trường chính (Key fields & Types) | Create (Tạo mới) | Read (Đọc) | Update (Cập nhật) | Delete (Xóa) | Màn hình sử dụng (Screens) |
|---|---|---|---|---|---|---|
| `users/{uid}` | `role` (string: `'user'`, `'staff'`, `'admin'`), `displayName` (string), `email` (string), `clubId` (string?), `createdAt` (timestamp), `updatedAt` (timestamp?) | Tự tạo khi đăng nhập lần đầu (`self`), mặc định gán `role = 'user'` | `self` đọc hồ sơ của mình; `admin` đọc toàn bộ; `staff` đọc qua đơn đăng ký | Chỉ `admin` được đổi `role` & `clubId` (không tự đổi của mình); `self` chỉ đổi `displayName` | Bị cấm (`allow delete: if false`) | **Mobile**: `A10 AccountTabScreen`, `ProfileEditScreen`.<br>**Web**: `AdminUsersScreen`, `AppShell`. |
| `clubs/{clubId}` | `name` (string), `shortName` (string), `description` (string), `status` (string: `'active'`, `'archived'`), `createdAt` (timestamp), `updatedAt` (timestamp) | Chỉ `admin` | Mọi user đã xác thực (`member()`) | Chỉ `admin` | Bị cấm (chuyển sang `archived` thay vì xóa) | **Mobile**: Bộ lọc `A02/A03`.<br>**Web**: `AdminClubsScreen`. |
| `events/{eventId}` | `title` (string <= 120), `clubId` (string), `clubName` (string), `location` (string), `startsAt` (timestamp), `endsAt` (timestamp), `deadline` (timestamp?), `description` (string), `topic` (string), `coverKey` (string), `registrationMode` (string: `'required'`, `'free'`), `visibility` (string: `'public'`, `'unlisted'`), `status` (string: `'draft'`, `'pending_approval'`, `'rejected'`, `'published'`, `'cancelled'`, `'archived'`), `capacity` (int), `activeCount` (int), `updatedAt` (timestamp) | `staff` (chỉ CLB được phân công; tạo draft/pending_approval) | Người dùng đã đăng nhập đọc sự kiện `published` & `public`; `staff` đọc sự kiện của CLB mình; `admin` đọc tất cả | `staff` cập nhật nội dung sự kiện CLB; `staff`/`admin` tăng activeCount khi duyệt; `user` chỉ giảm 1 khi hủy approved (hoặc legacy active) bằng transaction hợp lệ; tạo pending không đổi count | Bị cấm (chuyển sang `cancelled` hoặc `archived`) | **Mobile**: `A02 Discover`, `A03 Search`, `A04 EventDetail`.<br>**Web**: `ClubEventsScreen`, `LiveQrPanelScreen`. |
| `registrations/{uid}_{eventId}` | `uid` (string), `eventId` (string), `clubId` (string), `status` (string: `'pending'`, `'approved'`, `'rejected'`, `'cancelled'`), `generation` (int), `participant` (map: `name`, `email`, `group`, `cohort`, `organization`, `phone`), `reason` (string?), `reviewedBy` (string?), `reviewedAt` (timestamp?), `checkInAt` (timestamp?), `qrHash` (string?), `createdAt` (timestamp), `lastOperationId` (string: 48 hex) | `user` tạo đơn của chính mình (với `status = 'pending'`, sự kiện còn hạn/chỗ) | Chủ đơn (`uid == auth.uid`), `staff` cùng `clubId`, hoặc `admin` | `user` hủy đơn của mình (`cancelled`) hoặc check-in (`checkInAt`); `staff`/`admin` duyệt (`approved`) hoặc từ chối (`rejected` kèm `reason`) | Bị cấm (`allow delete: if false`) | **Mobile**: `A05 Register`, `A06 Success`, `A07 Schedule`, `A08 Detail`, `A11 Scan`, `A12 Result`.<br>**Web**: `ReviewQueueScreen`, `LiveQrPanelScreen`. |
| `checkinSessions/{eventId}` | `eventId` (string), `clubId` (string), `open` (bool), `updatedBy` (string), `updatedAt` (timestamp) | `staff` (CLB sở hữu sự kiện) hoặc `admin` | Get: chủ đơn approved/legacy active hoặc staff đúng CLB/admin; list: staff theo club/admin | `staff` cùng `clubId` hoặc `admin` (mở/đóng phiên) | Bị cấm | **Mobile**: `A11 ScannerScreen`.<br>**Web**: `LiveQrPanelScreen`. |
| `qrCredentials/{qrHash}` | `eventId` (string), `clubId` (string), `enabled` (bool), `createdBy` (string), `createdAt` (timestamp) | `staff` (CLB sở hữu) hoặc `admin` (khi tạo/xoay mã QR mới) | Get: member biết hash hợp lệ hoặc staff của CLB; list: staff đúng CLB/admin; Rules dùng get để kiểm tra khi check-in | `staff` cùng `clubId` hoặc `admin` (vô hiệu mã) | Bị cấm | **Web**: `LiveQrPanelScreen`. |
| `announcements/{announcementId}` | `title` (string <= 120), `body` (string <= 1000), `scope` (string: `'global'`, `'club'`, `'event'`), `clubId` (string?), `clubName` (string?), `eventId` (string?), `authorUid` (string), `authorRole` (string: `'staff'`, `'admin'`), `createdAt` (timestamp) | `staff` (cho CLB/sự kiện của mình); `admin` (toàn hệ thống hoặc bất kỳ CLB nào) | Mọi user đã xác thực | Bị cấm (immutable sau tạo) | Bị cấm | **Mobile**: `A09 NotificationsTabScreen`.<br>**Web**: `ClubAnnouncementsScreen`. |
| `users/{uid}/notifications/{id}` | `title` (string), `body` (string), `type` (string), `eventId` (string), `registrationId` (string?), `createdAt` (timestamp), `readAt` (timestamp?) | Staff/admin đúng event ghi khi duyệt/từ chối/đổi lịch; owner chỉ tạo push_received với ID push_ + hash hợp lệ | Chỉ chính chủ `uid` (`request.auth.uid == uid`) | Chỉ chính chủ `uid` (chỉ cập nhật trường `readAt = request.time`) | Bị cấm | **Mobile**: `A09 NotificationsTabScreen`. |
| `users/{uid}/devices/{deviceId}` | `fid` (string < 4096), `platform` (string: `'android'`, `'web'`), `updatedAt` (timestamp) | Chính chủ `uid` đăng ký token FCM | Chính chủ `uid` | Chính chủ `uid` | Chính chủ `uid` khi đăng xuất | **Mobile**: `FirebaseCloudServices`. |

---

### Metadata và receipts của mobile Final

| Collection | Fields/types | Create | Read | Update | Delete | Màn |
|---|---|---|---|---|---|---|
| users/{uid}/reports/{id} | fileName:string, mimeType:application/pdf, byteCount:int 1..20MB, rowCount:int 1..10000, createdAt:timestamp | user chủ UID, shape/time hợp lệ | user chủ UID | Cấm | Cấm | ExportScreen; không có URL/path/bytes |
| users/{uid}/announcementReads/{id} | readAt:timestamp | user chủ UID, announcement tồn tại | user chủ UID | user chủ UID, timestamp hiện tại | Cấm | NotificationsTabScreen |
| registrations/{id}/history/{entry} | Hồ sơ legacy chỉ đọc; không tạo từ clients hiện hành | Cấm | Chủ registration hoặc staff/admin theo rule scope | Cấm | Cấm | Lịch sử đã tồn tại nếu có |

## 3. Quy tắc Chuyển đổi Trạng thái Hợp lệ (`Allowed Status Transitions`)

Mọi bước chuyển trạng thái đều được kiểm tra chặt chẽ trong `firebase/firestore.rules`:

### 3.1. Sự kiện (`events.status`)
```mermaid
stateDiagram-v2
    [*] --> draft : CLB tạo trong clubId được phân công
    draft --> pending_approval : CLB gửi đề xuất
    pending_approval --> published : Admin phê duyệt
    pending_approval --> rejected : Admin từ chối kèm lý do
    rejected --> pending_approval : CLB chỉnh sửa và gửi lại
    draft --> archived : Staff/Admin lưu trữ
    published --> cancelled : Staff/Admin hủy (sự kiện dừng tổ chức)
    published --> archived : Staff/Admin lưu trữ (ẩn khỏi khám phá)
    cancelled --> archived : Staff/Admin lưu trữ lịch sử
```
- **Quyền hạn**: Chỉ `staff` sở hữu sự kiện hoặc `admin` được đổi trạng thái sự kiện. `user` không có quyền thay đổi trạng thái sự kiện.

### 3.2. Đơn đăng ký (`registrations.status`)
```mermaid
stateDiagram-v2
    [*] --> pending : User gửi đơn đăng ký mới (generation = 1)
    pending --> approved : Staff/Admin duyệt đơn (activeCount tăng +1)
    pending --> rejected : Staff/Admin từ chối (bắt buộc kèm reason, activeCount giữ nguyên)
    pending --> cancelled : User tự hủy khi chưa duyệt (activeCount giữ nguyên)
    approved --> cancelled : User tự hủy trước giờ bắt đầu (activeCount giảm -1)
    cancelled --> pending : User đăng ký lại (generation tăng +1)
    rejected --> pending : User nộp lại đơn (generation tăng +1, khi sự kiện còn hạn/chỗ)
```
- **Quy tắc ràng buộc nguyên tử (`Atomic Invariants`)**:
  - Khi `pending -> approved`: Transaction bắt buộc tăng `events/{eventId}.activeCount + 1` và bảo đảm `activeCount <= capacity`.
  - Khi `approved -> cancelled`: Transaction bắt buộc giảm `events/{eventId}.activeCount - 1` (chỉ cho phép khi sự kiện chưa bắt đầu và chưa điểm danh).
  - Khi `pending -> rejected`: Bắt buộc `reason` có độ dài từ 3 đến 300 ký tự; `activeCount` không thay đổi.
  - Điểm danh (`checkInAt`): Chỉ cho phép khi đơn đang `approved`, `checkInAt == null`, mã băm `qrHash` khớp với `qrCredentials` hợp lệ và `checkinSessions.open == true`.

---

## 4. Kiểm thử Mô hình Dữ liệu & Security Rules

Các ca hiện có nằm ở `firebase/tests/direct-firestore.test.js`. Kết quả local và khoảng trống ở `docs/test-report.md`; cần rà matrix allowed/denied cho mỗi role/collection trước nộp, không suy ra đủ coverage chỉ từ số nhóm test.

### Ràng buộc shape sau matrix Final

Self-update users: displayName/email phải là string với giới hạn120/254, không đổi role; updatedAt khi thay đổi dùng server timestamp. Events create/metadata update: startsAt/endsAt timestamp, endsAt>startsAt; required có deadline timestamp trước startsAt; free không bắt deadline. Client form đã kiểm tra cùng ràng buộc. Cases hợp lệ và sai kiểu/ngày được kiểm thử trong Appendix B matrix.

## Phân công đại diện CLB qua email
Xem [club-onboarding.md](club-onboarding.md). `clubAssignments/{email}` lưu phân công chờ/kích hoạt/thu hồi; `clubManagerSlots/{clubId}` giữ chỗ duy nhất cho phân công qua email. Admin quản lý; người nhận chỉ get đúng email đã xác minh và ghi requestedUid/requestedAt để chờ kích hoạt. Chỉ Admin khác UID cấp staff bằng transaction hồ sơ + phân công (acceptedBy/acceptedAt), không có ngoại lệ tự đổi role. Không dùng mobile để khởi tạo tài khoản CLB.
