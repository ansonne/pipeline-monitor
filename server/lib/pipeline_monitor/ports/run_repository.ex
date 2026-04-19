defmodule PipelineMonitor.Ports.RunRepository do
  alias PipelineMonitor.Domain.{Run, StepResult}

  @type error :: {:error, String.t()}

  @callback insert(Run.t()) :: {:ok, Run.t()} | error()
  @callback get(String.t()) :: {:ok, Run.t()} | {:error, :not_found}
  @callback list(String.t()) :: {:ok, [Run.t()]}
  @callback update_status(String.t(), Run.status()) :: {:ok, Run.t()} | error()
  @callback insert_step_result(StepResult.t()) :: {:ok, StepResult.t()} | error()
  @callback update_step_result(StepResult.t()) :: {:ok, StepResult.t()} | error()
end
