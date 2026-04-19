import type { Pipeline, Run, CreatePipelinePayload } from "./types";

const BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000/api";

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...init,
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`API ${res.status}: ${body}`);
  }

  const json = await res.json();
  return json.data as T;
}

export const api = {
  pipelines: {
    list: () => request<Pipeline[]>("/pipelines"),
    get: (id: string) => request<Pipeline>(`/pipelines/${id}`),
    create: (payload: CreatePipelinePayload) =>
      request<Pipeline>("/pipelines", {
        method: "POST",
        body: JSON.stringify(payload),
      }),
    delete: (id: string) =>
      fetch(`${BASE}/pipelines/${id}`, { method: "DELETE" }),
  },
  runs: {
    trigger: (pipelineId: string) =>
      request<Run>(`/pipelines/${pipelineId}/runs`, { method: "POST" }),
    get: (id: string) => request<Run>(`/runs/${id}`),
    list: (pipelineId: string) =>
      request<Run[]>(`/pipelines/${pipelineId}/runs`),
  },
};
