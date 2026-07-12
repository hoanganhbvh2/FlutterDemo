/// Selects a beautiful, high-quality Unsplash tech stock illustration based on the title keyword.
/// This guarantees every step of the learning roadmap has an elegant, content-rich graphic illustration.
String getStepIllustration(String title, int order) {
  final t = title.toLowerCase();
  
  // 1. Flutter & Dart core
  if (t.contains("variable") || t.contains("biến") || t.contains("types") || t.contains("kiểu dữ liệu")) {
    return "https://images.unsplash.com/photo-1618401471353-b98aedd07871?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("operator") || t.contains("toán tử") || t.contains("function") || t.contains("hàm")) {
    return "https://images.unsplash.com/photo-1629654297299-c8506221ca97?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("control flow") || t.contains("rẽ nhánh") || t.contains("loop") || t.contains("vòng lặp")) {
    return "https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("oop") || t.contains("object-oriented") || t.contains("đối tượng") || t.contains("class")) {
    return "https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("asynchronous") || t.contains("bất đồng bộ") || t.contains("future") || t.contains("stream")) {
    return "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=500&auto=format&fit=crop&q=80";
  }
  
  // 2. Mobile & Web UI Core
  if (t.contains("stateless") || t.contains("stateful") || t.contains("widget")) {
    return "https://images.unsplash.com/photo-1541462608141-27b2c7453c6f?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("layout") || t.contains("row") || t.contains("column") || t.contains("stack") || t.contains("flexbox") || t.contains("grid")) {
    return "https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=500&auto=format&fit=crop&q=80";
  }
  
  // 3. Backend & Core Languages
  if (t.contains("jdk") || t.contains("jvm") || t.contains("cài đặt") || t.contains("java") || t.contains("basic types") || t.contains("operators")) {
    return "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500&auto=format&fit=crop&q=80";
  }
  
  // 4. Web Frontend
  if (t.contains("html") || t.contains("semantic") || t.contains("thẻ ngữ nghĩa")) {
    return "https://images.unsplash.com/photo-1581291518655-9523c932ebcf?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("javascript") || t.contains("js") || t.contains("es6")) {
    return "https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=500&auto=format&fit=crop&q=80";
  }
  
  // 5. Artificial Intelligence & Python
  if (t.contains("python")) {
    return "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("regression") || t.contains("classification") || t.contains("machine learning") || t.contains("giám sát") || t.contains("hồi quy")) {
    return "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&auto=format&fit=crop&q=80";
  }
  if (t.contains("prompt") || t.contains("llm") || t.contains("ai") || t.contains("generative") || t.contains("chatgpt")) {
    return "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=500&auto=format&fit=crop&q=80";
  }
  
  final fallbacks = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=500&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&auto=format&fit=crop&q=80"
  ];
  return fallbacks[order % fallbacks.length];
}
