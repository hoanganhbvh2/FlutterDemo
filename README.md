# Học Mẹo — Flutter Mobile Application (`flutter_demo`)

Ứng dụng di động học tập theo lộ trình **Học Mẹo**, được phát triển bằng **Flutter 3.x (Dart)** kết hợp với kiến trúc quản lý trạng thái **Provider** và thiết kế nhận diện thương hiệu **Emerald Green `#4EB748`**.

---

## 1. Tính Năng Nổi Bật (Key Features)

1. **Khám Phá Lộ Trình Học Tập (Roadmap & Topics Exploration)**:
   - Danh sách các chủ đề (Topics) phân loại theo cấp độ (Beginner, Intermediate, Advanced) và danh mục (Categories/Tags).
   - Hiển thị phần trăm tiến độ hoàn thành %, bài học tiếp theo và chứng nhận.

2. **Học Theo Bài Viết & Các Bước Chi Tiết (Lessons & Steps)**:
   - Trình duyệt nội dung đa dạng với các khối lý thuyết, mã minh họa, hình ảnh, video và ghi chú.

3. **Bài Tập Trắc Nghiệm Tương Tác (Interactive Quizzes)**:
   - Làm bài tập trắc nghiệm chọn đáp án dưới mỗi bước học, tự động tính điểm và lưu tiến độ.

4. **Yêu Cầu Nâng Cấp Premium & Kiểm Tra Trạng Thái (Plan Request & Ticket Tracking)**:
   - **Form Đăng Ký**: Học viên gửi thông tin (Họ tên, SĐT, Lý do) nâng cấp tài khoản lên gói Premium trực tiếp tại màn hình Profile.
   - **Lịch Sử & Trạng Thái Ticket**: Thẻ Accordion hiển thị danh sách các ticket học viên đã gửi cùng trạng thái thời gian thực (`DANG CHO DUYET`, `DA DUYET`, `TU CHOI`) và phản hồi từ Admin.

5. **Bộ Nhận Diện Thương Hiệu Học Mẹo**:
   - Màu chủ đạo Emerald Green `Color(0xFF4EB748)`.
   - Trang Login & Register hiển thị Logo Học Mẹo 100x100 căn giữa kèm câu Quote truyền cảm hứng tiếng Anh.

---

## 2. Cấu Trúc Mã Nguồn (Code Structure)

```
flutter_demo/
├── lib/
│   ├── models/                 # Data Classes (User, Topic, StepNode, PlanRequest)
│   ├── providers/              # Provider State Management (RoadmapProvider)
│   ├── screens/                # Giao diện ứng dụng
│   │   ├── home_screen.dart    # Trang chủ & Tiến độ cá nhân
│   │   ├── explore_screen.dart # Khám phá lộ trình
│   │   ├── profile_screen.dart # Thông tin cá nhân & Accordion Plan Request
│   │   ├── login_screen.dart   # Đăng nhập (Logo 100x100 + Quote)
│   │   └── register_screen.dart# Đăng ký (Logo 100x100 + Quote)
│   ├── services/               # ApiClient & HTTP REST Requests
│   └── widgets/                # Reusable UI Widgets (RichContent, Popover)
└── pubspec.yaml
```

---

## 3. Hướng Dẫn Khởi Chạy (Getting Started)

### Yêu cầu môi trường:
- Flutter SDK `>= 3.19.0`
- Dart SDK `>= 3.3.0`
- Android Studio / VS Code (Flutter Extension)

### Cài đặt phụ thuộc:
```bash
cd flutter_demo
flutter pub get
```

### Khởi chạy ứng dụng:
```bash
flutter run
```

---

## 4. Cấu Hình Kết Nối API Backend

Mặc định ứng dụng kết nối tới Node.js Express Backend tại:
- **Android Emulator**: `http://10.0.2.2:5001/api/v1`
- **iOS Simulator / Local**: `http://localhost:5001/api/v1`
- **Production Server**: Thay đổi `defaultBaseUrl` trong `lib/utils/api_config.dart`.
