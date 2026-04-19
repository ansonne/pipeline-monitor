ExUnit.start()

if Code.ensure_loaded?(PipelineMonitor.Repo) and
     Application.get_env(:pipeline_monitor, PipelineMonitor.Repo) != nil do
  Ecto.Adapters.SQL.Sandbox.mode(PipelineMonitor.Repo, :manual)
end

{:ok, _} = PipelineMonitor.Fakes.PipelineRepo.start_link()
{:ok, _} = PipelineMonitor.Fakes.RunRepo.start_link()
