# Backend dùng chung — Final

Một project eventhub-group4, Firestore và Security Rules; không custom server, Cloud Functions hay Cloud Storage. Mobile và web dùng models/services tại packages/core.

- Schema, vai trò và chuyển trạng thái: [data model](data-model.md).
- Cấu hình teammate/Android/App Check: [mobile setup](mobile-setup.md).
- Test Rules emulator: firebase/tests/README.md. Deploy Rules/indexes bằng tool/deploy-cloud.ps1 sau khi test đạt.
- Event test tạo bằng web staff của đúng clubId; published/public, còn hạn và sức chứa. Không tự gán clubId cho dữ liệu lịch sử hoặc tự chỉnh count để ép pass.
- Mobile tạo pending; web duyệt approved hoặc rejected kèm lý do. Chỉ approved mới quét QR khi web mở phiên.
- Web tạo announcements; mobile inbox cập nhật đúng scope. Thông báo inbox không đồng nghĩa tự động gửi FCM: FCM vẫn kiểm thử riêng bằng Console.
- PDF local/private, chia sẻ theo thao tác, metadata users/{uid}/reports. Không cấu hình Cloudinary.
- Luồng cloud và đo realtime: [cross-role flow](cross-role-flow.md). App Check phải phối hợp cả web và Android trước enforcement.

Không thay kết quả emulator bằng tuyên bố đã kiểm thử production. Chưa chạy cloud thì ghi chưa xác nhận.
