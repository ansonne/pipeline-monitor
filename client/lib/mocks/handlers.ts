import { http, HttpResponse } from "msw";
import { mockPipelines, mockRuns } from "./data";
import type { Run } from "../types";

const BASE = "http://localhost:4000/api";

let pipelines = [...mockPipelines];
let runs = [...mockRuns];

export const handlers = [
  http.get(`${BASE}/pipelines`, () =>
    HttpResponse.json({ data: pipelines })
  ),

  http.get(`${BASE}/pipelines/:id`, ({ params }) => {
    const p = pipelines.find((p) => p.id === params.id);
    if (!p) return HttpResponse.json({ error: "not found" }, { status: 404 });
    return HttpResponse.json({ data: p });
  }),

  http.post(`${BASE}/pipelines`, async ({ request }) => {
    const body = await request.json() as { name: string; steps: unknown[] };
    const p = { id: crypto.randomUUID(), name: body.name, inserted_at: new Date().toISOString(), steps: [] };
    pipelines = [p, ...pipelines];
    return HttpResponse.json({ data: p }, { status: 201 });
  }),

  http.delete(`${BASE}/pipelines/:id`, ({ params }) => {
    pipelines = pipelines.filter((p) => p.id !== params.id);
    return new HttpResponse(null, { status: 204 });
  }),

  http.post(`${BASE}/pipelines/:id/runs`, ({ params }) => {
    const run: Run = {
      id: crypto.randomUUID(),
      pipeline_id: params.id as string,
      status: "pending",
      started_at: null,
      finished_at: null,
      step_results: [],
    };
    runs = [run, ...runs];
    return HttpResponse.json({ data: run }, { status: 201 });
  }),

  http.get(`${BASE}/pipelines/:id/runs`, ({ params }) => {
    const pipelineRuns = runs.filter((r) => r.pipeline_id === params.id);
    return HttpResponse.json({ data: pipelineRuns });
  }),

  http.get(`${BASE}/runs/:id`, ({ params }) => {
    const run = runs.find((r) => r.id === params.id);
    if (!run) return HttpResponse.json({ error: "not found" }, { status: 404 });
    return HttpResponse.json({ data: run });
  }),
];
