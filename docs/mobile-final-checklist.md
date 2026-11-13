# Mobile Final — checklist bàn giao

## Phạm vi

Giữ mọi màn/flow Lab 2 và instrumentation Lab 3; Final thay upload cloud bằng PDF local/native share + metadata Firestore. Mobile chỉ user; CLB/admin dùng web. Giữ nguyên slide nhóm. Không sửa repo Lab 3.

## Có code, phải xác nhận trên thiết bị/cloud

- [ ] Google login/cancel/logout; user được vào; staff/admin bị từ chối; đổi role đang chạy bị chặn.
- [ ] Tìm kiếm/detail/loading/empty/error/retry; Back và các tab.
- [ ] Đăng ký pending → web approve/reject có lý do → mobile cập nhật; pending không quét QR.
- [ ] Hủy pending/approved đúng điều kiện; phục hồi mạng không gửi trùng.
- [ ] Web mở QR → mobile xin camera/quét → xác nhận; sai QR/đóng phiên/quét lặp.
- [ ] Announcements đúng all/club/event; read receipt theo UID; tin riêng không lộ tài khoản khác.
- [ ] PDF khớp preview, lưu local, metadata Firestore, retry metadata không tạo báo cáo mới; native share; logout dọn dữ liệu local.
- [ ] App Check Android được đăng ký và verified; phối hợp web trước enforcement.
- [ ] Analytics params; FCM 3 trạng thái; RC 2 tham số đổi UI; Crashlytics lỗi thật + test crash có UID/key.
- [ ] 360/412dp, text scale, touch target và đối chiếu Figma/traceability.
- [ ] ARTEMIS Final chạy 3 lượt/ca, native/error path và phần mobile cross-role; AI test sau triển khai AI.

Hướng dẫn thao tác: docs/mobile-setup.md. Bằng chứng local: evidence/mobile-final/validation.md. Cross-role 3 lần và độ trễ: docs/cross-role-flow.md. Không tự đánh dấu đạt khi chỉ có code/unit test.

## Phần ngoài mobile

AI có thể ở web hoặc mobile theo đề; chưa triển khai. Web deploy, Rules theo role/collection và bằng chứng cross-role là phần hệ thống dùng chung. Slide/report/video chốt riêng sau khi có bằng chứng.
