defmodule PipelineMonitor.Ports.Notifier do
  alias PipelineMonitor.Domain.StepResult

  @callback broadcast_step_result(StepResult.t()) :: :ok
  @callback broadcast_run_status(String.t(), atom()) :: :ok
end
