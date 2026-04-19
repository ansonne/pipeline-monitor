import type { Pipeline, Run } from "../types";

export const mockPipelines: Pipeline[] = [
  {
    id: "pipeline-1",
    name: "Data Enrichment Pipeline",
    inserted_at: "2026-04-19T12:00:00Z",
    steps: [
      { id: "step-1", type: "http", order: 1, config: { url: "https://api.example.com/data", method: "GET" } },
      { id: "step-2", type: "transform", order: 2, config: { mappings: { result: "data" } } },
      { id: "step-3", type: "mock_ai", order: 3, config: {} },
      { id: "step-4", type: "notification", order: 4, config: { message: "Pipeline complete" } },
    ],
  },
  {
    id: "pipeline-2",
    name: "AI Summarization Flow",
    inserted_at: "2026-04-19T13:00:00Z",
    steps: [
      { id: "step-5", type: "mock_ai", order: 1, config: {} },
      { id: "step-6", type: "notification", order: 2, config: { message: "Summary sent" } },
    ],
  },
];

export const mockRuns: Run[] = [
  {
    id: "run-1",
    pipeline_id: "pipeline-1",
    status: "completed",
    started_at: "2026-04-19T12:01:00Z",
    finished_at: "2026-04-19T12:01:05Z",
    step_results: [
      { id: "sr-1", step_id: "step-1", status: "completed", input: {}, output: { data: "ok" }, error: null, duration_ms: 320 },
      { id: "sr-2", step_id: "step-2", status: "completed", input: { data: "ok" }, output: { result: "ok" }, error: null, duration_ms: 5 },
      { id: "sr-3", step_id: "step-3", status: "completed", input: { result: "ok" }, output: { ai_output: "Summary: positive trend." }, error: null, duration_ms: 440 },
      { id: "sr-4", step_id: "step-4", status: "completed", input: { ai_output: "Summary: positive trend." }, output: { notified: true }, error: null, duration_ms: 2 },
    ],
  },
];
