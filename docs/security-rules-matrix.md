# Appendix B — ma trận Security Rules

Đã chạy trên Firestore emulator `demo-direct-booking`, không thay đổi production data. JUnit thật: [final-matrix.xml](../evidence/rules/final-matrix.xml). Node báo55 tests đạt,0fail,0skipped (JUnit lưu52 testcase lá và3 role suites): 16 test cấp cao nhất (12 nhóm hiện hữu +3 nhóm role +1 nhóm anonymous/unverified), trong đó 3 nhóm role có 39 subtests. Không đếm 55 là 55 kịch bản cloud.

`A/D` = ca cho phép và ca từ chối trong test; `N/A` = policy không có thao tác cho phép cho role đó, chỉ kiểm tra deny. Tạo fixture bằng Admin test environment chỉ trong emulator, không phải khả năng ghi của client.

| Collection | user | staff | admin |
|---|---|---|---|
| users | A đọc mình / D tự nâng role | A đọc mình / D tự đổi role | A đọc mình / D tự đổi role |
| clubs | A đọc / D xóa | A đọc / D xóa | A đọc / D xóa |
| events | A đọc published/public / D xóa | A đọc published / D xóa | A đọc / D xóa |
| registrations | A đọc mình / D xóa | A đọc đúng scope / D xóa | A đọc / D xóa |
| registrations/history | A lịch sử chính UID / D ghi | A lịch sử chính UID nếu có / D ghi | A lịch sử chính UID nếu có / D ghi |
| checkinSessions | A chủ đăng ký approved đọc / D xóa | A CLB mình đọc / D xóa | A đọc / D xóa |
| qrCredentials | A đọc hash đã biết / D xóa | A đọc / D xóa | A đọc / D xóa |
| announcements | A đọc / D sửa | A đọc / D sửa | A đọc / D sửa |
| users/notifications | A đọc chính UID / D đọc UID khác | A đọc chính UID / D đọc UID khác | A đọc chính UID / D đọc UID khác |
| users/devices | A đọc chính UID / D đọc UID khác | A đọc chính UID / D đọc UID khác | A đọc chính UID / D đọc UID khác |
| users/reports | A đọc/tạo metadata mình / D UID khác, sửa | N/A allow; D đọc/tạo kể cả chính UID | N/A allow; D đọc/tạo kể cả chính UID |
| users/announcementReads | A đọc/ghi receipt mình / D UID khác, xóa | N/A allow; D đọc/ghi | N/A allow; D đọc/ghi |
| Collection không khai báo | D đọc/ghi | D đọc/ghi | D đọc/ghi |

Ngoài matrix tối thiểu, 12 nhóm chức năng kiểm tra ghi hợp lệ/không hợp lệ: bootstrap role user; Admin gán role cho người khác; CLB tạo/sửa/archive đúng clubId; draft→pending→Admin approve/reject; chặn CLB tự publish; pending→approved/rejected với reason/count; cạnh tranh chỗ; cancel/resubmit; legacy records; QR/session/rotation/check-in lặp; announcements theo role; receipts/devices; PDF metadata shape và immutable. Xem tên/assertions trong firebase/tests/direct-firestore.test.js.

Lịch sử đọc chỉ theo chủ UID, không cấp quyền staff đọc lịch sử riêng của người khác. Một tài khoản đổi role có thể vẫn sở hữu lịch sử cũ; matrix không cho staff/admin tự tạo đăng ký mobile mới. Anonymous/unverified bị từ chối các bản ghi ứng dụng thử nghiệm; profile chính mình có ngoại lệ phục vụ bootstrap trước xác nhận email theo source, không tuyên bố deny tuyệt đối ngoại lệ này.

Chạy lại khi emulator 8085 đã mở:

```powershell
$env:FIRESTORE_EMULATOR_HOST="127.0.0.1:8085"
npm test --prefix firebase/tests
```

Nếu chưa mở emulator, chạy terminal riêng:

```powershell
npx --yes firebase-tools@15.34.2 emulators:start --only firestore --project demo-direct-booking
```

Lượt matrix đã bổ sung shape guards cho profile self-update và dates/deadline sự kiện; đã kiểm tra client dùng server timestamp và form có cùng ràng buộc. Rules mới được triển khai sau khi ma trận đạt. Không bật/tắt enforcement App Check bằng unit test.

## Bổ sung phân công CLB qua email

| Collection | Admin | Google account có email đã xác minh | Tài khoản khác / anonymous |
|---|---|---|---|
| clubAssignments/{email} | Get/list; tạo pending kèm slot; thu hồi kèm xóa slot và gỡ staff tương ứng | Get đúng email; pending→accepted chỉ cùng transaction users→staff đúng CLB | Deny |
| clubManagerSlots/{clubId} | Read; tạo kèm pending invitation; delete kèm revoked invitation; không update | Deny đọc/ghi trực tiếp | Deny |
| users/{uid} activation | Giữ chính sách phân quyền hiện có; không tự đổi role; staff không được chiếm CLB đang có slot khác | Chỉ user→staff khi invitation+slot hợp lệ và invitation accepted cùng transaction; không đổi profile khác | Deny |

Bằng chứng: `evidence/rules/club-onboarding.xml`, không phải kiểm thử cloud thật. Phân công email là ngoại lệ có kiểm soát cho bước nhận quyền, không cho người dùng tự chọn quyền.
