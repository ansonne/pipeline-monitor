defmodule PipelineMonitor.Adapters.Executors.MockAiStep do
  @behaviour PipelineMonitor.Ports.StepExecutor

  @responses [
    "Summary: The data indicates a positive trend with notable outliers.",
    "Classification: category_a (confidence: 0.87)",
    "Analysis complete. Key findings: increased engagement, reduced churn.",
    "Transformation applied. Output normalized and enriched."
  ]

  @impl true
  def execute(_step, input) do
    Process.sleep(Enum.random(200..600))
    {:ok, Map.merge(input, %{"ai_output" => Enum.random(@responses), "model" => "mock-v1"})}
  end
end
