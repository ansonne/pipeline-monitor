defmodule PipelineMonitor.Adapters.Executors.Dispatcher do
  @behaviour PipelineMonitor.Ports.StepExecutor

  alias PipelineMonitor.Adapters.Executors.{HttpStep, MockAiStep, TransformStep, NotificationStep}

  @impl true
  def execute(%{type: :http} = step, input), do: HttpStep.execute(step, input)
  def execute(%{type: :mock_ai} = step, input), do: MockAiStep.execute(step, input)
  def execute(%{type: :transform} = step, input), do: TransformStep.execute(step, input)
  def execute(%{type: :notification} = step, input), do: NotificationStep.execute(step, input)
end
