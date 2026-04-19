defmodule PipelineMonitorWeb.PipelineController do
  use PipelineMonitorWeb, :controller

  alias PipelineMonitor.UseCases.CreatePipeline
  alias PipelineMonitor.Adapters.Ecto.PipelineRepositoryImpl, as: PipelineRepo

  def index(conn, _params) do
    {:ok, pipelines} = PipelineRepo.list()
    json(conn, %{data: Enum.map(pipelines, &serialize/1)})
  end

  def show(conn, %{"id" => id}) do
    case PipelineRepo.get(id) do
      {:ok, pipeline} -> json(conn, %{data: serialize(pipeline)})
      {:error, :not_found} -> send_resp(conn, 404, ~s({"error":"not found"}))
    end
  end

  def create(conn, params) do
    steps =
      (params["steps"] || [])
      |> Enum.map(fn s ->
        %{
          type: parse_step_type(s["type"]),
          order: s["order"],
          config: s["config"] || %{}
        }
      end)

    case CreatePipeline.execute(%{name: params["name"], steps: steps}, PipelineRepo) do
      {:ok, pipeline} ->
        conn
        |> put_status(:created)
        |> json(%{data: serialize(pipeline)})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    case PipelineRepo.delete(id) do
      :ok -> send_resp(conn, 204, "")
      {:error, :not_found} -> send_resp(conn, 404, ~s({"error":"not found"}))
    end
  end

  @valid_step_types ~w(http mock_ai transform notification)

  defp parse_step_type(t) when t in @valid_step_types, do: String.to_atom(t)
  defp parse_step_type(t), do: raise(ArgumentError, "invalid step type: #{t}")

  defp serialize(p) do
    %{
      id: p.id,
      name: p.name,
      inserted_at: p.inserted_at,
      steps: Enum.map(p.steps, &serialize_step/1)
    }
  end

  defp serialize_step(s) do
    %{id: s.id, type: s.type, order: s.order, config: s.config}
  end
end
