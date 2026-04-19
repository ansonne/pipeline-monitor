import { notFound } from "next/navigation";
import { api } from "@/lib/api";
import { PipelineDetail } from "@/components/pipeline-detail";

export const dynamic = "force-dynamic";

export default async function PipelinePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  let pipeline;
  try {
    pipeline = await api.pipelines.get(id);
  } catch {
    notFound();
  }

  let runs: import("@/lib/types").Run[] = [];
  try {
    runs = await api.runs.list(id);
  } catch {
    // ignore
  }

  return <PipelineDetail pipeline={pipeline} initialRuns={runs} />;
}
