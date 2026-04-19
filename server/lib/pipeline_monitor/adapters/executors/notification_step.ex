defmodule PipelineMonitor.Adapters.Executors.NotificationStep do
  @behaviour PipelineMonitor.Ports.StepExecutor

  require Logger

  @impl true
  def execute(%{config: config}, input) do
    message = Map.get(config, "message", "Pipeline step completed")
    Logger.info("[Notification] #{message} | data=#{inspect(input)}")
    {:ok, Map.put(input, "notified", true)}
  end
end
