import React, { useState } from "react";
import { BookOpen, Layers, Edit2, Trash2, CheckCircle, HelpCircle, Save, X } from "lucide-react";
import { Topic } from "../types";

interface TopicCardProps {
  key?: string;
  topic: Topic;
  onSelect: () => void;
  onEdit: (id: string, updates: Partial<Topic>) => void;
  onDelete: (id: string) => void;
}

export default function TopicCard({
  topic,
  onSelect,
  onEdit,
  onDelete,
}: TopicCardProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(topic.title);
  const [editDesc, setEditDesc] = useState(topic.description);
  const [editEmoji, setEditEmoji] = useState(topic.emoji);

  const handleSave = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!editTitle.trim()) return;
    onEdit(topic.id, {
      title: editTitle.trim(),
      description: editDesc.trim(),
      emoji: editEmoji.trim(),
    });
    setIsEditing(false);
  };

  const handleStartEdit = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsEditing(true);
  };

  const handleCancelEdit = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsEditing(false);
    setEditTitle(topic.title);
    setEditDesc(topic.description);
    setEditEmoji(topic.emoji);
  };

  // Calculate stats for lessons and steps
  const lessonsCount = topic.lessons.length;
  const steps = topic.lessons.flatMap((l) => l.nodes || []);
  const stepsCount = steps.length;
  const completedStepsCount = steps.filter((s) => s.status === "Completed").length;
  
  const completionPercent = stepsCount > 0 
    ? Math.round((completedStepsCount / stepsCount) * 100) 
    : 0;

  return (
    <div
      onClick={() => !isEditing && onSelect()}
      className={`bg-white rounded-2xl border border-slate-100 p-5 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between group h-full relative cursor-pointer ${
        isEditing ? "cursor-default" : "hover:-translate-y-0.5"
      }`}
    >
      
      {/* Top Section */}
      <div className="space-y-4">
        {isEditing ? (
          <div className="space-y-2.5" onClick={(e) => e.stopPropagation()}>
            <div className="flex gap-2">
              <input
                type="text"
                value={editEmoji}
                onChange={(e) => setEditEmoji(e.target.value)}
                className="w-12 px-2 py-1 border border-slate-200 rounded-lg text-center font-bold text-lg text-slate-950 bg-slate-50"
                title="Emoji"
              />
              <input
                type="text"
                value={editTitle}
                onChange={(e) => setEditTitle(e.target.value)}
                className="flex-1 px-3 py-1 border border-slate-200 rounded-lg text-xs font-semibold text-slate-950 bg-slate-50"
                placeholder="Tên chủ đề"
              />
            </div>
            <textarea
              value={editDesc}
              onChange={(e) => setEditDesc(e.target.value)}
              className="w-full px-3 py-1.5 border border-slate-200 rounded-lg text-xs text-slate-700 bg-slate-50 resize-none"
              rows={2}
              placeholder="Mô tả"
            />
            <div className="flex justify-end gap-1">
              <button
                onClick={handleCancelEdit}
                className="p-1 hover:bg-slate-100 rounded text-slate-500"
              >
                <X className="w-4 h-4" />
              </button>
              <button
                onClick={handleSave}
                className="p-1 bg-indigo-50 hover:bg-indigo-100 rounded text-indigo-600"
              >
                <Save className="w-4 h-4" />
              </button>
            </div>
          </div>
        ) : (
          <>
            <div className="flex justify-between items-start">
              {/* Emoji badge */}
              <div className="w-12 h-12 bg-slate-50 border border-slate-100 rounded-2xl flex items-center justify-center text-2xl shadow-sm group-hover:scale-105 transition-transform duration-200">
                {topic.emoji}
              </div>

              {/* Action buttons (only on hover) */}
              <div className="opacity-0 group-hover:opacity-100 flex gap-1 transition-opacity duration-150">
                <button
                  onClick={handleStartEdit}
                  className="p-1.5 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-indigo-600 transition-colors cursor-pointer"
                  title="Chỉnh sửa chủ đề"
                >
                  <Edit2 className="w-3.5 h-3.5" />
                </button>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    if (confirm(`Bạn có chắc chắn muốn xóa chủ đề "${topic.title}"?`)) {
                      onDelete(topic.id);
                    }
                  }}
                  className="p-1.5 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-red-500 transition-colors cursor-pointer"
                  title="Xóa chủ đề"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            {/* Title & description */}
            <div className="space-y-1">
              <h4 className="font-bold text-slate-900 group-hover:text-indigo-600 transition-colors text-sm line-clamp-1">
                {topic.title}
              </h4>
              <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">
                {topic.description || "Chưa có mô tả cụ thể."}
              </p>
            </div>
          </>
        )}
      </div>

      {/* Bottom Progress and Statistics Section */}
      <div className="mt-5 pt-4 border-t border-slate-50 space-y-3">
        {/* Statistics Counts */}
        <div className="flex gap-4 text-[11px] text-slate-400">
          <span className="flex items-center gap-1">
            <Layers className="w-3.5 h-3.5 text-slate-300" />
            <strong>{lessonsCount}</strong> bài học
          </span>
          <span className="flex items-center gap-1">
            <BookOpen className="w-3.5 h-3.5 text-slate-300" />
            <strong>{stepsCount}</strong> bước học
          </span>
        </div>

        {/* Learning Progress Indicator */}
        <div className="space-y-1">
          <div className="flex justify-between items-center text-[10px] font-semibold">
            <span className="text-slate-400">Tiến độ hoàn thành</span>
            <span className={completionPercent === 100 ? "text-emerald-500" : "text-indigo-500"}>
              {completionPercent}%
            </span>
          </div>

          <div className="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
            <div
              className={`h-full rounded-full transition-all duration-300 ${
                completionPercent === 100 ? "bg-emerald-500" : "bg-indigo-500"
              }`}
              style={{ width: `${completionPercent}%` }}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
