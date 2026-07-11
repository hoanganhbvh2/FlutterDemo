import { Topic } from "./types";

export const SAMPLE_TOPICS: Topic[] = [
  {
    id: "topic-flutter",
    title: "Flutter Development",
    description: "Lộ trình học phát triển ứng dụng di động đa nền tảng với Flutter và Dart.",
    emoji: "📱",
    createdAt: new Date("2026-01-01").toISOString(),
    lessons: [
      {
        id: "lesson-dart-basics",
        topicId: "topic-flutter",
        title: "Dart Programming Basics",
        description: "Học ngôn ngữ Dart, nền tảng của Flutter, từ cơ bản đến nâng cao.",
        order: 1,
        nodes: [
          {
            id: "step-dart-1",
            lessonId: "lesson-dart-basics",
            title: "Variables & Basic Types / Biến & Kiểu dữ liệu",
            description: "Tìm hiểu cách khai báo biến, các kiểu dữ liệu cơ bản như String, int, double, bool và từ khóa var, final, const.",
            emoji: "📦",
            positionX: 200,
            positionY: 100,
            status: "Completed",
            order: 1
          },
          {
            id: "step-dart-2",
            lessonId: "lesson-dart-basics",
            title: "Operators & Functions / Toán tử & Hàm",
            description: "Cách sử dụng toán tử số học, logic, so sánh và viết các hàm có tham số tùy chọn hoặc đặt tên.",
            emoji: "⚙️",
            positionX: 500,
            positionY: 220,
            status: "Completed",
            order: 2
          },
          {
            id: "step-dart-3",
            lessonId: "lesson-dart-basics",
            title: "Control Flow (If/Else, Loops) / Cấu trúc rẽ nhánh & Vòng lặp",
            description: "Sử dụng If-Else, Switch Case, vòng lặp for, while để điều khiển luồng chương trình.",
            emoji: "🔄",
            positionX: 200,
            positionY: 340,
            status: "In Progress",
            order: 3
          },
          {
            id: "step-dart-4",
            lessonId: "lesson-dart-basics",
            title: "Object-Oriented Programming (OOP) / Hướng đối tượng",
            description: "Hiểu về Class, Object, Kế thừa (Inheritance), Đa hình (Polymorphism), Mixins và Interfaces trong Dart.",
            emoji: "🧩",
            positionX: 500,
            positionY: 460,
            status: "Not Started",
            order: 4
          },
          {
            id: "step-dart-5",
            lessonId: "lesson-dart-basics",
            title: "Asynchronous (Future, Stream) / Lập trình bất đồng bộ",
            description: "Làm chủ async, await, Future và Stream để xử lý các tác vụ tốn thời gian như gọi API hoặc đọc file.",
            emoji: "⚡",
            positionX: 350,
            positionY: 580,
            status: "Not Started",
            order: 5
          }
        ],
        edges: [
          { id: "edge-dart-1", lessonId: "lesson-dart-basics", from: "step-dart-1", to: "step-dart-2" },
          { id: "edge-dart-2", lessonId: "lesson-dart-basics", from: "step-dart-2", to: "step-dart-3" },
          { id: "edge-dart-3", lessonId: "lesson-dart-basics", from: "step-dart-3", to: "step-dart-4" },
          { id: "edge-dart-4", lessonId: "lesson-dart-basics", from: "step-dart-4", to: "step-dart-5" }
        ]
      },
      {
        id: "lesson-flutter-ui",
        topicId: "topic-flutter",
        title: "Flutter UI & Widgets",
        description: "Xây dựng giao diện người dùng đẹp mắt với hệ thống Widget của Flutter.",
        order: 2,
        nodes: [
          {
            id: "step-ui-1",
            lessonId: "lesson-flutter-ui",
            title: "Stateless vs Stateful Widgets",
            description: "Sự khác biệt cốt lõi giữa Widget không trạng thái và Widget có trạng thái, khi nào nên dùng cái nào.",
            emoji: "🎨",
            positionX: 200,
            positionY: 100,
            status: "Not Started",
            order: 1
          },
          {
            id: "step-ui-2",
            lessonId: "lesson-flutter-ui",
            title: "Basic Widgets (Text, Image, Container)",
            description: "Thành thạo các widget cơ bản để vẽ và trang trí layout cơ bản.",
            emoji: "🖼️",
            positionX: 500,
            positionY: 220,
            status: "Not Started",
            order: 2
          },
          {
            id: "step-ui-3",
            lessonId: "lesson-flutter-ui",
            title: "Layout Widgets (Row, Column, Stack)",
            description: "Cách sắp xếp các widget theo hàng ngang, cột dọc hoặc đè lên nhau.",
            emoji: "📊",
            positionX: 200,
            positionY: 340,
            status: "Not Started",
            order: 3
          }
        ],
        edges: [
          { id: "edge-ui-1", lessonId: "lesson-flutter-ui", from: "step-ui-1", to: "step-ui-2" },
          { id: "edge-ui-2", lessonId: "lesson-flutter-ui", from: "step-ui-2", to: "step-ui-3" }
        ]
      }
    ]
  },
  {
    id: "topic-java",
    title: "Java Programming",
    description: "Lộ trình học lập trình hướng đối tượng Java toàn diện cho backend developer.",
    emoji: "📘",
    createdAt: new Date("2026-01-05").toISOString(),
    lessons: [
      {
        id: "lesson-java-intro",
        topicId: "topic-java",
        title: "Java Core Fundamentals",
        description: "Làm quen với cú pháp Java, kiểu dữ liệu và cấu trúc điều khiển.",
        order: 1,
        nodes: [
          {
            id: "step-java-1",
            lessonId: "lesson-java-intro",
            title: "JDK, JRE & JVM / Cài đặt môi trường",
            description: "Hiểu kiến trúc chạy mã Java, cài đặt JDK và viết chương trình HelloWorld đầu tiên.",
            emoji: "💻",
            positionX: 200,
            positionY: 100,
            status: "Completed",
            order: 1
          },
          {
            id: "step-java-2",
            lessonId: "lesson-java-intro",
            title: "Data Types & Variables / Kiểu dữ liệu",
            description: "Kiểu dữ liệu nguyên thủy (primitive) và kiểu đối tượng (reference) trong Java.",
            emoji: "🔢",
            positionX: 500,
            positionY: 220,
            status: "Completed",
            order: 2
          },
          {
            id: "step-java-3",
            lessonId: "lesson-java-intro",
            title: "Conditional Statements / Cấu trúc rẽ nhánh",
            description: "Làm quen với if-else, ternary operator và switch-case truyền thống.",
            emoji: "🌿",
            positionX: 200,
            positionY: 340,
            status: "In Progress",
            order: 3
          }
        ],
        edges: [
          { id: "edge-java-1", lessonId: "lesson-java-intro", from: "step-java-1", to: "step-java-2" },
          { id: "edge-java-2", lessonId: "lesson-java-intro", from: "step-java-2", to: "step-java-3" }
        ]
      }
    ]
  },
  {
    id: "topic-web",
    title: "Web Development",
    description: "Trở thành Fullstack Web Developer với HTML, CSS, JavaScript và React.",
    emoji: "🌐",
    createdAt: new Date("2026-02-10").toISOString(),
    lessons: [
      {
        id: "lesson-web-frontend",
        topicId: "topic-web",
        title: "Frontend Core",
        description: "Học nền tảng giao diện web tĩnh.",
        order: 1,
        nodes: [
          {
            id: "step-web-1",
            lessonId: "lesson-web-frontend",
            title: "HTML5 Semantic Tags / Thẻ ngữ nghĩa",
            description: "Xây dựng khung xương cho trang web với các thẻ ngữ nghĩa chuẩn SEO như header, footer, article, section.",
            emoji: "🦴",
            positionX: 200,
            positionY: 100,
            status: "Completed",
            order: 1
          },
          {
            id: "step-web-2",
            lessonId: "lesson-web-frontend",
            title: "CSS3 Flexbox & Grid Layouts / Bố cục CSS",
            description: "Tạo bố cục web linh hoạt và responsive dễ dàng nhờ Flexbox và CSS Grid.",
            emoji: "🎨",
            positionX: 500,
            positionY: 220,
            status: "Completed",
            order: 2
          },
          {
            id: "step-web-3",
            lessonId: "lesson-web-frontend",
            title: "Modern JavaScript (ES6+) / JS hiện đại",
            description: "Nắm vững arrow functions, destructuring, promises và fetch API.",
            emoji: "⚡",
            positionX: 200,
            positionY: 340,
            status: "In Progress",
            order: 3
          }
        ],
        edges: [
          { id: "edge-web-1", lessonId: "lesson-web-frontend", from: "step-web-1", to: "step-web-2" },
          { id: "edge-web-2", lessonId: "lesson-web-frontend", from: "step-web-2", to: "step-web-3" }
        ]
      }
    ]
  },
  {
    id: "topic-ai",
    title: "Artificial Intelligence",
    description: "Nhập môn AI, Machine Learning, Deep Learning và Generative AI (LLMs).",
    emoji: "🤖",
    createdAt: new Date("2026-03-15").toISOString(),
    lessons: [
      {
        id: "lesson-ai-intro",
        topicId: "topic-ai",
        title: "Introduction to ML & GenAI",
        description: "Khám phá các mô hình học máy cơ bản và công nghệ AI tạo sinh.",
        order: 1,
        nodes: [
          {
            id: "step-ai-1",
            lessonId: "lesson-ai-intro",
            title: "Python for Data Science / Python cơ bản",
            description: "Học cú pháp Python và các thư viện cốt lõi như NumPy và Pandas để xử lý dữ liệu.",
            emoji: "🐍",
            positionX: 200,
            positionY: 100,
            status: "Not Started",
            order: 1
          },
          {
            id: "step-ai-2",
            lessonId: "lesson-ai-intro",
            title: "Linear Regression & Classification / Học máy có giám sát",
            description: "Làm quen với các thuật toán ML hồi quy tuyến tính, phân loại và thư viện Scikit-learn.",
            emoji: "📈",
            positionX: 500,
            positionY: 220,
            status: "Not Started",
            order: 2
          },
          {
            id: "step-ai-3",
            lessonId: "lesson-ai-intro",
            title: "Prompt Engineering & LLMs / Kỹ thuật viết Prompt",
            description: "Tìm hiểu cách hoạt động của Large Language Models và các kỹ thuật viết prompt chuyên sâu như Few-shot, Chain-of-Thought.",
            emoji: "💡",
            positionX: 200,
            positionY: 340,
            status: "Not Started",
            order: 3
          }
        ],
        edges: [
          { id: "edge-ai-1", lessonId: "lesson-ai-intro", from: "step-ai-1", to: "step-ai-2" },
          { id: "edge-ai-2", lessonId: "lesson-ai-intro", from: "step-ai-2", to: "step-ai-3" }
        ]
      }
    ]
  }
];
