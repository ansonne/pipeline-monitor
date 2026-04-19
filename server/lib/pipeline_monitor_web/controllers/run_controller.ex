defmodule PipelineMonitorWeb.RunController do
  use PipelineMonitorWeb, :controller

  alias PipelineMonitor.UseCases.{TriggerRun, GetRunStatus}
  alias PipelineMonitor.Adapters.Ecto.{PipelineRepositoryImpl, RunRepositoryImpl}
  alias PipelineMonitor.Adapters.Executors.Dispatcher
  alias PipelineMonitor.Adapters.Phoenix.PubSubNotifier

  def create(conn, %{"pipeline_id" => pipeline_id}) do
    case TriggerRun.execute(pipeline_id, PipelineRepositoryImpl, RunRepositoryImpl, Dispatcher, PubSubNotifier) do
      {:ok, run} ->
        conn
        |> put_status(:created)
        |> json(%{data: serialize(run)})

      {:error, :not_found} ->
        send_resp(conn, 404, ~s({"error":"pipeline not found"}))

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def show(conn, %{"id" => id}) do
    case GetRunStatus.execute(id, RunRepositoryImpl) do
      {:ok, run} -> json(conn, %{data: serialize(run)})
      {:error, :not_found} -> send_resp(conn, 404, ~s({"error":"not found"}))
    end
  end

  def index(conn, %{"pipeline_id" => pipeline_id}) do
    {:ok, runs} = RunRepositoryImpl.list(pipeline_id)
    json(conn, %{data: Enum.map(runs, &serialize/1)})
  end

  defp serialize(r) do
    %{
      id: r.id,
      pipeline_id: r.pipeline_id,
      status: r.status,
      started_at: r.started_at,
      finished_at: r.finished_at,
      step_results: Enum.map(r.step_results, &serialize_result/1)
    }
  end

  defp serialize_result(sr) do
    %{
      id: sr.id,
      step_id: sr.step_id,
      status: sr.status,
      input: sr.input,
      output: sr.output,
      error: sr.error,
      duration_ms: sr.duration_ms
    }
  end
end
