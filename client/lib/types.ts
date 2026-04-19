export type StepType = "http" | "mock_ai" | "transform" | "notification";
export type RunStatus = "pending" | "running" | "completed" | "failed";
export type StepResultStatus = "pending" | "running" | "completed" | "failed";

export interface Step {
  id: string;
  type: StepType;
  order: number;
  config: Record<string, unknown>;
}

export interface Pipeline {
  id: string;
  name: string;
  inserted_at: string;
  steps: Step[];
}

export interface StepResult {
  id: string;
  step_id: string;
  status: StepResultStatus;
  input: Record<string, unknown>;
  output: Record<string, unknown> | null;
  error: string | null;
  duration_ms: number | null;
}

export interface Run {
  id: string;
  pipeline_id: string;
  status: RunStatus;
  started_at: string | null;
  finished_at: string | null;
  step_results: StepResult[];
}

export interface CreatePipelinePayload {
  name: string;
  steps: Array<{
    type: StepType;
    order: number;
    config: Record<string, unknown>;
  }>;
}
