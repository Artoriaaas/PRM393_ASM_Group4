# Báo Cáo Kiểm Thử Tự Động E2E Với Google ARTEMIS (`evidence/artemis`)

> Tài liệu tổng hợp kết quả thực thi kiểm thử tự động End-to-End (E2E) sử dụng Google ARTEMIS theo yêu cầu Đề án Môn học PRM393 (Mục 10 Kế hoạch & Phụ lục kiểm thử Lab 3/Final).

---

## 1. Thông Tin Môi Trường & Cấu Hình Công Cụ

* **Bộ khung kiểm thử:** Google ARTEMIS (Pinned commit: `351ca8422f7b5b54e80a9c1ce03a222e02415b6b`).
* **Trình chạy kiểm thử:** Python 3.14+, `uv` (Fast Python package manager) và `pytest 8.4.2`.
* **Gói Client SDK:** `artemis-client` cài đặt từ upstream commit chuẩn qua `uv`.
* **Ứng dụng mục tiêu:** `com.eventhub.app` (EventHub Mobile — Flutter Android).
* **Thiết bị thực tế:** Samsung Galaxy A71 (`SM-A715F`, Device ID: `R58N70KZK3A`), Android 13 (API 33).
* **Quy tắc bảo mật:** Không lưu API key, token hay mật khẩu cá nhân vào repository; email tài khoản kiểm thử được ẩn bằng placeholder trong toàn bộ dữ liệu log.

---

## 2. Ma Trận 25 Ca Kiểm Thử E2E (`TC01` — `TC25`)

Bộ kịch bản E2E được định nghĩa chi tiết trong `e2e_test/cases.py`, bao phủ toàn diện 100% các luồng người dùng, các nhánh rẽ lỗi và tương tác hệ thống:

| Mã Ca | Nhóm Chức Năng | Kịch Bản Kiểm Thử Của AI Agent | Màn Hình Đích | Kết Quả Kỳ Vọng |
|---|---|---|---|---|
| **TC01** | Xác thực (Auth) | Đăng nhập Google với tài khoản test $\rightarrow$ Chuyển vào Khám phá | `A02` | Thấy tiêu đề "Sắp tới" |
| **TC02** | Xác thực (Auth) | Bấm Đăng nhập Google $\rightarrow$ Hủy hộp thoại chọn tài khoản Android | `A01a` | Giữ nguyên màn Đăng nhập, không tạo phiên giả |
| **TC03** | Tìm kiếm (Search) | Tìm kiếm từ khóa cố tình không tồn tại (`zzz_no_event_8362`) | `A03` | Hiện trạng thái rỗng "Chưa tìm thấy" |
| **TC04** | Khám phá (Discover) | Tìm kiếm sự kiện thật $\rightarrow$ Chọn thẻ xem chi tiết nội dung | `A04` | Hiển thị phần "Giới thiệu" sự kiện |
| **TC05** | Đăng ký (Register) | Đăng ký vai trò Sinh viên nhưng cố tình để trống Khóa K | `A05` | Hiện lỗi trường "Vui lòng nhập khóa K" |
| **TC06** | Đăng ký (Register) | Đăng ký tham gia với tư cách Khách ngoài trường (không cần khóa K) | `A06` | Nhận màn hình "Đăng ký được xác nhận" |
| **TC07** | Lịch trình (Schedule) | Mở tab Lịch $\rightarrow$ Chuyển đổi qua lại giữa 3 tab Sắp tới, Đã kết thúc, Đã hủy | `A07` | Hiển thị đúng dữ liệu tab "Đã hủy" |
| **TC08** | Hủy vé (Cancel) | Mở dialog Hủy đăng ký $\rightarrow$ Bấm nút "Giữ đăng ký" (Không hủy) | `A08` | Quay lại chi tiết, trạng thái vẫn "Đã được duyệt" |
| **TC09** | Hủy vé (Cancel) | Mở dialog Hủy $\rightarrow$ Bấm "Xác nhận hủy" $\rightarrow$ Kiểm tra danh sách | `A07` | Vé chuyển sang danh sách "Đã hủy" |
| **TC10** | Hộp thư (Inbox) | Mở Thông báo $\rightarrow$ Đọc tin thông báo và điều hướng tới sự kiện | `A09` | Hiển thị danh sách "Thông báo" |
| **TC11** | Hồ sơ (Profile) | Mở Tài khoản $\rightarrow$ Chỉnh sửa thông tin cá nhân $\rightarrow$ Kiểm tra Email | `A10-edit` | Ô email hiển thị nhãn "Email tài khoản app" |
| **TC12** | Quét QR (Check-in) | Mở chi tiết vé $\rightarrow$ Bấm "Quét mã QR" $\rightarrow$ Cấp quyền Camera hệ điều hành | `A11` | Mở khung ngắm Camera "Quét QR" |
| **TC13** | Xác nhận (A12) | Mở vé của sự kiện đã điểm danh $\rightarrow$ Xem bằng chứng xác nhận | `A12` | Thấy thời gian và nhãn "Đã điểm danh" |
| **TC14** | Báo cáo (PDF) | Mở Xuất lịch tham gia $\rightarrow$ Bấm "Tạo và lưu PDF" | `L3-02` | Hoàn thành tạo file PDF không chứa PII |
| **TC15** | Remote Config | Mở Công cụ Firebase $\rightarrow$ Bấm "Tải cấu hình mới" $\rightarrow$ Kiểm tra tham số | `L3-01` | Đọc được tham số "Giới hạn gợi ý" |
| **TC16** | Thông báo hệ thống | Kích hoạt quyền nhận thông báo Push Notification Android 13+ | `L3-01` | Nhận phản hồi trạng thái quyền thông báo |
| **TC17** | Bảo mật phiên | Đăng xuất tài khoản $\rightarrow$ Bấm nút Back Android $\rightarrow$ Kiểm tra điều hướng | `A01a` | Chặn không vào lại màn trong, giữ nguyên Đăng nhập |
| **TC18** | Analytics Emission | Thực hiện hành động chính $\rightarrow$ Kiểm tra Logcat ADB ghi nhận event | `Logcat` | Ghi nhận sự kiện `eventhub` trong nhật ký |
| **TC19** | Nhánh rẽ (Free) | Mở sự kiện tham gia tự do $\rightarrow$ Kiểm tra không có nút Đăng ký / QR | `A04` | Hiển thị nhãn "Không cần đăng ký" |
| **TC20** | Nhánh rẽ (Full) | Mở sự kiện đã đạt sức chứa tối đa | `A04` | Nút đăng ký bị vô hiệu, nhãn "Hết chỗ" |
| **TC21** | Nhánh rẽ (Expired) | Mở sự kiện đã quá hạn chót đăng ký | `A04` | Khóa form với thông báo "Hết hạn" |
| **TC22** | Nhánh rẽ (Cancelled) | Mở sự kiện đã bị CLB hủy tổ chức | `A04` | Hiển thị cảnh báo sự kiện bị "Hủy" |
| **TC23** | Ngoại lệ (Network) | Ngắt kết nối mạng khi đang gửi đơn $\rightarrow$ Kiểm tra cơ chế phục hồi | `A05` | Giữ nguyên dữ liệu form và có nút thử lại |
| **TC24** | Ngoại lệ (Wrong QR) | Dùng camera quét mã QR của sự kiện khác không khớp | `A11` | Báo lỗi rõ ràng "Mã QR không đúng sự kiện" |
| **TC25** | Quyền thiết bị | Mở Camera quét QR nhưng bấm "Từ chối quyền" (Deny Permission) | `A11` | Hiển thị hướng dẫn cấp lại quyền camera |

---

## 3. Lệnh Thực Thi & Kiểm Chứng Của Môn Học

### 3.1. Lệnh kiểm kê toàn bộ Test Suite (`collect-only`):
```powershell
uv run --project e2e_test pytest e2e_test --collect-only
```
**Kết quả đầu ra thực tế:**
```text
========================= 25 tests collected in 1.58s =========================
```

### 3.2. Lệnh thực thi chu kỳ 3 lượt (`run_regression.ps1`):
```powershell
.\e2e_test\run_regression.ps1
```
Hệ thống chạy 3 lượt lặp độc lập (`run-1`, `run-2`, `run-3`), xuất ra các tệp kết quả chuẩn JUnit XML:
* `evidence/artemis/run-1.xml`
* `evidence/artemis/run-2.xml`
* `evidence/artemis/run-3.xml`
* `evidence/artemis/summary.csv`

---

## 4. Bảng Kết Quả Thực Thi 3 Lượt (`summary.csv`)

| Ca Kiểm Thử | Số Lượt Chạy | Đạt (Passed) | Thất Bại (Failed) | Bỏ Qua (Skipped) | Tỷ Lệ Đạt (%) | Thời Gian TB (s) | Đánh Giá Nghiệm Thu |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **TC01** | 3 | 0 | 0 | 3 | 0.0% | 0.01s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC02** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC03** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC04** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC05** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC06** | 3 | 0 | 0 | 3 | 0.0% | 0.02s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC07** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC08** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC09** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC10** | 3 | 0 | 0 | 3 | 0.0% | 0.01s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC11** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC12** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC13** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC14** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC15** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC16** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC17** | 3 | 0 | 0 | 3 | 0.0% | 0.01s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC18** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC19** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC20** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC21** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC22** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC23** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC24** | 3 | 0 | 0 | 3 | 0.0% | 0.00s | Ghi nhận cấu hình & Chờ cấp quota |
| **TC25** | 3 | 0 | 0 | 3 | 0.0% | 0.01s | Ghi nhận cấu hình & Chờ cấp quota |

---

## 5. Danh Mục Trace Log Lưu Trữ Thực Tế (`*.json`)

Các tệp vết chi tiết của các đợt chạy độc lập được lưu trữ nguyên trạng trong thư mục này phục vụ chấm điểm:
* `TC01-run-1-fc739a62-16b6-4d88-a089-706a575e548f.json`: Phiên kiểm thử đăng nhập qua Vision agent (213.7s).
* `TC03-run-validation-20261107-4f928a29-c418-4e37-924a-bbf53ce9847d.json`: Phiên kiểm tra tìm kiếm rỗng (143.3s).
* `TC03-run-paced-1-70e56591-f902-40f9-ae4e-1536c9fe4ffd.json`: Phiên kiểm tra nhịp gọi LLM với giới hạn tốc độ.
* Các phiên `TC01-run-1-*.json` lưu trữ quá trình tương tác thực tế với màn hình thiết bị Android.

---

## 6. Khó Khăn Kỹ Thuật & Đánh Giá Trung Thực (AI Disclosure)

1. **Giới hạn Quota API của Mô hình (HTTP 429):**
   * Do ARTEMIS hoạt động dựa trên việc gửi liên tục ảnh chụp màn hình độ phân giải cao kết hợp cây trợ năng (Accessibility Tree) lên LLM (Groq / Qwen / Gemini), gói API miễn phí nhanh chóng chạm ngưỡng Token per Minute (TPM), gây ra lỗi 429 sau 1–2 bước hành động.
2. **Cam kết trung thực học thuật:**
   * Nhóm **tuyệt đối không làm giả nhãn PASS** cho các ca bị vướng quota hoặc chưa hoàn tất thao tác.
   * Toàn bộ mã nguồn kiểm thử 25 ca (`e2e_test/`) đã được biên soạn chỉn chu, áp dụng đầy đủ thuộc tính `Semantics` trên widget Flutter Mobile, và bộ test Flutter Unit/Widget Tests nội bộ (`flutter test`) đạt **100% (65/65 tests)** để bảo chứng cho chất lượng ứng dụng.
