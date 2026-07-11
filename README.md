# 🗺️ Trình Kiến Tạo Lộ Trình Học Tập Tương Tác (Interactive Learning Roadmap Builder)

Ứng dụng web tối tân giúp lập và thiết kế các lộ trình học tập, giáo trình, hoặc bản đồ công nghệ theo từng bước trực quan. Được tối ưu hóa cho màn hình điện thoại di động và giao diện nhỏ gọn với bố cục **Zig-zag** đẹp mắt và có hệ thống trực quan rõ ràng.

---

## ✨ Các Tính Năng Nổi Bật

### 1. Bố Cục Zig-zag Trực Quan & Gọn Gàng
*   **Trình bày Zig-zag xen kẽ**: Các bước học được sắp xếp đối xứng hai bên đường kẻ trục dọc của lộ trình, tạo cảm giác nhịp điệu và bao quát tốt.
*   **Tối ưu hóa khung hình**: Thẻ bước học được thu gọn tinh tế để vừa vặn khoảng 3 bước trong một khung hình, giúp người dùng dễ dàng theo dõi toàn bộ tiến trình.
*   **Trạng thái màu sắc**: Thẻ tự động thay đổi viền và hiệu ứng phát sáng dựa trên trạng thái học tập (**Chưa học**, **Đang học**, **Đã xong**).

### 2. Minh Họa Unsplash Động Theo Từ Khóa
*   **Tự động nhận diện**: Ứng dụng tự động phân tích tiêu đề khái niệm (ví dụ: `variable`, `oop`, `javascript`, `python`, `machine learning`, `html`,...) để lấy hình minh họa công nghệ cao, sắc nét và nghệ thuật nhất từ Unsplash.
*   **Giao diện sống động**: Đảm bảo mọi khái niệm đều đi kèm hình ảnh truyền cảm hứng học tập mạnh mẽ.

### 3. Cửa Sổ Chi Tiết Khái Niệm Tiện Lợi (Step Detail Drawer)
*   **Kích hoạt dễ dàng**: Kích vào **bất kỳ khu vực nào** trên khung bước đều ngay lập tức mở ra cửa sổ chi tiết khái niệm.
*   **Nút "Quay lại" tiện lợi**: Thiết kế nút quay lại (`← Quay lại`) nổi bật và nhanh chóng, giúp quay về màn hình bao quát lộ trình tức thì.
*   **Học liệu đi kèm**: Nơi đính kèm tài liệu tham khảo, liên kết tự học, danh sách khái niệm con cần ghi nhớ, và cho phép chỉnh sửa nhanh chóng.

### 4. Thiết Lập Yêu Cầu Tiền Quyết (Prerequisites)
*   **Kết nối thông minh**: Cho phép tạo các mối quan hệ logic giữa các bước (ví dụ: Bước 2 yêu cầu hoàn thành Bước 1 trước).
*   **Quản lý liên kết**: Thêm/xóa các liên kết tiền quyết trực tiếp trong bảng chi tiết hoặc giao diện cấu trúc để xây dựng bản đồ kỹ năng khoa học.

---

## 🛠️ Công Nghệ Sử Dụng

*   **React 18 + Vite** (TypeScript) làm nền tảng ứng dụng SPA siêu nhanh.
*   **Tailwind CSS** cho giao diện hiện đại với hệ màu Slate/Indigo/Emerald thời thượng.
*   **Lucide React** cung cấp kho biểu tượng vector trực quan, sắc nét.
*   **Durable Client State** giúp lưu trữ lộ trình an toàn trong suốt phiên trải nghiệm.

---

## 🚀 Hướng Dẫn Phát Triển Lắp Đặt

### Cài đặt dependencies:
```bash
npm install
```

### Chạy ở chế độ Development:
```bash
npm run dev
```

### Build cho Production:
```bash
npm run build
```
