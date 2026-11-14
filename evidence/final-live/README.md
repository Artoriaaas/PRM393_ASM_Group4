# Bằng chứng chạy thật Final — chờ thực hiện

Không thay thế kết quả cloud bằng unit/widget test. Lưu ảnh/video thực tế vào các thư mục tương ứng, bỏ PII/token khỏi bản công bố; giữ bản gốc riêng nếu cần đối chiếu.

| Mục | Bằng chứng cần lưu | Trạng thái |
|---|---|---|
| Web actions | sign-in/role rejection, management, review, dashboard, announcement | Chưa chạy xác nhận |
| Web states | ảnh loading/empty/error và retry các màn tải dữ liệu | Chưa đủ |
| Mobile | flow/state Lab2, PDF/native share, QR thật, logout/privacy | Chưa chốt binary Final |
| AI1/2/3 | đầu vào chủ đề, output thật, model/RC version, preview/apply/edit | Chưa có |
| AI error/off | RC off/ảnh lỗi, form vẫn hoạt động; trả RC về true sau thử | Chưa có |
| AI Analytics | ai_request / ai_result_accepted / ai_error | Chưa có Console proof |
| Cross-role run1/2/3 | video hai client + độ trễ và cách đo | Chưa có đủ |
| App Check | request verified Web+Android; enforcement Firestore+AI | Chưa đủ |

Read-only cloud audit: ../cloud-readiness/config-status.json. Rules JUnit: ../rules/final-matrix.xml. Checklist: ../../docs/final-live-verification.md. Không đếm config registered hoặc HTTP200 là Gemini/cross-role pass.
