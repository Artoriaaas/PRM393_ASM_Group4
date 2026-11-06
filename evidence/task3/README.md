# Bằng chứng nhiệm vụ 3 — kiểm kê ngày 07/11/2026

Chủ dự án xác nhận đã test toàn bộ chức năng trong chat. Đây là lời xác nhận của người thử, chưa có bộ ảnh/video tương ứng được lưu để người chấm kiểm chứng. Các ô dưới chỉ đánh dấu khi đã có file thật.

| Yêu cầu | Bằng chứng cần bổ sung | Trạng thái |
|---|---|---|
| Navigation/3 flow/Back | navigation-f1.mp4, navigation-f2.mp4, navigation-f4a.mp4 hoặc bộ ảnh có thứ tự | Chưa lưu |
| Loading/empty/error/retry | states-<screen>-loading.png, empty.png, error.png cho mỗi màn tải dữ liệu | Chưa đủ; không tạo ảnh lỗi giả |
| Nguồn Firestore | firestore-events.png và firestore-own-registration.png, thấy project ID và che PII | Chưa lưu bộ cuối |
| PDF từ nội dung đang xem | export-preview.png, report.pdf, upload-progress.png, upload-success.png, cloud-file.png | Chưa lưu lượt Android cuối |
| Khu demo Profile | firebase-demo.png | Có ảnh fixture cũ D03, chưa thay bằng Android thật |
| Thay đổi thiết kế | Cặp Figma/app cho từng Dxx cùng lý do trong docs/design-traceability.md | D03/D08 có fixture; D11 có ảnh Android; phần còn lại chưa đủ |
| Chấp thuận Cloudinary | lecturer-storage-substitution.md hoặc ảnh xác nhận đã che thông tin riêng | User-reported, chưa có xác nhận lưu trong repo |
| Giữ Figma, báo cáo thay đổi qua slide | lecturer-design-exception.md nếu thầy đồng ý | Chưa được xác nhận; yêu cầu cập nhật Figma gốc còn mở |

Có sẵn: ../design-changes/D11-discover-filters/after-android.png và before-android.png (thay đổi cũ); ../cloud/remote-config-fetch-android.png (chỉ chứng minh fetch, không chứng minh thay đổi cả hai tham số). Các ảnh component_preview/ui-prototype/*-ui-fixture chỉ dùng minh họa layout, không là bằng chứng cloud.

## Cách lưu lượt test vừa chạy

Đặt ảnh/video đúng thư mục này hoặc liên kết tới vị trí thật; giữ màn hình đầy đủ để biết đang ở đâu. Ghi ngày, phiên bản commit app, Android device và bước test. Che email/tên/token/QR khi không cần cho việc chứng minh. Đừng chia sẻ URL PDF có dữ liệu riêng. Không đổi file thành pass chỉ dựa vào tên.

## Câu hỏi cần thầy chốt

Nhóm đã ghi từng thay đổi Figma–app và lý do, kèm ảnh trước/sau trong design-traceability và báo cáo/slides. Nhóm có được giữ nguyên Figma Lab 2 thay cho cập nhật Figma như mục 3 không? Nếu được, lưu xác nhận cùng bài nộp; nếu không, cần cập nhật thiết kế.

## Phạm vi

Đây chỉ là mục 3, không đưa thêm yêu cầu web/admin/Functions vào checklist. Quyền riêng tư Cloudinary của mục 6 vẫn chưa hoàn tất dù upload có thể thành công.
