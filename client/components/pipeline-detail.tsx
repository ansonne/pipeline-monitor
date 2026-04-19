"use client";

import { useRouter } from "next/navigation";
import Link from "next/link";
import type { Pipeline, Run } from "@/lib/types";
import { api } from "@/lib/api";
import { Play, ArrowLeft } from "lucide-react";
import { RunStatusBadge } from "./run-status-badge";

export function PipelineDetail({ pipeline, initialRuns }: { pipeline: Pipeline; initialRuns: Run[] }) {
  const router = useRouter();

  async function handleTrigger() {
    const run = await api.runs.trigger(pipeline.id);
    router.push(`/runs/${run.id}`);
  }

  return (
    <div>
      <Link href="/pipelines" className="flex items-center gap-1 text-sm text-neutral-400 hover:text-[#f5f5f5] mb-6">
        <ArrowLeft className="w-4 h-4" /> Pipelines
      </Link>

      <div className="flex items-start justify-between mb-8">
        <div>
          <h1 className="text-2xl font-semibold">{pipeline.name}</h1>
          <p className="text-sm text-neutral-400 mt-1">Created {new Date(pipeline.inserted_at).toLocaleString()}</p>
        </div>
        <button
          onClick={handleTrigger}
          className="flex items-center gap-2 bg-violet-600 hover:bg-violet-500 text-white px-4 py-2 rounded-md transition-colors text-sm"
        >
          <Play className="w-4 h-4" /> Run
        </button>
      </div>

      <section className="mb-8">
        <h2 className="text-sm font-semibold text-neutral-400 uppercase tracking-wider mb-3">Steps</h2>
        <div className="space-y-2">
          {pipeline.steps.map((step, i) => (
            <div key={step.id} className="flex items-center gap-3 border border-[#2a2a2a] rounded-lg p-4 bg-[#1a1a1a]">
              <span className="text-xs text-neutral-500 w-5 text-center">{i + 1}</span>
              <span className="font-mono text-sm text-violet-300">{step.type}</span>
              {typeof step.config.url === "string" && (
                <span className="text-xs text-neutral-500 truncate">{step.config.url}</span>
              )}
              {typeof step.config.message === "string" && (
                <span className="text-xs text-neutral-500 truncate">{step.config.message}</span>
              )}
            </div>
          ))}
        </div>
      </section>

      <section>
        <h2 className="text-sm font-semibold text-neutral-400 uppercase tracking-wider mb-3">Recent Runs</h2>
        {initialRuns.length === 0 ? (
          <p className="text-sm text-neutral-500">No runs yet. Click Run to start.</p>
        ) : (
          <div className="space-y-2">
            {initialRuns.map((run) => (
              <Link
                key={run.id}
                href={`/runs/${run.id}`}
                className="flex items-center justify-between border border-[#2a2a2a] rounded-lg p-4 bg-[#1a1a1a] hover:border-violet-600 transition-colors"
              >
                <div>
                  <span className="text-sm font-mono text-neutral-300">{run.id.slice(0, 8)}…</span>
                  {run.started_at && (
                    <span className="text-xs text-neutral-500 ml-3">
                      {new Date(run.started_at).toLocaleString()}
                    </span>
                  )}
                </div>
                <RunStatusBadge status={run.status} />
              </Link>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
