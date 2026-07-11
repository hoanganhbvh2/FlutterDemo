import React, { useState } from "react";
import { Sparkles, X, Lightbulb, Compass, Code, Brain } from "lucide-react";
import { Topic } from "../types";

interface AIGeneratorModalProps {
  isOpen: boolean;
  onClose: () => void;
  onGenerateSuccess: (newTopic: Topic) => void;
}

const AI_TIPS = [
  "Gemini sẽ tự động phân bổ tọa độ X, Y dạng zic-zắc để bạn dễ theo dõi trên Canvas.",
  "Mỗi bước đều có song ngữ Anh - Việt giúp bạn học thuật ngữ chuyên ngành dễ dàng.",
  "Mọi lộ trình được sinh ra dưới dạng sơ đồ Graph liên kết giúp thể hiện rõ thứ tự tiên quyết.",
  "Bạn có thể kéo thả bất kỳ Node nào sau khi AI tạo xong để sắp xếp lại theo ý muốn."
];

export default function AIGeneratorModal({ isOpen, onClose, onGenerateSuccess }: AIGeneratorModalProps) {
  const [topicName, setTopicName] = useState("");
  const [description, setDescription] = useState("");
  const [loading, setLoading] = useState(false);
  const [currentTipIndex, setCurrentTipIndex] = useState(0);
  const [error, setError] = useState<string | null>(null);

  React.useEffect(() => {
    let interval: NodeJS.Timeout;
    if (loading) {
      interval = setInterval(() => {
        setCurrentTipIndex((prev) => (prev + 1) % AI_TIPS.length);
      }, 4000);
    }
    return () => clearInterval(interval);
  }, [loading]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!topicName.trim()) return;

    setLoading(true);
    setError(null);

    try {
      const response = await fetch("/api/generate-roadmap", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          topic: topicName.trim(),
          description: description.trim(),
        }),
      });

      const data = await response.json();
      if (!response.ok || !data.success) {
        throw new Error(data.error || "Không thể khởi tạo lộ trình học tập từ AI.");
      }

      // Convert generated format to local model
      const generated = data.data;
      const newTopic: Topic = {
        id: `topic-${Date.now()}`,
        title: generated.topicTitle || topicName,
        description: generated.topicDescription || "Lộ trình học tập do AI tự động tạo lập.",
        emoji: generated.topicEmoji || "🧠",
        createdAt: new Date().toISOString(),
        lessons: (generated.lessons || []).map((lesson: any, lIdx: number) => ({
          id: lesson.id || `lesson-${Date.now()}-${lIdx}`,
          topicId: `topic-${Date.now()}`,
          title: lesson.title || `Bài học ${lIdx + 1}`,
          description: lesson.description || "Nội dung học tập.",
          order: lesson.order || (lIdx + 1),
          nodes: (lesson.nodes || []).map((node: any, nIdx: number) => ({
            id: node.id || `step-${Date.now()}-${lIdx}-${nIdx}`,
            lessonId: lesson.id || `lesson-${Date.now()}-${lIdx}`,
            title: node.title,
            description: node.description,
            emoji: node.emoji || "📝",
            positionX: node.positionX || (200 + (nIdx % 2) * 300),
            positionY: node.positionY || (100 + nIdx * 120),
            status: "Not Started",
            order: node.order || (nIdx + 1),
          })),
          edges: (lesson.edges || []).map((edge: any, eIdx: number) => ({
            id: edge.id || `edge-${Date.now()}-${lIdx}-${eIdx}`,
            lessonId: lesson.id || `lesson-${Date.now()}-${lIdx}`,
            from: edge.from,
            to: edge.to,
          }))
        }))
      };

      onGenerateSuccess(newTopic);
      onClose();
      // Clear inputs
      setTopicName("");
      setDescription("");
    } catch (err: any) {
      console.error(err);
      setError(err.message || "Đã xảy ra lỗi khi kết nối với máy chủ AI.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="absolute inset-0 bg-slate-950/70 backdrop-blur-xs z-50 flex items-end sm:items-center justify-center">
      <div className="bg-white rounded-t-[32px] sm:rounded-2xl shadow-2xl w-full max-h-[95%] border-t border-slate-100 overflow-hidden relative animate-in slide-in-from-bottom sm:zoom-in-95 duration-250 flex flex-col">
        
        {/* Pull Indicator on Mobile */}
        <div className="w-12 h-1 bg-slate-200 rounded-full mx-auto mt-3 mb-1 shrink-0 sm:hidden" />

        {/* Header */}
        <div className="px-5 py-4 bg-slate-50 border-b border-slate-100 flex justify-between items-center shrink-0">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-indigo-50 text-indigo-600 rounded-xl">
              <Sparkles className="w-4 h-4 animate-pulse" />
            </div>
            <div>
              <h3 className="font-bold text-slate-900 text-xs">Lộ trình tự động bằng AI</h3>
              <p className="text-[10px] text-slate-500 font-medium">Sử dụng Gemini để sinh giáo trình & roadmap sơ đồ</p>
            </div>
          </div>
          <button 
            onClick={onClose} 
            disabled={loading}
            className="p-1 hover:bg-slate-200 rounded-lg text-slate-400 hover:text-slate-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        {!loading ? (
          <form onSubmit={handleSubmit} className="p-6 space-y-4">
            {error && (
              <div className="p-3 bg-red-50 text-red-600 border border-red-100 rounded-xl text-sm">
                ⚠️ {error}
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Tên chủ đề học tập <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                required
                placeholder="VD: ReactJS, Docker Container, Thiết kế UI/UX,..."
                value={topicName}
                onChange={(e) => setTopicName(e.target.value)}
                className="w-full px-4 py-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 outline-none transition-all text-slate-900"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Yêu cầu đặc biệt (Không bắt buộc)
              </label>
              <textarea
                placeholder="VD: Tôi muốn lộ trình cho người mới bắt đầu, tập trung thực hành, học trong vòng 4 tuần..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                rows={3}
                className="w-full px-4 py-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 outline-none transition-all text-slate-900 resize-none text-sm"
              />
            </div>

            {/* Quick Suggestions */}
            <div className="pt-2">
              <span className="text-xs text-slate-400 block mb-2">Gợi ý chủ đề thịnh hành:</span>
              <div className="flex flex-wrap gap-2">
                {["Docker & Kubernetes", "Prompt Engineering", "Data Structures & Algorithms", "Rust Programming"].map((item) => (
                  <button
                    key={item}
                    type="button"
                    onClick={() => {
                      setTopicName(item);
                      setDescription("Tập trung vào các dự án thực tế và sơ đồ học bài bản.");
                    }}
                    className="px-2.5 py-1 text-xs bg-slate-50 hover:bg-indigo-50 hover:text-indigo-600 text-slate-600 rounded-lg border border-slate-200 hover:border-indigo-100 transition-all"
                  >
                    {item}
                  </button>
                ))}
              </div>
            </div>

            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 rounded-xl transition-colors"
              >
                Hủy bỏ
              </button>
              <button
                type="submit"
                className="px-5 py-2 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-lg shadow-indigo-500/20 flex items-center gap-1.5 transition-all"
              >
                <Sparkles className="w-4 h-4" />
                Bắt đầu Tạo Lộ trình
              </button>
            </div>
          </form>
        ) : (
          <div className="p-8 text-center space-y-6 flex flex-col items-center">
            {/* Loading Animation */}
            <div className="relative w-20 h-20">
              <div className="absolute inset-0 border-4 border-indigo-100 rounded-full"></div>
              <div className="absolute inset-0 border-4 border-indigo-600 rounded-full border-t-transparent animate-spin"></div>
              <div className="absolute inset-0 flex items-center justify-center text-indigo-600">
                <Sparkles className="w-8 h-8 animate-pulse" />
              </div>
            </div>

            <div className="space-y-2">
              <h4 className="font-semibold text-slate-950 text-base animate-pulse">Gemini AI đang tư duy...</h4>
              <p className="text-sm text-slate-500 max-w-sm mx-auto">
                Chúng tôi đang phân tích cấu trúc kiến thức, soạn thảo nội dung song ngữ và tính toán vị trí đồ họa tối ưu.
              </p>
            </div>

            {/* AI Tips Rotation Card */}
            <div className="w-full bg-indigo-50/50 rounded-xl p-4 border border-indigo-100/50 text-left flex gap-3 items-start animate-fade-in">
              <Lightbulb className="w-5 h-5 text-indigo-500 shrink-0 mt-0.5" />
              <div>
                <span className="text-xs font-semibold text-indigo-600 block uppercase tracking-wider mb-0.5">Bạn có biết?</span>
                <p className="text-xs text-indigo-950 leading-relaxed transition-all">
                  {AI_TIPS[currentTipIndex]}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
