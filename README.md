# Học Mẹo - Flutter Mobile Application

Ứng dụng di động học tập theo lộ trình **Học Mẹo**, được phát triển bằng **Flutter 3.x (Dart)** kết hợp với kiến trúc quản lý trạng thái **Provider**.

---

## Tính Năng Chính (Key Features)

1. **Khám Phá Lộ Trình (Roadmap & Topics Exploration)**:
   - Danh sách các chủ đề (Topics) phân theo cấp độ (Beginner, Intermediate, Advanced) và danh mục (Categories/Tags).
   - Thống kê thời gian ước tính, tiến độ hoàn thành % và các mốc học tập.

2. **Học Theo Bài Viết & Bài Học (Lessons & Blogs)**:
   - Cấu trúc bài học rõ ràng kèm theo các khối nội dung đa dạng (Lý thuyết, Mã minh họa, Ghi chú).

3. **Thực Hành Tương Tác & Bài Tập Trắc Nghiệm (Steps & Interactive Quizzes)**:
   - Làm bài tập trắc nghiệm trực tiếp dưới mỗi Step.
   - Phản hồi kết quả thông minh, thông báo chính xác đáp án và lý do sai khi làm bài.

4. **Theo Dõi Tiến Độ & Chuỗi Ngày Học (Streak & XP Rewards)**:
   - Tính toán chuỗi ngày học liên tục (Streak Days).
   - Cộng điểm thưởng XP và lưu trạng thái hoàn thành đồng bộ với Spring Boot Backend.

5. **Đồng Bộ Dữ Liệu Chế Độ Kép (Dual Data Mode - REST & Offline Fallback)**:
   - Tự động kết nối và đồng bộ trực tiếp với Spring Boot Backend REST API (`http://localhost:5001/api/v1`).
   - Tự động chuyển sang chế độ dữ liệu nạp sẵn khi mất kết nối mạng, đảm bảo trải nghiệm liền mạch cho học viên.

---

## Kiến Trúc Mã Nguồn (Code Architecture)

```
lib/
├── models/                     # Data Entities & JSON Serialization
│   ├── category.dart
│   ├── tag.dart
│   ├── topic.dart
│   ├── lesson.dart
│   ├── step_item.dart
│   ├── quiz_question.dart
│   └── user.dart
│
├── providers/                  # Application State & Business Logic
│   ├── auth_provider.dart      # Đăng nhập, lưu Token & phiên làm việc
│   └── roadmap_provider.dart   # Fetch Topic, tính toán tiến độ, submit Quiz & Streak
│
├── screens/                    # Giao diện chính các màn hình
│   ├── home_screen.dart        # Màn hình trang chủ & Tiến độ cá nhân
│   ├── explore_screen.dart     # Khám phá danh sách Lộ trình
│   ├── topic_detail_screen.dart# Chi tiết Topic & Danh sách Bài học (Blog)
│   ├── lesson_detail_screen.dart# Chi tiết Bài học, Step & Trắc nghiệm Quiz
│   ├── profile_screen.dart     # Thông tin học viên, Chuỗi ngày & Cài đặt
│   └── login_screen.dart       # Đăng nhập hệ thống
│
├── services/                   # Kết nối mạng & REST API Client
│   └── api_service.dart
│
└── utils/                      # Constants, App Colors, Styles & Helpers
    └── app_theme.dart
```

---

## Hướng Dẫn Chạy Ứng Dụng (Getting Started)

### 1. Yêu cầu hệ thống:

- Flutter SDK `>= 3.11.5`
- Dart SDK `>= 3.0.0`
- Android Studio / VS Code (đã cài Flutter Extension)
- Thiết bị ảo (Emulator) hoặc thiết bị thật (Android / iOS)

### 2. Cài đặt phụ thuộc:

```bash
flutter pub get
```

### 3. Khởi chạy ứng dụng:

```bash
flutter run
```

---

## ⚙️ Cấu Hình Kết Nối API Backend

Mặc định ứng dụng kết nối tới Spring Boot Backend tại:

- **Android Emulator**: `http://10.0.2.2:5001/api/v1`
- **iOS Simulator / Local**: `http://localhost:5001/api/v1`
- **Production Server**: Thay đổi `baseUrl` trong `lib/services/api_service.dart`.
