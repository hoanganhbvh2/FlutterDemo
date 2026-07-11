import React, { useState, useEffect } from "react";
import { X, CheckCircle, Clock, BookOpen, Trash2, Edit2, CheckSquare, Save } from "lucide-react";
import { Step, StepStatus } from "../types";
import { getStepIllustration } from "../utils";

interface StepDetailDrawerProps {
  step: Step | null;
  onClose: () => void;
  onUpdateStep: (id: string, updates: Partial<Step>) => void;
  onDeleteStep: (id: string) => void;
}

export default function StepDetailDrawer({
  step,
  onClose,
  onUpdateStep,
  onDeleteStep,
}: StepDetailDrawerProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [emoji, setEmoji] = useState("");
  const [order, setOrder] = useState<number>(1);

  // Sync state with selected step
  useEffect(() => {
    if (step) {
      setTitle(step.title);
      setDescription(step.description);
      setEmoji(step.emoji);
      setOrder(step.order);
      setIsEditing(false); // Reset editing mode
    }
  }, [step]);

  if (!step) return null;

  const handleSave = () => {
    onUpdateStep(step.id, {
      title,
      description,
      emoji,
      order: Number(order)
    });
    setIsEditing(false);
  };

  const handleStatusChange = (newStatus: StepStatus) => {
    onUpdateStep(step.id, { status: newStatus });
  };

  const statusConfigs = {
    "Not Started": { label: "Chưa học", color: "bg-slate-100 text-slate-700 border-slate-300 hover:bg-slate-200" },
    "In Progress": { label: "Đang học", color: "bg-amber-100 text-amber-800 border-amber-300 hover:bg-amber-200" },
    "Completed": { label: "Hoàn thành", color: "bg-emerald-100 text-emerald-800 border-emerald-300 hover:bg-emerald-200" }
  };

  // Extract bilingual components (Vietnamese and English) if separated by slash
  const parts = step.title.split("/");
  const viTitle = parts[0]?.trim();
  const enTitle = parts[1]?.trim();

  return (
    <div className="absolute inset-0 z-50 flex flex-col justify-end bg-slate-950/60 backdrop-blur-xs">
      {/* Backdrop click to close */}
      <div className="absolute inset-0" onClick={onClose} />
 
      {/* Drawer Container (Mobile slide-up bottom sheet) */}
      <div className="relative w-full max-h-[88%] bg-white shadow-2xl rounded-t-[32px] border-t border-slate-100 flex flex-col z-10 animate-in slide-in-from-bottom duration-200">
        
        {/* Pull Indicator Bar */}
        <div className="w-12 h-1.5 bg-slate-200 rounded-full mx-auto my-3 shrink-0" />

        {/* Drawer Header */}
        <div className="px-5 pb-4 border-b border-slate-100 flex justify-between items-center">
          <div className="flex items-center gap-2.5">
            <span className="text-2xl">{step.emoji}</span>
            <div>
              <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wider">
                Khái niệm bài học
              </span>
              <h4 className="font-bold text-slate-800 text-xs">
                Mã số: {step.id.substring(5)}
              </h4>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-slate-100 text-slate-400 hover:text-slate-600 rounded-full transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Scrollable Drawer Body */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          
          {/* Status Tracker */}
          <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100/50 space-y-3">
            <span className="text-xs font-semibold text-slate-500 block">Trạng thái học tập</span>
            <div className="grid grid-cols-3 gap-2">
              {(["Not Started", "In Progress", "Completed"] as StepStatus[]).map((st) => {
                const isActive = step.status === st;
                return (
                  <button
                    key={st}
                    onClick={() => handleStatusChange(st)}
                    className={`px-2.5 py-2 border rounded-xl text-xs font-semibold transition-all flex flex-col items-center gap-1.5 cursor-pointer ${
                      isActive
                        ? st === "Completed"
                          ? "bg-emerald-600 text-white border-emerald-600 shadow-md shadow-emerald-500/20"
                          : st === "In Progress"
                          ? "bg-amber-500 text-white border-amber-500 shadow-md shadow-amber-500/20"
                          : "bg-slate-700 text-white border-slate-700 shadow-md shadow-slate-700/20"
                        : "bg-white text-slate-600 border-slate-200 hover:bg-slate-100"
                    }`}
                  >
                    {st === "Completed" && <CheckCircle className="w-4 h-4" />}
                    {st === "In Progress" && <Clock className="w-4 h-4" />}
                    {st === "Not Started" && <BookOpen className="w-4 h-4" />}
                    <span>{statusConfigs[st].label}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Bilingual Title Card or Editable Fields */}
          {isEditing ? (
            <div className="p-4 bg-slate-50/50 rounded-xl border border-slate-200 space-y-4">
              <h5 className="font-semibold text-slate-800 text-xs uppercase tracking-wider">Chỉnh sửa thông tin</h5>
              <div>
                <label className="block text-[11px] font-medium text-slate-600 mb-1">Tiêu đề (Bilingual hoặc Đơn ngữ)</label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-3 py-1.5 text-xs border border-slate-200 rounded-lg focus:ring-1 focus:ring-indigo-500 bg-white text-slate-950 font-semibold"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[11px] font-medium text-slate-600 mb-1">Emoji đại diện</label>
                  <input
                    type="text"
                    value={emoji}
                    onChange={(e) => setEmoji(e.target.value)}
                    className="w-full px-3 py-1.5 text-xs border border-slate-200 rounded-lg focus:ring-1 focus:ring-indigo-500 bg-white text-slate-950 text-center"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-medium text-slate-600 mb-1">Thứ tự hiển thị</label>
                  <input
                    type="number"
                    value={order}
                    onChange={(e) => setOrder(Number(e.target.value))}
                    className="w-full px-3 py-1.5 text-xs border border-slate-200 rounded-lg focus:ring-1 focus:ring-indigo-500 bg-white text-slate-950"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-medium text-slate-600 mb-1">Nội dung giải thích chi tiết</label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={6}
                  className="w-full px-3 py-1.5 text-xs border border-slate-200 rounded-lg focus:ring-1 focus:ring-indigo-500 bg-white text-slate-950 font-mono resize-none"
                />
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setIsEditing(false)}
                  className="px-3 py-1.5 text-xs text-slate-500 hover:bg-slate-200 rounded-lg transition-colors"
                >
                  Hủy bỏ
                </button>
                <button
                  type="button"
                  onClick={handleSave}
                  className="px-3 py-1.5 text-xs text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg font-medium flex items-center gap-1 transition-colors"
                >
                  <Save className="w-3.5 h-3.5" />
                  Lưu thay đổi
                </button>
              </div>
            </div>
          ) : (
            <div className="space-y-5">
              
              {/* Step Detail Illustration Banner */}
              <div className="relative w-full h-32 overflow-hidden rounded-2xl bg-slate-100 border border-slate-100 select-none">
                <img 
                  src={getStepIllustration(step.title, step.order)} 
                  alt={step.title} 
                  className="w-full h-full object-cover"
                  referrerPolicy="no-referrer"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-slate-900/10 to-transparent pointer-events-none" />
              </div>

              {/* Title Section */}
              <div className="space-y-1">
                <div className="flex justify-between items-start gap-4">
                  <div>
                    {enTitle ? (
                      <>
                        <h3 className="text-lg font-bold text-slate-900 tracking-tight leading-snug">
                          {viTitle}
                        </h3>
                        <p className="text-sm text-slate-400 font-medium tracking-tight">
                          {enTitle}
                        </p>
                      </>
                    ) : (
                      <h3 className="text-lg font-bold text-slate-900 tracking-tight leading-snug">
                        {step.title}
                      </h3>
                    )}
                  </div>
                  <button
                    onClick={() => setIsEditing(true)}
                    className="p-1.5 bg-slate-100 hover:bg-indigo-50 hover:text-indigo-600 rounded-lg text-slate-500 transition-colors shrink-0 cursor-pointer"
                    title="Chỉnh sửa thông tin"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                </div>
                <div className="text-[11px] font-semibold text-indigo-600 uppercase tracking-widest bg-indigo-50/50 border border-indigo-100 px-2 py-0.5 rounded w-max mt-2">
                  Bước {step.order}
                </div>
              </div>

              {/* Description Content */}
              <div className="space-y-3 pt-2">
                <h5 className="font-bold text-slate-700 text-xs flex items-center gap-1.5">
                  <CheckSquare className="w-4 h-4 text-indigo-500" />
                  Tài liệu & Hướng dẫn học tập
                </h5>
                
                {/* Visual markdown/concept text */}
                <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100 prose prose-slate max-w-none text-xs text-slate-700 leading-relaxed space-y-3 whitespace-pre-wrap font-sans">
                  {step.description}
                </div>
              </div>

              {/* Sample study checklist box */}
              <div className="bg-emerald-50/50 border border-emerald-100 rounded-2xl p-4 space-y-2.5">
                <h6 className="font-bold text-emerald-800 text-xs flex items-center gap-1.5">
                  <CheckSquare className="w-4 h-4 text-emerald-600" />
                  Mục tiêu cần đạt (Checklist)
                </h6>
                <ul className="text-xs text-emerald-950 space-y-2">
                  <li className="flex items-center gap-2">
                    <input type="checkbox" defaultChecked={step.status === "Completed"} className="rounded border-emerald-300 text-emerald-600 focus:ring-emerald-500" />
                    <span>Nắm vững lý thuyết cốt lõi của khái niệm này</span>
                  </li>
                  <li className="flex items-center gap-2">
                    <input type="checkbox" defaultChecked={step.status === "Completed"} className="rounded border-emerald-300 text-emerald-600 focus:ring-emerald-500" />
                    <span>Viết và chạy thành công code ví dụ minh hoạ</span>
                  </li>
                  <li className="flex items-center gap-2">
                    <input type="checkbox" className="rounded border-emerald-300 text-emerald-600 focus:ring-emerald-500" />
                    <span>Giải quyết bài tập trắc nghiệm/vấn đáp</span>
                  </li>
                </ul>
              </div>
            </div>
          )}
        </div>

        {/* Drawer Footer actions */}
        <div className="p-4 bg-slate-50 border-t border-slate-100 flex justify-between gap-3 shrink-0">
          <button
            type="button"
            onClick={() => {
              if (confirm("Bạn có chắc chắn muốn xóa vĩnh viễn bước học này? Toàn bộ các đường nối đi kèm sẽ biến mất.")) {
                onDeleteStep(step.id);
                onClose();
              }
            }}
            className="px-3 py-2 border border-red-200 text-red-600 hover:bg-red-50 text-xs font-semibold rounded-xl flex items-center gap-1.5 transition-colors cursor-pointer"
          >
            <Trash2 className="w-3.5 h-3.5" />
            <span>Xóa Bước</span>
          </button>
          <button
            type="button"
            onClick={onClose}
            className="px-5 py-2 bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold rounded-xl transition-colors cursor-pointer flex items-center gap-1.5 shadow-sm"
          >
            <span>← Quay lại</span>
          </button>
        </div>
      </div>
    </div>
  );
}
