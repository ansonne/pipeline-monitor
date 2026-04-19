defmodule PipelineMonitor.Ports.StepExecutor do
  alias PipelineMonitor.Domain.Step

  @type input :: map()
  @type output :: {:ok, map()} | {:error, String.t()}

  @callback execute(Step.t(), input()) :: output()
end
