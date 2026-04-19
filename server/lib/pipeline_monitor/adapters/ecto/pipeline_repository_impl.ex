defmodule PipelineMonitor.Adapters.Ecto.PipelineRepositoryImpl do
  @behaviour PipelineMonitor.Ports.PipelineRepository

  import Ecto.Query
  alias PipelineMonitor.Repo
  alias PipelineMonitor.Adapters.Ecto.PipelineSchema
  alias PipelineMonitor.Domain.{Pipeline, Step}

  @impl true
  def insert(pipeline) do
    attrs = %{
      id: pipeline.id,
      name: pipeline.name,
      inserted_at: pipeline.inserted_at,
      steps:
        Enum.map(pipeline.steps, fn s ->
          %{id: s.id, pipeline_id: s.pipeline_id, type: to_string(s.type), order: s.order, config: s.config}
        end)
    }

    changeset =
      %PipelineSchema{}
      |> Ecto.Changeset.cast(attrs, [:id, :name, :inserted_at])
      |> Ecto.Changeset.cast_assoc(:steps,
        with: fn schema, params ->
          Ecto.Changeset.cast(schema, params, [:id, :pipeline_id, :type, :order, :config])
        end
      )

    case Repo.insert(changeset) do
      {:ok, record} -> {:ok, to_domain(record)}
      {:error, cs} -> {:error, format_errors(cs)}
    end
  end

  @impl true
  def get(id) do
    case Repo.get(PipelineSchema, id) |> Repo.preload(:steps) do
      nil -> {:error, :not_found}
      record -> {:ok, to_domain(record)}
    end
  end

  @impl true
  def list do
    records = Repo.all(from p in PipelineSchema, order_by: [desc: p.inserted_at]) |> Repo.preload(:steps)
    {:ok, Enum.map(records, &to_domain/1)}
  end

  @impl true
  def delete(id) do
    case Repo.get(PipelineSchema, id) do
      nil -> {:error, :not_found}
      record ->
        Repo.delete(record)
        :ok
    end
  end

  defp to_domain(%PipelineSchema{} = r) do
    steps = Enum.map(r.steps, &step_to_domain/1)

    %Pipeline{
      id: r.id,
      name: r.name,
      steps: Enum.sort_by(steps, & &1.order),
      inserted_at: r.inserted_at
    }
  end

  defp step_to_domain(s) do
    %Step{
      id: s.id,
      pipeline_id: s.pipeline_id,
      type: String.to_existing_atom(s.type),
      order: s.order,
      config: s.config
    }
  end

  defp format_errors(cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, _} -> msg end) |> inspect()
  end
end
