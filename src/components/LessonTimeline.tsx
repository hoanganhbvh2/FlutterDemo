import React, { useState } from "react";
import { Plus, Edit2, Trash2, ChevronRight, CheckCircle, HelpCircle, Save, X } from "lucide-react";
import { Lesson } from "../types";

interface LessonTimelineProps {
  lessons: Lesson[];
  selectedLessonId: string | null;
  onSelectLesson: (id: string) => void;
  onAddLesson: (title: string, description: string) => void;
  onEditLesson: (id: string, updates: Partial<Lesson>) => void;
  onDeleteLesson: (id: string) => void;
}

export default function LessonTimeline({
  lessons,
  selectedLessonId,
  onSelectLesson,
  onAddLesson,
  onEditLesson,
  onDeleteLesson,
}: LessonTimelineProps) {
  const [isAdding, setIsAdding] = useState(false);
  const [newTitle, setNewTitle] = useState("");
  const [newDesc, setNewDesc] = useState("");
  
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editTitle, setEditTitle] = useState("");
  const [editDesc, setEditDesc] = useState("");

  const handleSubmitAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;
    onAddLesson(newTitle.trim(), newDesc.trim());
    setNewTitle("");
    setNewDesc("");
    setIsAdding(false);
  };

  const handleStartEdit = (lesson: Lesson, e: React.MouseEvent) => {
    e.stopPropagation(); // Avoid selecting
    setEditingId(lesson.id);
    setEditTitle(lesson.title);
    setEditDesc(lesson.description);
  };

  const handleSaveEdit = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (!editTitle.trim()) return;
    onEditLesson(id, { title: editTitle.trim(), description: editDesc.trim() });
    setEditingId(null);
  };

  // Check the overall completion rate of a lesson based on step nodes
  const getLessonProgress = (lesson: Lesson) => {
    if (!lesson.nodes || lesson.nodes.length === 0) return { completed: 0, total: 0, percent: 0 };
    const completed = lesson.nodes.filter(n => n.status === "Completed").length;
    const total = lesson.nodes.length;
    return {
      completed,
      total,
      percent: Math.round((completed / total) * 100)
    };
  };

  return (
    <div className="bg-white rounded-2xl border border-slate-100 p-5 space-y-6 shadow-sm">
      <div className="flex justify-between items-center pb-2 border-b border-slate-50">
        <div>
          <h4 className="font-semibold text-slate-900 text-sm">Danh sách bài học</h4>
          <p className="text-xs text-slate-400">Chọn bài học để xem sơ đồ kiến thức</p>
        </div>
        <button
          onClick={() => setIsAdding(!isAdding)}
          className="p-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-600 rounded-lg border border-indigo-100 hover:border-indigo-200 transition-all flex items-center gap-1 text-xs font-medium cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Thêm bài</span>
        </button>
      </div>

      {/* Add Lesson inline form */}
      {isAdding && (
        <form onSubmit={handleSubmitAdd} className="p-3.5 bg-slate-50 rounded-xl border border-slate-100 space-y-2.5 animate-in slide-in-from-top duration-150">
          <div>
            <input
              type="text"
              required
              placeholder="Tên bài học (VD: OOP Basics)"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              className="w-full px-3 py-1.5 text-xs border border-slate-200 rounded-lg focus:ring-1 focus:ring-indigo-500 outline-none bg-white text-slate-950"
            />
          </div>
          <div>
            <input
              type="text"
              placeholder="Mô tả ngắn"
              value={newDesc}
              onChange={(e) => setNewDesc(e.target.value)}
              className="w-full px-3 py-1.5 text-xs border border-slate-200 rounded-lg focus:ring-1 focus:ring-indigo-500 outline-none bg-white text-slate-950"
            />
          </div>
          <div className="flex justify-end gap-1.5">
            <button
              type="button"
              onClick={() => setIsAdding(false)}
              className="px-2.5 py-1 text-xs text-slate-500 hover:bg-slate-200 rounded-md transition-colors"
            >
              Hủy
            </button>
            <button
              type="submit"
              className="px-2.5 py-1 text-xs text-white bg-indigo-600 hover:bg-indigo-700 rounded-md transition-colors font-medium"
            >
              Lưu bài học
            </button>
          </div>
        </form>
      )}

      {/* Elegant Vertical Progress Timeline */}
      <div className="relative pl-2 pr-2 py-2">
        {lessons.length === 0 ? (
          <div className="text-center py-8 bg-slate-50 rounded-2xl border border-dashed border-slate-150">
            <HelpCircle className="w-8 h-8 text-slate-300 mx-auto mb-2" />
            <p className="text-xs text-slate-400 font-medium">Chưa có bài học nào được khởi tạo.</p>
          </div>
        ) : (
          <div className="relative pl-6 space-y-4">
            
            {/* Left Vertical Timeline track */}
            <div className="absolute top-5 bottom-5 left-[19px] w-0.5 bg-slate-100 pointer-events-none z-0" />

            {lessons
              .sort((a, b) => a.order - b.order)
              .map((lesson, idx) => {
                const isSelected = selectedLessonId === lesson.id;
                const progress = getLessonProgress(lesson);

                return (
                  <div
                    key={lesson.id}
                    onClick={() => onSelectLesson(lesson.id)}
                    className="relative z-10 cursor-pointer group transition-all duration-200"
                  >
                    {/* Small dot on the vertical track */}
                    <div className="absolute -left-[24px] top-4 -translate-x-1/2 w-2.5 h-2.5 rounded-full border-2 border-white bg-slate-300 group-hover:bg-indigo-400 z-10 transition-colors" />

                    {/* Lesson Card */}
                    <div 
                      className={`w-full bg-white hover:bg-slate-50 border p-4 rounded-xl transition-all duration-200 flex gap-3.5 ${
                        isSelected 
                          ? "border-indigo-600 ring-4 ring-indigo-50 shadow-md translate-x-1" 
                          : "border-slate-100 shadow-sm hover:shadow"
                      }`}
                    >
                      {/* Numbered Avatar */}
                      <div className="flex flex-col items-center shrink-0">
                        <div className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs transition-all duration-200 ${
                          isSelected
                            ? "bg-indigo-600 text-white shadow-md shadow-indigo-500/20"
                            : progress.percent === 100
                            ? "bg-emerald-500 text-white"
                            : "bg-slate-100 text-slate-500 group-hover:bg-indigo-50 group-hover:text-indigo-600"
                        }`}>
                          {progress.percent === 100 ? (
                            <CheckCircle className="w-4.5 h-4.5" />
                          ) : (
                            idx + 1
                          )}
                        </div>
                        {progress.total > 0 && (
                          <span className="text-[10px] mt-1 text-slate-400 font-semibold">
                            {progress.completed}/{progress.total}
                          </span>
                        )}
                      </div>

                      {/* Content details */}
                      <div className="flex-1 min-w-0">
                        {editingId === lesson.id ? (
                          <div className="space-y-1.5" onClick={(e) => e.stopPropagation()}>
                            <input
                              type="text"
                              value={editTitle}
                              onChange={(e) => setEditTitle(e.target.value)}
                              className="w-full text-xs font-semibold px-2 py-1 border border-slate-200 rounded text-slate-900"
                            />
                            <input
                              type="text"
                              value={editDesc}
                              onChange={(e) => setEditDesc(e.target.value)}
                              className="w-full text-[11px] px-2 py-1 border border-slate-200 rounded text-slate-600"
                            />
                            <div className="flex justify-end gap-1">
                              <button
                                onClick={() => setEditingId(null)}
                                className="p-1 hover:bg-slate-200 rounded text-slate-500"
                              >
                                <X className="w-3.5 h-3.5" />
                              </button>
                              <button
                                onClick={(e) => handleSaveEdit(lesson.id, e)}
                                className="p-1 bg-indigo-50 hover:bg-indigo-100 rounded text-indigo-600"
                              >
                                <Save className="w-3.5 h-3.5" />
                              </button>
                            </div>
                          </div>
                        ) : (
                          <>
                            <div className="flex items-center justify-between">
                              <h5 className={`font-bold text-xs truncate transition-colors ${
                                isSelected ? "text-indigo-600" : "text-slate-800 group-hover:text-indigo-600"
                              }`}>
                                {lesson.title}
                              </h5>
                              
                              {/* Edit / Delete actions on hover */}
                              <div className="opacity-0 group-hover:opacity-100 flex gap-0.5 ml-1 shrink-0 transition-opacity">
                                <button
                                  onClick={(e) => handleStartEdit(lesson, e)}
                                  className="p-1 hover:bg-slate-100 rounded text-slate-400 hover:text-indigo-600 transition-colors"
                                  title="Sửa bài học"
                                >
                                  <Edit2 className="w-3.5 h-3.5" />
                                </button>
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    if (confirm("Bạn có chắc chắn muốn xóa bài học này? Toàn bộ các bước học (step) đi kèm sẽ bị xóa.")) {
                                      onDeleteLesson(lesson.id);
                                    }
                                  }}
                                  className="p-1 hover:bg-slate-100 rounded text-slate-400 hover:text-red-600 transition-colors"
                                  title="Xóa bài học"
                                >
                                  <Trash2 className="w-3.5 h-3.5" />
                                </button>
                              </div>
                            </div>
                            <p className="text-[11px] text-slate-400 line-clamp-1 mt-0.5 leading-relaxed">
                              {lesson.description || "Chưa có mô tả cụ thể."}
                            </p>
                            {/* ProgressBar */}
                            {progress.total > 0 && (
                              <div className="w-full bg-slate-150 h-1 rounded-full mt-2 overflow-hidden">
                                <div 
                                  className={`h-full rounded-full transition-all duration-300 ${
                                    progress.percent === 100 ? "bg-emerald-500" : "bg-indigo-500"
                                  }`}
                                  style={{ width: `${progress.percent}%` }}
                                />
                              </div>
                            )}
                          </>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
          </div>
        )}
      </div>
    </div>
  );
}
