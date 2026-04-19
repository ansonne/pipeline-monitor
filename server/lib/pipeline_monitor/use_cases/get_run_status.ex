defmodule PipelineMonitor.UseCases.GetRunStatus do
  alias PipelineMonitor.Domain.Run
  alias PipelineMonitor.Ports.RunRepository

  @spec execute(String.t(), module()) :: {:ok, Run.t()} | {:error, :not_found}
  def execute(run_id, repo \\ RunRepository) do
    repo.get(run_id)
  end
end
