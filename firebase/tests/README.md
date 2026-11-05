# Firestore Rules tests

Chạy từ thư mục gốc repo, chỉ dùng project emulator `demo-direct-booking`:

```powershell
npm ci --prefix firebase/tests
npx firebase-tools emulators:exec --only firestore --project demo-direct-booking "npm test --prefix firebase/tests"
```

Không cần billing hoặc key cloud. Test tự tạo/xóa fixture trong emulator. Các test kiểm tra quyền theo tài khoản, đăng ký/hủy nguyên tử và QR. Không deploy Functions.
