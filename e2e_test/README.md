# ARTEMIS E2E — cần host thật trước khi chạy

SDK được pin commit `351ca8422f7b5b54e80a9c1ce03a222e02415b6b` từ google/artemis. Đã đối chiếu API `ArtemisClient.run`, TaskResult.output/trace_id/succeeded trên source của commit này. Client hiện là remote SDK; daemon/model/device nằm trên host, không tự khởi chạy agent chỉ vì cài client.

Cần: Python ≥3.12, uv, Android/ADB, Artemis daemon đã cấu hình model, app thật và cloud/fixtures đã sẵn sàng. Chưa có ARTEMIS_BASE_URL hoặc host/model được cung cấp trong lần triển khai này; **chưa chạy thiết bị/AI E2E, chưa có pass rate hay exploratory session**.

Thiết lập biến môi trường (không commit giá trị thật): ARTEMIS_BASE_URL, ARTEMIS_TOKEN nếu host có proxy, ARTEMIS_TEST_ACCOUNT_EMAIL, ARTEMIS_EVENT_TITLE, ARTEMIS_DEVICE. Chỉ dùng tài khoản test được chỉ rõ, đã thêm vào Android; không đưa mật khẩu vào prompt. Không expose daemon chưa có xác thực ra Internet.

```powershell
uv sync --project e2e_test
uv run --project e2e_test pytest e2e_test --collect-only
1..3 | ForEach-Object {
  $env:ARTEMIS_RUN = "$_"
  uv run --project e2e_test pytest e2e_test
}
```

Mỗi test xác minh screen code + chữ agent thực sự quan sát, không chỉ trạng thái SUCCESS. SDK result được lưu với trace ID/thời gian ở evidence/artemis; email test được thay bằng placeholder trong JSON. Screenshot/replay của host vẫn cần kiểm tra dữ liệu riêng tư trước khi chia sẻ. Fixtures thiếu được ghi skipped với lý do, không tính pass.

TC19–TC25 bao phủ free/full/expired/cancelled, mạng và QR/quyền camera; cần fixture riêng, không thay backend thật để ép lỗi. TC18 kiểm tra analytics emission bằng ADB debug log sau thao tác mới; vẫn cần ảnh console DebugView theo đề. Bật verbose log FA/FA-SVC trên thiết bị test nếu SDK không ghi event trong log mặc định. Reset debug flag sau test. Không chạy các ca thay đổi đăng ký trên tài khoản người dùng thật. Tài khoản/event test cần cho phép reset trước mỗi lần; fixture đã điểm danh phải được chuẩn bị từ web CLB/backend để TC13 có ý nghĩa.

Sau regression: một session profile Pro 15–30 phút trên host thật, lưu trace/replay và vấn đề tìm thấy. Chưa tự chạy hoặc trả tiền API khi chưa có host/model/credentials của nhóm. Không thay bằng test Flutter/emulator rồi gọi là ARTEMIS.

Exploratory: sau khi host/model/budget sẵn sàng, đặt `ARTEMIS_ALLOW_PRO=1` và chạy `uv run --project e2e_test python e2e_test/explore.py`. Script ghi thời gian thật và không tính đạt nếu dưới 15 phút; chưa thực thi phiên Pro này.
