# Instrumentation evidence — 07/11/2026

Computer-use @oai/sky/node_repl và cua_repl cùng thất bại khởi tạo: failed to write kernel assets: The system cannot find the path specified (os error 3). Không truy cập được phiên Console qua UI trong lượt này, không tạo screenshot Console giả.

ADB FA/FA-SVC logcat đọc được nhưng không có dòng event phù hợp trong buffer hiện tại, xem logcat-event-audit.json. Không suy ra SDK hỏng hoặc server nhận event từ dữ liệu rỗng.

Chưa xác nhận: FCM foreground/background/terminated + lịch sử/tap; DebugView từng event; Crashlytics nonfatal thực + test crash/UID/key; Remote Config trước/sau thay 2 tham số. Một ảnh fetch cũ tại evidence/cloud không hoàn thành cả mục.

Cần khôi phục công cụ desktop/browser hoặc chủ dự án tự chụp Console trong phiên đăng nhập của mình. Không cần tạo thêm key hoặc bật billing chỉ để chụp ảnh.
