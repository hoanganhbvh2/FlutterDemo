import React, { useState } from "react";
import { Plus, Trash2, Link2, Unlink, CheckCircle, Clock, BookOpen, AlertCircle, Sparkles, ChevronDown, ChevronUp, BookMarked, HelpCircle, GraduationCap } from "lucide-react";
import { Step, Edge } from "../types";
import { getStepIllustration } from "../utils";

interface RoadmapCanvasProps {
  nodes: Step[];
  edges: Edge[];
  onUpdateNodePosition: (id: string, x: number, y: number) => void;
  onAddNode: (x: number, y: number) => void;
  onSelectNode: (id: string) => void;
  onConnectNodes: (fromId: string, toId: string) => void;
  onDisconnectNodes: (edgeId: string) => void;
  onDeleteNode: (id: string) => void;
}

export default function RoadmapCanvas({
  nodes,
  edges,
  onUpdateNodePosition,
  onAddNode,
  onSelectNode,
  onConnectNodes,
  onDisconnectNodes,
  onDeleteNode,
}: RoadmapCanvasProps) {
  const [showConnectorForStep, setShowConnectorForStep] = useState<string | null>(null);

  // Sort nodes by order, fallback to ID
  const sortedNodes = [...nodes].sort((a, b) => a.order - b.order);

  // Get completed stats
  const completedCount = nodes.filter((n) => n.status === "Completed").length;
  const inProgressCount = nodes.filter((n) => n.status === "In Progress").length;
  const totalCount = nodes.length;
  const percentCompleted = totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0;

  // Handle adding new step node
  const handleAddNewStep = () => {
    // Generate position parameters or simple offsets (not used visual but good for data)
    onAddNode(0, 0);
  };

  return (
    <div className="flex flex-col h-full bg-slate-50 select-none">
      
      {/* Sub-Header: Progress Metrics & Quick Actions */}
      <div className="bg-white px-4 py-3 border-b border-slate-100 flex flex-col gap-2 shrink-0 z-10 shadow-2xs">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1.5">
            <BookMarked className="w-4 h-4 text-indigo-600" />
            <span className="text-xs font-black text-slate-800">Tiến trình Khái niệm ({completedCount}/{totalCount})</span>
          </div>
          <button
            onClick={handleAddNewStep}
            className="px-2.5 py-1 bg-indigo-600 hover:bg-indigo-700 text-white text-[10px] font-bold rounded-lg flex items-center gap-1 shadow-sm transition-all"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>Thêm khái niệm</span>
          </button>
        </div>

        {/* Beautiful Compact Progress Bar */}
        <div className="space-y-1">
          <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden flex">
            <div 
              className="h-full bg-emerald-500 rounded-l-full transition-all duration-300" 
              style={{ width: `${percentCompleted}%` }}
            />
            <div 
              className="h-full bg-amber-400 transition-all duration-300" 
              style={{ width: `${totalCount > 0 ? (inProgressCount / totalCount) * 100 : 0}%` }}
            />
          </div>
          <div className="flex justify-between items-center text-[8px] text-slate-400 font-bold">
            <span className="flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" /> Hoàn thành: {percentCompleted}%
            </span>
            <span className="flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-amber-400" /> Đang học: {inProgressCount}
            </span>
            <span className="flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-slate-300" /> Chưa học: {totalCount - completedCount - inProgressCount}
            </span>
          </div>
        </div>
      </div>

      {/* Main Roadmap Steps Area */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4 pb-24">
        {sortedNodes.length === 0 ? (
          <div className="text-center py-16 bg-white rounded-2xl border border-dashed border-slate-200 p-6 space-y-3">
            <HelpCircle className="w-10 h-10 text-slate-300 mx-auto" />
            <div>
              <h5 className="font-bold text-slate-800 text-xs">Chưa có khái niệm nào</h5>
              <p className="text-[10px] text-slate-400 max-w-[200px] mx-auto mt-1 leading-relaxed">
                Bài học này đang trống. Hãy nhấp nút phía trên hoặc tự sinh giáo trình bằng AI.
              </p>
            </div>
            <button
              onClick={handleAddNewStep}
              className="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-[10px] font-bold rounded-lg border border-slate-200 transition-colors"
            >
              + Tạo khái niệm đầu tiên
            </button>
          </div>
        ) : (
          <div className="relative py-2 px-1">
            
            {/* Elegant vertical flow trail line down the middle of the timeline */}
            <div className="absolute top-4 bottom-4 left-1/2 -translate-x-1/2 w-0.5 border-l-2 border-dashed border-slate-200 pointer-events-none" />

            {sortedNodes.map((node, index) => {
              const isLeft = index % 2 === 0;
              // Find prerequisites of this node (edges where to === node.id)
              const prerequisites = edges.filter((e) => e.to === node.id);

              return (
                <div 
                  key={node.id} 
                  className={`relative w-full flex ${isLeft ? "justify-start" : "justify-end"} items-center py-3 min-h-[145px]`}
                >
                  {/* Central timeline milestone marker node */}
                  <div className={`absolute left-1/2 -translate-x-1/2 w-3.5 h-3.5 rounded-full border-2 bg-white transition-all duration-300 z-10 ${
                    node.status === "Completed" 
                      ? "border-emerald-500 bg-emerald-500 shadow-sm shadow-emerald-500/20" 
                      : node.status === "In Progress" 
                      ? "border-amber-400 bg-amber-400 shadow-sm shadow-amber-400/25 animate-pulse" 
                      : "border-slate-300 bg-white"
                  }`}>
                    {node.status === "In Progress" && (
                      <span className="absolute inset-0 rounded-full bg-amber-400/50 animate-ping" />
                    )}
                  </div>

                  {/* Horizontal visual connecting branch trail */}
                  <div className={`absolute top-1/2 -translate-y-1/2 h-[1.5px] ${
                    isLeft ? "left-[45%] right-[50%]" : "left-[50%] right-[45%]"
                  } border-t-2 border-dashed ${
                    node.status === "Completed" 
                      ? "border-emerald-200" 
                      : node.status === "In Progress" 
                      ? "border-amber-200 animate-pulse" 
                      : "border-slate-200"
                  }`} />

                  {/* Step Compact Card Container */}
                  <div 
                    onClick={() => onSelectNode(node.id)}
                    className={`w-[45%] bg-white rounded-xl border p-2 shadow-2xs hover:shadow-sm transition-all duration-200 cursor-pointer hover:border-indigo-400 group relative flex flex-col gap-1.5 ${
                      node.status === "Completed" 
                        ? "border-emerald-100 ring-1 ring-emerald-500/5" 
                        : node.status === "In Progress"
                        ? "border-amber-100 ring-1 ring-amber-500/5"
                        : "border-slate-150"
                    }`}
                  >
                    
                    {/* Visual Card Banner image illustration */}
                    <div className="relative w-full h-12 overflow-hidden rounded-lg bg-slate-100 border border-slate-100/50 shrink-0 select-none">
                      <img 
                        src={getStepIllustration(node.title, index)} 
                        alt={node.title} 
                        className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                        referrerPolicy="no-referrer"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-slate-900/10 to-transparent pointer-events-none" />
                      
                      {/* Compact floating emoji */}
                      <div className="absolute bottom-1 left-1 bg-white/95 backdrop-blur-xs w-4.5 h-4.5 rounded-md flex items-center justify-center text-xs shadow-2xs">
                        {node.emoji || "📝"}
                      </div>

                      {/* Small Quick Delete Icon directly accessible */}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          if (confirm(`Bạn muốn xóa bước học "Bước ${node.order}: ${node.title}"?`)) {
                            onDeleteNode(node.id);
                          }
                        }}
                        className="absolute top-1 right-1 opacity-0 group-hover:opacity-100 bg-white/90 hover:bg-red-50 text-slate-400 hover:text-red-500 p-1 rounded-md transition-all shadow-2xs"
                        title="Xóa khái niệm"
                      >
                        <Trash2 className="w-2.5 h-2.5" />
                      </button>
                    </div>

                    {/* Step order, Title */}
                    <div className="space-y-0.5">
                      <span className="text-[7.5px] text-indigo-600 font-extrabold uppercase tracking-wider block">
                        Bước {node.order}
                      </span>
                      <h5 className="font-extrabold text-slate-800 text-[10px] leading-tight line-clamp-1 group-hover:text-indigo-600 transition-colors">
                        {node.title}
                      </h5>
                    </div>

                    {/* Step short description text */}
                    <p className="text-[9px] text-slate-400 leading-normal line-clamp-1">
                      {node.description || "Chưa bổ sung mô tả."}
                    </p>

                    {/* Status badge and Pre-req status indicator */}
                    <div className="flex items-center justify-between text-[8px] border-t border-slate-50 pt-1 mt-0.5 shrink-0">
                      <span className={`px-1 rounded-sm font-bold scale-[0.95] origin-left ${
                        node.status === "Completed" 
                          ? "bg-emerald-50 text-emerald-700" 
                          : node.status === "In Progress"
                          ? "bg-amber-50 text-amber-700"
                          : "bg-slate-50 text-slate-400"
                      }`}>
                        {node.status === "Completed" ? "Đã xong" : node.status === "In Progress" ? "Đang học" : "Chưa học"}
                      </span>
                      
                      {prerequisites.length > 0 && (
                        <span className="text-[7.5px] text-slate-400 font-bold flex items-center gap-0.5">
                          <Link2 className="w-2.5 h-2.5 text-slate-300" />
                          {prerequisites.length}
                        </span>
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
