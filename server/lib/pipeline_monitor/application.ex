defmodule PipelineMonitor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PipelineMonitorWeb.Telemetry,
      PipelineMonitor.Repo,
      {DNSCluster, query: Application.get_env(:pipeline_monitor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PipelineMonitor.PubSub},
      {Task.Supervisor, name: PipelineMonitor.TaskSupervisor},
      PipelineMonitorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PipelineMonitor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PipelineMonitorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
