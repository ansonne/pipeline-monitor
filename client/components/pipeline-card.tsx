"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import type { Pipeline } from "@/lib/types";
import { api } from "@/lib/api";
import { Trash2, Play, ChevronRight } from "lucide-react";

const STEP_TYPE_COLORS: Record<string, string> = {
  http: "bg-blue-900 text-blue-300",
  mock_ai: "bg-purple-900 text-purple-300",
  transform: "bg-amber-900 text-amber-300",
  notification: "bg-green-900 text-green-300",
};

export function PipelineCard({ pipeline }: { pipeline: Pipeline }) {
  const router = useRouter();

  async function handleTrigger(e: React.MouseEvent) {
    e.preventDefault();
    const run = await api.runs.trigger(pipeline.id);
    router.push(`/runs/${run.id}`);
  }

  async function handleDelete(e: React.MouseEvent) {
    e.preventDefault();
    if (!confirm(`Delete "${pipeline.name}"?`)) return;
    await api.pipelines.delete(pipeline.id);
    router.refresh();
  }

  return (
    <Link
      href={`/pipelines/${pipeline.id}`}
      className="group block border border-[#2a2a2a] rounded-lg p-5 hover:border-violet-600 transition-colors bg-[#1a1a1a]"
    >
      <div className="flex items-start justify-between">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h2 className="font-medium text-[#f5f5f5] truncate">{pipeline.name}</h2>
            <ChevronRight className="w-4 h-4 text-neutral-500 group-hover:text-violet-400 transition-colors" />
          </div>
          <p className="text-xs text-neutral-500 mt-1">
            {pipeline.steps.length} step{pipeline.steps.length !== 1 ? "s" : ""} ·{" "}
            {new Date(pipeline.inserted_at).toLocaleDateString()}
          </p>
          <div className="flex gap-1.5 mt-3 flex-wrap">
            {pipeline.steps.map((s) => (
              <span
                key={s.id}
                className={`text-xs px-2 py-0.5 rounded-full font-mono ${STEP_TYPE_COLORS[s.type] ?? "bg-neutral-800 text-neutral-300"}`}
              >
                {s.type}
              </span>
            ))}
          </div>
        </div>
        <div className="flex gap-2 ml-4">
          <button
            onClick={handleTrigger}
            className="p-2 rounded-md bg-violet-700 hover:bg-violet-600 transition-colors"
            title="Run pipeline"
          >
            <Play className="w-4 h-4" />
          </button>
          <button
            onClick={handleDelete}
            className="p-2 rounded-md bg-[#262626] hover:bg-red-900 transition-colors"
            title="Delete pipeline"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    </Link>
  );
}
