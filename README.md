# Hiếu Gamer Chess AI – app iOS (WebView + menu đè lên bàn cờ)

App mở Chess.com trong WebView và tự chèn menu **Hiếu Gamer Chess AI** (file `chess_ai.js`) vào mọi trang.
Menu là nút tím nổi ở góc phải dưới; bấm vào để mở bảng điều khiển đè lên bàn cờ.

## Build ra file .ipa bằng GitHub (không cần Mac)

1. Tạo repo mới trên github.com, rồi **Add file → Upload files** và tải lên TẤT CẢ file trong thư mục này
   (`HieuGamerApp.swift`, `ChessWebView.swift`, `chess_ai.js`, `icon-1024.png`, `Info.plist`, `project.yml`, `build-ipa.yml`, `README.md`).
2. Chuyển workflow vào đúng chỗ: mở file `build-ipa.yml` → bấm biểu tượng bút chì → ở ô tên file, đổi thành
   `.github/workflows/build-ipa.yml` → **Commit changes**.
   (Trên máy tính: tạo thư mục `.github/workflows` rồi bỏ file vào.)
3. Vào tab **Actions** → **Build IPA** → **Run workflow**. Chờ khoảng 5–10 phút.
4. Mở lần chạy vừa xong → mục **Artifacts** → tải `HieuGamerChessAI-ipa` (bên trong là `HieuGamerChessAI.ipa`).

## Cài lên iPhone

File .ipa **chưa ký**. Dùng Sideloadly, AltStore, eSign hoặc TrollStore để ký và cài.
Apple ID miễn phí thì app hết hạn sau 7 ngày, cần cài lại.

## Tùy chỉnh

- Trang mở đầu: sửa `startURL` trong `ChessWebView.swift`.
- Menu và logic: sửa `chess_ai.js`.
- Tên app trên màn hình chính: `CFBundleDisplayName` trong `Info.plist`.
- Bundle ID: `PRODUCT_BUNDLE_IDENTIFIER` trong `project.yml`.

## Lưu ý

- Cần có mạng: Stockfish được tải từ unpkg / jsdelivr khi mở menu lần đầu.
- Chưa thử build trên máy thật. Nếu Actions báo lỗi, gửi log cho mình để sửa.
