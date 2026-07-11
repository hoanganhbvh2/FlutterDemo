/**
 * Selects a beautiful, high-quality Unsplash tech stock illustration based on the title keyword.
 * This guarantees every step of the learning roadmap has an elegant, content-rich graphic illustration.
 */
export function getStepIllustration(title: string, order: number): string {
  const t = title.toLowerCase();
  
  // 1. Flutter & Dart core
  if (t.includes("variable") || t.includes("biến") || t.includes("types") || t.includes("kiểu dữ liệu")) {
    return "https://images.unsplash.com/photo-1618401471353-b98aedd07871?w=500&auto=format&fit=crop&q=80"; // Modern tech workspace abstract
  }
  if (t.includes("operator") || t.includes("toán tử") || t.includes("function") || t.includes("hàm")) {
    return "https://images.unsplash.com/photo-1629654297299-c8506221ca97?w=500&auto=format&fit=crop&q=80"; // Futuristic abstract mechanical structures
  }
  if (t.includes("control flow") || t.includes("rẽ nhánh") || t.includes("loop") || t.includes("vòng lặp")) {
    return "https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=500&auto=format&fit=crop&q=80"; // Neon curves reflecting repetition
  }
  if (t.includes("oop") || t.includes("object-oriented") || t.includes("đối tượng") || t.includes("class")) {
    return "https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&auto=format&fit=crop&q=80"; // Block-structured layout design
  }
  if (t.includes("asynchronous") || t.includes("bất đồng bộ") || t.includes("future") || t.includes("stream")) {
    return "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=500&auto=format&fit=crop&q=80"; // Flow of glowing light / fibers
  }
  
  // 2. Mobile & Web UI Core
  if (t.includes("stateless") || t.includes("stateful") || t.includes("widget")) {
    return "https://images.unsplash.com/photo-1541462608141-27b2c7453c6f?w=500&auto=format&fit=crop&q=80"; // Clean interface layout
  }
  if (t.includes("layout") || t.includes("row") || t.includes("column") || t.includes("stack") || t.includes("flexbox") || t.includes("grid")) {
    return "https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=500&auto=format&fit=crop&q=80"; // Bright structured grids
  }
  
  // 3. Backend & Core Languages
  if (t.includes("jdk") || t.includes("jvm") || t.includes("cài đặt") || t.includes("java") || t.includes("basic types") || t.includes("operators")) {
    return "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500&auto=format&fit=crop&q=80"; // Beautiful high-tech code view
  }
  
  // 4. Web Frontend
  if (t.includes("html") || t.includes("semantic") || t.includes("thẻ ngữ nghĩa")) {
    return "https://images.unsplash.com/photo-1581291518655-9523c932ebcf?w=500&auto=format&fit=crop&q=80"; // Elegant digital workspace web design
  }
  if (t.includes("javascript") || t.includes("js") || t.includes("es6")) {
    return "https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=500&auto=format&fit=crop&q=80"; // Golden futuristic light code
  }
  
  // 5. Artificial Intelligence & Python
  if (t.includes("python")) {
    return "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500&auto=format&fit=crop&q=80"; // Tech neon neural networks
  }
  if (t.includes("regression") || t.includes("classification") || t.includes("machine learning") || t.includes("giám sát") || t.includes("hồi quy")) {
    return "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&auto=format&fit=crop&q=80"; // Beautiful colorful data chart graphs
  }
  if (t.includes("prompt") || t.includes("llm") || t.includes("ai") || t.includes("generative") || t.includes("chatgpt")) {
    return "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=500&auto=format&fit=crop&q=80"; // Virtual intelligence neural concept
  }
  
  // Curated fallbacks based on index order to keep everything gorgeous
  const fallbacks = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500&auto=format&fit=crop&q=80", // Interactive UI design
    "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&auto=format&fit=crop&q=80", // Sleek black laptop with color lines
    "https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop&q=80", // Colorful concept map / wireframes
    "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=500&auto=format&fit=crop&q=80", // Modern analytical work board
    "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&auto=format&fit=crop&q=80"  // Cyber nodes lines
  ];
  return fallbacks[order % fallbacks.length];
}
