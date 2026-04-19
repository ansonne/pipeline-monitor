defmodule PipelineMonitor.Repo do
  use Ecto.Repo,
    otp_app: :pipeline_monitor,
    adapter: Ecto.Adapters.Postgres
end
