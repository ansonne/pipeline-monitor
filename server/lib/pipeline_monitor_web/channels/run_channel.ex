defmodule PipelineMonitorWeb.RunChannel do
  use Phoenix.Channel

  alias Phoenix.PubSub

  def join("run:" <> run_id, _params, socket) do
    PubSub.subscribe(PipelineMonitor.PubSub, "run:#{run_id}")
    {:ok, assign(socket, :run_id, run_id)}
  end

  def handle_info({:step_result, result}, socket) do
    push(socket, "step_result", %{
      id: result.id,
      step_id: result.step_id,
      status: result.status,
      output: result.output,
      error: result.error,
      duration_ms: result.duration_ms
    })

    {:noreply, socket}
  end

  def handle_info({:run_status, run_id, status}, socket) do
    push(socket, "run_status", %{run_id: run_id, status: status})
    {:noreply, socket}
  end
end
