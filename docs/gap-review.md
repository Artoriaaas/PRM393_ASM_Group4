# Gap review Final — cập nhật 13/11/2026

## Phần tự động đã xác nhận

- Mobile86/86, web40/40, core6/6; analyze cả3package sạch. Web production build thành công.
- Security Rules55/55 gồm16top-level groups và39subtests; JUnit52case lá+3role suites,0failure/skip. [Matrix](security-rules-matrix.md), [JUnit](../evidence/rules/final-matrix.xml). Kiểm tra quyền/chuyển trạng thái và shape profile/dates; không sửa production data trong test.
- Rules/indexes và web mới đã deploy: https://eventhub-group4.web.app. HTTP200 không chứng minh chức năng/đăng nhập thành công.
- AI dùng Firebase AI Logic SDK, JSON/schema, preview/apply/edit, chặn PII từ form bằng input chủ đề có sẵn, lỗi tiếp tục nhập tay; RC force-fetch trên explicit action. Cloud RCv6 bật model gemini-3.5-flash-lite, AI Logic App Check ENFORCED.
- Web Enterprise/Android Play Integrity registered, TTL1giờ. Không đưa site key/token/config local vào Git. Slides nhóm giữ nguyên.

## Cần người dùng mở app để xác nhận

| Phần | Chưa đủ | Cách hoàn thành |
|---|---|---|
| Mobile/web | Native flows/states, QR/PDF/share, web main actions và empty/error/loading | Theo docs/final-live-verification.md, lưu evidence/final-live |
| AI | 3output thật+1failure/RCoff; Console Analytics | Dùng web Hosted role staff; preview/apply/edit; không lấy mock tests làm proof |
| Cross-role | 3lượt deployment và số đo độ trễ | Mobile pending→web queue→staff approve/reject→mobile/inbox, video2client |
| App Check | Android debug token0, chưa có request verified Web/Android trong lần quan sát; Firestore UNENFORCED | Mở app debug, node tool/register-android-appcheck.cjs DEVICE; dùng cả2client rồi node tool/check-cloud.cjs; chốt enforcement sau verified requests |

Lần cloud audit lưu timestamp và số đếm thật trong evidence/cloud-readiness/config-status.json; cửa sổ24giờ thấy24Firestore INVALID/UNKNOWN. Không suy ra verified chỉ từ registered. Không có thiết bị ADB kết nối trong đợt chuẩn bị, nên không thể đăng ký token thiết bị hoặc kiểm thử native thay người dùng. Không hạ AI enforcement để vượt lỗi.

## Ngoài phạm vi 5mục đang chốt

ARTEMIS Final chưa có pass (bộ cũ25ca×3 đều skipped), AI review/PR và fix commit evidence, report10–15trang, slides12–15, video8–12phút, README demo accounts/Admin/ID/video và Figma cần chốt trước nộp. Không sửa slides nhóm, không rewrite lịch sử, không tạo screenshot/test output giả. Source sửa mới đang working tree, chưa commit/push.

[Đối chiếu đề](final-requirements.md) · [Chạy thật từng bước](final-live-verification.md) · [Test report](test-report.md).
