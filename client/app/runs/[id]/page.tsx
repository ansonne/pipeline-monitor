import { notFound } from "next/navigation";
import { api } from "@/lib/api";
import { RunViewer } from "@/components/run-viewer";

export const dynamic = "force-dynamic";

export default async function RunPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  let run;
  try {
    run = await api.runs.get(id);
  } catch {
    notFound();
  }

  return <RunViewer initialRun={run} />;
}
