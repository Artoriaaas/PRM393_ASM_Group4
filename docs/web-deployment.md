# Đồng bộ main với Firebase Hosting

Workflow `.github/workflows/deploy-web.yml` kiểm tra core/web và Firestore Rules, rồi build/deploy khi push main chạm web, shared core, firebase hoặc workflow. PR chỉ kiểm thử, không nhận deploy secrets. Có thể chạy bằng Actions → Test and deploy EventHub Web → Run workflow → main. Push chỉ sửa slides/docs không deploy lại app.

## Cấu hình một lần trên GitHub

Repo → Settings → Secrets and variables → Actions → New repository secret:

1. `FIREBASE_WEB_ENV_JSON`: nội dung file local `web/web_env.json` đã dùng build đúng project eventhub-group4. Không đưa file lên Git, không gửi key vào chat.
2. `FIREBASE_SERVICE_ACCOUNT_EVENTHUB_GROUP4`: JSON key của service account chuyên deploy project eventhub-group4 (không dùng tài khoản cá nhân hoặc khóa của app mobile).

GitHub Environment `firebase-production` có thể đặt required reviewers nếu trường/nhóm muốn duyệt trước deploy. Nếu dùng environment secrets thì tạo hai secrets cùng tên trong environment đó.

## Service account

Tạo service account riêng, ví dụ `github-eventhub-deploy`, trong Google Cloud project eventhub-group4. Chỉ cấp các role cần deploy:

- Firebase Hosting Admin (`roles/firebasehosting.admin`)
- Firebase Rules Admin (`roles/firebaserules.admin`)
- Cloud Datastore Index Admin (`roles/datastore.indexAdmin`)
- Service Usage Consumer (`roles/serviceusage.serviceUsageConsumer`)
- Firebase Viewer (`roles/firebase.viewer`) để CLI đọc project/web app metadata.

Tạo JSON key và đặt vào GitHub Secret nói trên. Không commit JSON, không cấp Owner/Editor. Xóa bản tải về sau khi đã cất an toàn; thu hồi/đổi key khi kết thúc dự án hoặc nghi bị lộ. Có thể thay bằng OIDC/WIF về sau nhưng workflow hiện dùng service-account secret, không yêu cầu Cloud Functions/App Hosting/Blaze.

## Sau mỗi lần sửa

Commit → push main → tab Actions. Job verify chạy trước; verify/build fail thì không deploy. Deploy cập nhật Rules + indexes + Hosting, không sửa data, RC, Auth providers hay App Check enforcement. Rules và Hosting không phải một transaction: nếu deploy bị lỗi giữa chừng, đọc log và chạy lại sau khi sửa.

Link: https://eventhub-group4.web.app . HTTP200 chỉ xác nhận Hosting phục vụ trang; vẫn cần chạy Google login, AI và cross-role thật trên bản mới. Điện thoại không tự cập nhật APK khi push Git.

## Phiên bản

Flutter 3.47.4; Node24; Java21; Firebase CLI15.34.2; Dart dependencies từ pubspec.lock. Các khóa runtime (Google Sign-in/cấu hình Firebase) giữ ngoài source. Action chỉ đưa bản web đã build lên Hosting, không public toàn bộ repo hoặc service-account file.

Tham khảo: https://firebase.google.com/docs/hosting/github-integration và https://github.com/google-github-actions/auth .

## Thiết lập đã thực hiện 14/11/2026
Hai repository secrets đã được cấu hình qua API GitHub; service account chuyên dụng `github-eventhub-deploy@eventhub-group4.iam.gserviceaccount.com` có các role trên. Private key được mã hóa trực tiếp vào GitHub Secret, không lưu ra file hoặc source. Workflow chưa chạy trên GitHub trước khi commit/push; không coi cấu hình secrets là bằng chứng deploy thành công.
