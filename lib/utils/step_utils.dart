import '../models/roadmap.dart';

List<ChecklistItem> getDefaultChecklist(String title, String stepId) {
  final t = title.toLowerCase();
  List<String> items = [];

  if (t.contains("variable") || t.contains("biến") || t.contains("types") || t.contains("kiểu dữ liệu")) {
    items = [
      "Hiểu khái niệm biến và quy tắc đặt tên trong ngôn ngữ học",
      "Khai báo thuần thục các kiểu dữ liệu cơ bản (String, int, double, bool)",
      "Phân biệt rõ ràng phạm vi sử dụng của var, final và const"
    ];
  } else if (t.contains("operator") || t.contains("toán tử") || t.contains("function") || t.contains("hàm")) {
    items = [
      "Thực hành sử dụng toán tử số học, logic và so sánh",
      "Viết được hàm có tham số bắt buộc và tham số tùy chọn",
      "Sử dụng thuần thục các hàm nặc danh (anonymous) và arrow functions"
    ];
  } else if (t.contains("control flow") || t.contains("rẽ nhánh") || t.contains("loop") || t.contains("vòng lặp")) {
    items = [
      "Sử dụng điều kiện if-else và switch-case để kiểm soát luồng chạy",
      "Viết vòng lặp for và while để xử lý duyệt danh sách",
      "Biết cách thoát vòng lặp bằng break và bỏ qua lượt bằng continue"
    ];
  } else if (t.contains("oop") || t.contains("đối tượng") || t.contains("class")) {
    items = [
      "Nắm rõ 4 tính chất cốt lõi của OOP (Đóng gói, Kế thừa, Đa hình, Trừu tượng)",
      "Tạo được Class chứa thuộc tính, hàm khởi tạo (Constructor) và phương thức",
      "Thực hành kế thừa Class và ghi đè phương thức bằng @override"
    ];
  } else if (t.contains("asynchronous") || t.contains("bất đồng bộ") || t.contains("future") || t.contains("stream")) {
    items = [
      "Hiểu cơ chế hoạt động bất đồng bộ đơn luồng của Event Loop",
      "Sử dụng cú pháp async/await kết hợp Future để xử lý tác vụ chờ đợi",
      "Biết cách lắng nghe luồng dữ liệu liên tục với Stream và StreamController"
    ];
  } else if (t.contains("stateless") || t.contains("stateful") || t.contains("widget")) {
    items = [
      "Hiểu vòng đời (Lifecycle) của một Stateful Widget",
      "Phân biệt khi nào nên dùng Stateless vs Stateful để tối ưu hiệu năng",
      "Sử dụng setState() để cập nhật giao diện động một cách chính xác"
    ];
  } else if (t.contains("layout") || t.contains("row") || t.contains("column") || t.contains("stack") || t.contains("flexbox") || t.contains("grid")) {
    items = [
      "Sắp xếp các thành phần con theo hàng ngang (Row/Flex) hoặc cột dọc (Column)",
      "Căn chỉnh tỉ lệ hiển thị linh hoạt với Expanded, Flexible hoặc Spacer",
      "Xây dựng bố cục xếp đè lên nhau với Stack và định vị bằng Positioned"
    ];
  } else if (t.contains("jdk") || t.contains("jvm") || t.contains("cài đặt") || t.contains("java")) {
    items = [
      "Hiểu vai trò của JDK, JRE và máy ảo JVM trong quá trình chạy mã Java",
      "Cấu hình thành công biến môi trường JAVA_HOME trên hệ điều hành",
      "Viết, biên dịch và chạy thành công chương trình HelloWorld đầu tiên"
    ];
  } else if (t.contains("html") || t.contains("semantic") || t.contains("thẻ ngữ nghĩa")) {
    items = [
      "Nắm vững ý nghĩa của các thẻ ngữ nghĩa chuẩn SEO mới trong HTML5",
      "Tổ chức cấu trúc trang web mạch lạc sử dụng header, nav, main, section, footer",
      "Đảm bảo website có cấu trúc thân thiện với người dùng và các robot đọc màn hình"
    ];
  } else if (t.contains("javascript") || t.contains("js") || t.contains("es6")) {
    items = [
      "Sử dụng thuần thục các cú pháp ES6+ như Arrow function, Destructuring, Spread operator",
      "Xử lý lập trình bất đồng bộ bằng cách sử dụng Promise hoặc Fetch API",
      "Làm quen với các phương thức xử lý mảng hiện đại: map(), filter(), reduce()"
    ];
  } else if (t.contains("python")) {
    items = [
      "Nắm vững cú pháp cơ bản và các cấu trúc dữ liệu List, Dictionary trong Python",
      "Sử dụng thư viện NumPy để thực hiện các phép toán trên mảng đa chiều nhanh chóng",
      "Đọc, làm sạch và phân tích dữ liệu dạng bảng bằng thư viện Pandas DataFrame"
    ];
  } else if (t.contains("regression") || t.contains("classification") || t.contains("machine learning") || t.contains("giám sát") || t.contains("hồi quy")) {
    items = [
      "Hiểu sự khác biệt giữa bài toán Hồi quy (Regression) và Phân loại (Classification)",
      "Chuẩn bị dữ liệu và chia bộ dữ liệu thành tập huấn luyện (Train) và tập kiểm thử (Test)",
      "Huấn luyện và đánh giá mô hình học máy có giám sát sử dụng thư viện Scikit-Learn"
    ];
  } else if (t.contains("prompt") || t.contains("llm") || t.contains("ai") || t.contains("generative")) {
    items = [
      "Hiểu cơ chế hoạt động đằng sau các mô hình ngôn ngữ lớn (LLMs)",
      "Áp dụng thành thạo kỹ thuật Prompt Few-shot để định hướng kết quả trả về",
      "Xây dựng cấu trúc lập luận logic cho AI sử dụng kỹ thuật Chain-of-Thought"
    ];
  } else {
    items = [
      "Nắm vững định nghĩa lý thuyết cốt lõi của khái niệm này",
      "Thực hành gõ và chạy thử thành công ví dụ code minh họa",
      "Áp dụng kiến thức đã học vào bài tập hoặc dự án thực tế nhỏ"
    ];
  }

  return items.asMap().entries.map((entry) => ChecklistItem(
    id: 'item-${entry.key + 1}',
    text: entry.value,
    completed: false,
  )).toList();
}

class CodeSnippet {
  final String language;
  final String code;

  CodeSnippet({required this.language, required this.code});
}

CodeSnippet getStepCodeSnippet(String title) {
  final t = title.toLowerCase();

  if (t.contains("variable") || t.contains("biến") || t.contains("types") || t.contains("kiểu dữ liệu")) {
    return CodeSnippet(
      language: "dart",
      code: '''void main() {
  // Khai báo biến với kiểu dữ liệu cụ thể
  String name = "Flutter";
  int year = 2026;
  double version = 3.5;
  bool isAwesome = true;

  // Sử dụng var, final và const
  var dynamicVar = "Có thể thay đổi giá trị";
  final currentTime = DateTime.now(); // Xác định lúc chạy (runtime)
  const pi = 3.14159; // Xác định lúc biên dịch (compile-time)

  print("Chào mừng đến với \$name \$year (v\$version)");
}''',
    );
  }

  if (t.contains("operator") || t.contains("toán tử") || t.contains("function") || t.contains("hàm")) {
    return CodeSnippet(
      language: "dart",
      code: '''// Hàm cơ bản có kiểu trả về cụ thể
int calculateArea(int width, int height) {
  return width * height;
}

// Hàm với tham số đặt tên (Named Parameters) và giá trị mặc định
void greetUser({required String name, String role = "Học viên"}) {
  print("Xin chào \$name, vai trò của bạn là: \$role");
}

void main() {
  int area = calculateArea(5, 10);
  print("Diện tích: \$area");

  // Gọi hàm với tham số đặt tên trực quan
  greetUser(name: "Nguyễn Văn A", role: "Lập trình viên Flutter");
}''',
    );
  }

  if (t.contains("control flow") || t.contains("rẽ nhánh") || t.contains("loop") || t.contains("vòng lặp")) {
    return CodeSnippet(
      language: "dart",
      code: '''void main() {
  int score = 85;

  // Cấu trúc rẽ nhánh If-Else
  if (score >= 90) {
    print("Xuất sắc");
  } else if (score >= 80) {
    print("Giỏi");
  } else {
    print("Cần cố gắng");
  }

  // Vòng lặp For cơ bản
  print("Đếm từ 1 đến 3:");
  for (int i = 1; i <= 3; i++) {
    print("Lần lặp thứ \$i");
  }

  // Vòng lặp duyệt danh sách (for-in)
  List<String> fruits = ["Táo", "Chuối", "Cam"];
  for (var fruit in fruits) {
    print("Trái cây: \$fruit");
  }
}''',
    );
  }

  if (t.contains("oop") || t.contains("đối tượng") || t.contains("class")) {
    return CodeSnippet(
      language: "dart",
      code: '''// Khai báo lớp (Class) hướng đối tượng
class Car {
  String brand;
  int year;

  // Constructor (Hàm khởi tạo rút gọn của Dart)
  Car(this.brand, this.year);

  // Phương thức hoạt động (Method)
  void drive() {
    print("\$brand (\$year) đang di chuyển mượt mà trên đường...");
  }
}

// Lớp con Kế thừa (Inheritance) từ lớp Car
class ElectricCar extends Car {
  int batteryCapacity;

  ElectricCar(String brand, int year, this.batteryCapacity) : super(brand, year);

  @override
  void drive() {
    print("\$brand chạy bằng điện cực êm, dung lượng pin: \$batteryCapacity%!");
  }
}

void main() {
  var myCar = ElectricCar("Tesla Model Y", 2026, 95);
  myCar.drive(); // Sẽ kích hoạt phương thức override ở lớp con
}''',
    );
  }

  if (t.contains("asynchronous") || t.contains("bất đồng bộ") || t.contains("future") || t.contains("stream")) {
    return CodeSnippet(
      language: "dart",
      code: '''// Giả lập gọi API lấy dữ liệu bất đồng bộ với Future
Future<String> fetchUserData() async {
  print("Đang tải dữ liệu người dùng từ máy chủ...");
  // Chờ 2 giây giả lập mạng trễ
  await Future.delayed(const Duration(seconds: 2));
  return "Học Viên Xuất Sắc";
}

void main() async {
  print("Bắt đầu chương trình chính.");
  
  try {
    // Chờ kết quả bất đồng bộ mà không block giao diện
    String username = await fetchUserData();
    print("Tải thành công! Xin chào: \$username");
  } catch (e) {
    print("Có lỗi xảy ra: \$e");
  }
  
  print("Kết thúc chương trình.");
}''',
    );
  }

  if (t.contains("stateless") || t.contains("stateful") || t.contains("widget")) {
    return CodeSnippet(
      language: "dart",
      code: '''import 'package:flutter/material.dart';

// 1. Stateless Widget: Giao diện tĩnh, không tự thay đổi trạng thái
class InfoCard extends StatelessWidget {
  final String title;
  const InfoCard({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

// 2. Stateful Widget: Giao diện động, tự thay đổi khi có sự kiện kích hoạt
class CounterWidget extends StatefulWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0; // Trạng thái sẽ được thay đổi

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _counter++; // Kích hoạt render lại widget để hiển thị số mới
        });
      },
      child: Text("Đã click: \$_counter lần"),
    );
  }
}''',
    );
  }

  if (t.contains("layout") || t.contains("row") || t.contains("column") || t.contains("stack")) {
    return CodeSnippet(
      language: "dart",
      code: '''import 'package:flutter/material.dart';

Widget buildDashboardLayout() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Bố cục hàng ngang (Row)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
        ],
      ),
      const SizedBox(height: 20),
      // Bố cục chồng đè (Stack)
      Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 120, height: 120, color: Colors.indigo),
          Container(width: 80, height: 80, color: Colors.indigoAccent),
          const Text("Top Layer", style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      )
    ],
  );
}''',
    );
  }

  if (t.contains("jdk") || t.contains("jvm") || t.contains("cài đặt") || t.contains("java")) {
    return CodeSnippet(
      language: "java",
      code: '''// HelloWorld.java
public class HelloWorld {
    public static void main(String[] args) {
        // In lời chào ra màn hình điều khiển terminal
        System.out.println("Hello, World! Chào mừng bạn đến với Java Core.");
        
        // Truy xuất thông tin máy ảo JVM đang hoạt động
        String version = System.getProperty("java.version");
        System.out.println("Phiên bản Java Runtime (JVM) đang chạy: " + version);
    }
}''',
    );
  }

  if (t.contains("html") || t.contains("semantic") || t.contains("thẻ ngữ nghĩa")) {
    return CodeSnippet(
      language: "html",
      code: '''<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sử dụng Thẻ Ngữ Nghĩa HTML5</title>
</head>
<body>
    <!-- Header định nghĩa vùng đầu trang chứa thanh điều hướng -->
    <header>
        <h1>Cộng Đồng Học Tập Web</h1>
        <nav>
            <ul>
                <li><a href="#lessons">Bài học</a></li>
                <li><a href="#forum">Diễn đàn</a></li>
            </ul>
        </nav>
    </header>

    <!-- Main đại diện cho phần nội dung chính duy nhất chuẩn SEO -->
    <main>
        <article>
            <header>
                <h2>Tầm quan trọng của SEO trong kỷ nguyên Web mới</h2>
                <p>Xuất bản bởi Admin vào tháng 7, 2026</p>
            </header>
            <p>Sử dụng các thẻ như <section>, <article>, <aside> giúp Google dễ dàng phân tích dữ liệu...</p>
        </article>
    </main>

    <!-- Footer chứa thông tin bản quyền và liên hệ cuối trang -->
    <footer>
        <p>© 2026 Bản quyền thuộc về Lập Trình Viên Web</p>
    </footer>
</body>
</html>''',
    );
  }

  if (t.contains("javascript") || t.contains("js") || t.contains("es6")) {
    return CodeSnippet(
      language: "javascript",
      code: '''// Sử dụng ES6+ hiện đại
const multiplyAndAdd = (a, b) => {
  const product = a * b;
  return product + 10;
};

// Destructuring mảng & đối tượng
const user = { name: "Thanh Tung", age: 20, rank: "A" };
const { name, rank } = user;
console.log(`Học sinh: \${name} - Xếp hạng: \${rank}`);

// Các hàm duyệt mảng tối tân
const scores = [80, 95, 70, 85];
const passedScores = scores.filter(s => s >= 80).map(s => s + 5);
console.log("Điểm cộng thưởng:", passedScores);''',
    );
  }

  if (t.contains("python")) {
    return CodeSnippet(
      language: "python",
      code: '''# Sử dụng Python cơ bản & thư viện khoa học dữ liệu
import numpy as np

def calculate_analytics():
    # Khai báo list Python
    data_list = [10, 20, 30, 40, 50]
    
    # Chuyển đổi sang NumPy array đa chiều nhanh chóng
    np_array = np.array(data_list)
    mean_val = np.mean(np_array)
    std_val = np.std(np_array)
    
    print(f"Giá trị trung bình: {mean_val}")
    print(f"Độ lệch chuẩn: {std_val}")

if __name__ == "__main__":
    calculate_analytics()''',
    );
  }

  if (t.contains("regression") || t.contains("classification") || t.contains("machine learning") || t.contains("giám sát") || t.contains("hồi quy")) {
    return CodeSnippet(
      language: "python",
      code: '''# Xây dựng mô hình học máy với Scikit-Learn
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
import numpy as np

# Tạo dữ liệu huấn luyện giả lập
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([2, 4, 6, 8, 10])

# Chia bộ Train / Test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Khởi tạo thuật toán hồi quy tuyến tính
model = LinearRegression()
model.fit(X_train, y_train)

# Dự đoán
predictions = model.predict(X_test)
print("Kết quả dự đoán thử nghiệm:", predictions)''',
    );
  }

  return CodeSnippet(
    language: "dart",
    code: '''void main() {
  // Lộ trình học tập thông minh tự động
  print("Đang tìm hiểu khái niệm: $title");
  print("Hãy hoàn thành các mục tiêu trong checklist để nắm vững kiến thức!");
}''',
  );
}
