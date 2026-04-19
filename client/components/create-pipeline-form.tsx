"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import type { StepType } from "@/lib/types";
import { api } from "@/lib/api";
import { Plus, Trash2 } from "lucide-react";

const STEP_TYPES: StepType[] = ["http", "mock_ai", "transform", "notification"];

interface StepInput {
  type: StepType;
  config: Record<string, string>;
}

export function CreatePipelineForm() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [steps, setSteps] = useState<StepInput[]>([{ type: "mock_ai", config: {} }]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  function addStep() {
    setSteps((s) => [...s, { type: "mock_ai", config: {} }]);
  }

  function removeStep(i: number) {
    setSteps((s) => s.filter((_, idx) => idx !== i));
  }

  function updateStep(i: number, patch: Partial<StepInput>) {
    setSteps((s) => s.map((step, idx) => (idx === i ? { ...step, ...patch } : step)));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const pipeline = await api.pipelines.create({
        name,
        steps: steps.map((s, i) => ({ type: s.type, order: i + 1, config: s.config })),
      });
      router.push(`/pipelines/${pipeline.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create pipeline");
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-neutral-300 mb-1.5">Pipeline name</label>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="My pipeline"
          required
          className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-md px-3 py-2 text-sm text-[#f5f5f5] focus:outline-none focus:border-violet-500"
        />
      </div>

      <div>
        <div className="flex items-center justify-between mb-3">
          <label className="block text-sm font-medium text-neutral-300">Steps</label>
          <button
            type="button"
            onClick={addStep}
            className="flex items-center gap-1 text-xs text-violet-400 hover:text-violet-300"
          >
            <Plus className="w-3.5 h-3.5" /> Add step
          </button>
        </div>

        <div className="space-y-2">
          {steps.map((step, i) => (
            <div key={i} className="flex gap-2 items-start border border-[#2a2a2a] rounded-lg p-3 bg-[#1a1a1a]">
              <span className="text-xs text-neutral-500 pt-2 w-5 text-center">{i + 1}</span>
              <div className="flex-1 space-y-2">
                <select
                  value={step.type}
                  onChange={(e) => updateStep(i, { type: e.target.value as StepType, config: {} })}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded px-2 py-1.5 text-sm text-[#f5f5f5] focus:outline-none focus:border-violet-500"
                >
                  {STEP_TYPES.map((t) => (
                    <option key={t} value={t}>{t}</option>
                  ))}
                </select>

                {step.type === "http" && (
                  <input
                    type="url"
                    placeholder="https://api.example.com/data"
                    value={(step.config.url as string) ?? ""}
                    onChange={(e) => updateStep(i, { config: { ...step.config, url: e.target.value } })}
                    className="w-full bg-[#111] border border-[#2a2a2a] rounded px-2 py-1.5 text-sm text-[#f5f5f5] focus:outline-none focus:border-violet-500"
                  />
                )}

                {step.type === "notification" && (
                  <input
                    type="text"
                    placeholder="Notification message"
                    value={(step.config.message as string) ?? ""}
                    onChange={(e) => updateStep(i, { config: { ...step.config, message: e.target.value } })}
                    className="w-full bg-[#111] border border-[#2a2a2a] rounded px-2 py-1.5 text-sm text-[#f5f5f5] focus:outline-none focus:border-violet-500"
                  />
                )}
              </div>
              <button
                type="button"
                onClick={() => removeStep(i)}
                disabled={steps.length === 1}
                className="p-1.5 text-neutral-500 hover:text-red-400 disabled:opacity-30"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          ))}
        </div>
      </div>

      {error && <p className="text-sm text-red-400">{error}</p>}

      <button
        type="submit"
        disabled={loading}
        className="w-full bg-violet-600 hover:bg-violet-500 disabled:opacity-50 text-white py-2 rounded-md text-sm font-medium transition-colors"
      >
        {loading ? "Creating…" : "Create Pipeline"}
      </button>
    </form>
  );
}
