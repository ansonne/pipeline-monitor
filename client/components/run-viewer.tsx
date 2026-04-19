"use client";

import { useEffect, useState, useRef } from "react";
import Link from "next/link";
import type { Run, StepResult } from "@/lib/types";
import { RunStatusBadge } from "./run-status-badge";
import { ArrowLeft, Clock } from "lucide-react";

declare global {
  interface Window {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    Phoenix: any;
  }
}

export function RunViewer({ initialRun }: { initialRun: Run }) {
  const [run, setRun] = useState<Run>(initialRun);
  const socketRef = useRef<unknown>(null);

  useEffect(() => {
    if (run.status === "completed" || run.status === "failed") return;

    const connect = async () => {
      const { Socket } = await import("phoenix");
      const socket = new Socket(
        `${process.env.NEXT_PUBLIC_WS_URL ?? "ws://localhost:4000"}/socket`
      );
      socket.connect();
      socketRef.current = socket;

      const channel = socket.channel(`run:${run.id}`, {});
      channel.on("step_result", (payload: StepResult) => {
        setRun((prev) => {
          const existing = prev.step_results.findIndex((s) => s.id === payload.id);
          const results =
            existing >= 0
              ? prev.step_results.map((s) => (s.id === payload.id ? payload : s))
              : [...prev.step_results, payload];
          return { ...prev, step_results: results };
        });
      });

      channel.on("run_status", (payload: { run_id: string; status: Run["status"] }) => {
        setRun((prev) => ({ ...prev, status: payload.status }));
      });

      channel.join();
    };

    connect();

    return () => {
      if (socketRef.current) (socketRef.current as { disconnect: () => void }).disconnect();
    };
  }, [run.id, run.status]);

  return (
    <div>
      <Link href={`/pipelines/${run.pipeline_id}`} className="flex items-center gap-1 text-sm text-neutral-400 hover:text-[#f5f5f5] mb-6">
        <ArrowLeft className="w-4 h-4" /> Pipeline
      </Link>

      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-semibold font-mono">{run.id.slice(0, 8)}…</h1>
          {run.started_at && (
            <p className="text-sm text-neutral-400 mt-1">
              Started {new Date(run.started_at).toLocaleString()}
            </p>
          )}
        </div>
        <RunStatusBadge status={run.status} />
      </div>

      <div className="space-y-3">
        {run.step_results.length === 0 && run.status === "pending" && (
          <p className="text-sm text-neutral-500">Waiting for execution to start…</p>
        )}

        {run.step_results.map((result, i) => (
          <StepResultCard key={result.id} result={result} index={i + 1} />
        ))}

        {run.status === "running" && (
          <div className="border border-[#2a2a2a] rounded-lg p-4 bg-[#1a1a1a] animate-pulse">
            <span className="text-sm text-neutral-500">Executing…</span>
          </div>
        )}
      </div>

      {run.finished_at && (
        <div className="mt-6 text-sm text-neutral-500">
          Finished {new Date(run.finished_at).toLocaleString()}
          {run.started_at && (
            <span className="ml-2">
              ({Math.round((new Date(run.finished_at).getTime() - new Date(run.started_at).getTime()) / 1000)}s)
            </span>
          )}
        </div>
      )}
    </div>
  );
}

function StepResultCard({ result, index }: { result: StepResult; index: number }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="border border-[#2a2a2a] rounded-lg bg-[#1a1a1a] overflow-hidden">
      <button
        onClick={() => setExpanded((p) => !p)}
        className="w-full flex items-center gap-3 p-4 text-left hover:bg-[#222] transition-colors"
      >
        <span className="text-xs text-neutral-500 w-5 text-center">{index}</span>
        <RunStatusBadge status={result.status} />
        <span className="text-sm font-mono text-neutral-300 flex-1">step {result.step_id.slice(0, 8)}</span>
        {result.duration_ms !== null && (
          <span className="text-xs text-neutral-500 flex items-center gap-1">
            <Clock className="w-3 h-3" /> {result.duration_ms}ms
          </span>
        )}
      </button>

      {expanded && (
        <div className="border-t border-[#2a2a2a] p-4 space-y-3">
          {result.error && (
            <div>
              <p className="text-xs text-red-400 font-semibold mb-1">Error</p>
              <pre className="text-xs text-red-300 bg-red-950 p-2 rounded overflow-x-auto">{result.error}</pre>
            </div>
          )}
          {result.output && (
            <div>
              <p className="text-xs text-neutral-400 font-semibold mb-1">Output</p>
              <pre className="text-xs text-neutral-300 bg-[#111] p-2 rounded overflow-x-auto">
                {JSON.stringify(result.output, null, 2)}
              </pre>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
