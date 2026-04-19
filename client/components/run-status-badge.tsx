import type { RunStatus, StepResultStatus } from "@/lib/types";

const STYLES: Record<RunStatus | StepResultStatus, string> = {
  pending: "bg-neutral-700 text-neutral-300",
  running: "bg-blue-900 text-blue-300 animate-pulse",
  completed: "bg-green-900 text-green-300",
  failed: "bg-red-900 text-red-300",
};

export function RunStatusBadge({ status }: { status: RunStatus | StepResultStatus }) {
  return (
    <span className={`text-xs font-mono px-2 py-0.5 rounded-full ${STYLES[status]}`}>
      {status}
    </span>
  );
}
