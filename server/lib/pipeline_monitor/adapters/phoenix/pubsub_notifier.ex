defmodule PipelineMonitor.Adapters.Phoenix.PubSubNotifier do
  @behaviour PipelineMonitor.Ports.Notifier

  alias Phoenix.PubSub
  alias PipelineMonitor.Domain.StepResult

  @impl true
  def broadcast_step_result(%StepResult{} = result) do
    PubSub.broadcast(PipelineMonitor.PubSub, "run:#{result.run_id}", {:step_result, result})
    :ok
  end

  @impl true
  def broadcast_run_status(run_id, status) do
    PubSub.broadcast(PipelineMonitor.PubSub, "run:#{run_id}", {:run_status, run_id, status})
    :ok
  end
end
