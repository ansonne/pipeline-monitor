import Link from "next/link";
import { api } from "@/lib/api";
import type { Pipeline } from "@/lib/types";
import { PipelineCard } from "@/components/pipeline-card";

export const dynamic = "force-dynamic";

export default async function PipelinesPage() {
  let pipelines: Pipeline[] = [];
  try {
    pipelines = await api.pipelines.list();
  } catch {
    // backend not up yet — render empty state
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-semibold">Pipelines</h1>
          <p className="text-sm text-neutral-400 mt-1">
            {pipelines.length} pipeline{pipelines.length !== 1 ? "s" : ""}
          </p>
        </div>
      </div>

      {pipelines.length === 0 ? (
        <div className="border border-[#2a2a2a] rounded-lg p-12 text-center">
          <p className="text-neutral-400 mb-4">No pipelines yet.</p>
          <Link
            href="/pipelines/new"
            className="text-sm bg-violet-600 text-white px-4 py-2 rounded-md hover:bg-violet-500 transition-colors"
          >
            Create your first pipeline
          </Link>
        </div>
      ) : (
        <div className="grid gap-3">
          {pipelines.map((p) => (
            <PipelineCard key={p.id} pipeline={p} />
          ))}
        </div>
      )}
    </div>
  );
}
