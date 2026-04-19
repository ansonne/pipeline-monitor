defmodule PipelineMonitor.Adapters.Ecto.RunRepositoryImpl do
  @behaviour PipelineMonitor.Ports.RunRepository

  import Ecto.Query
  alias PipelineMonitor.Repo
  alias PipelineMonitor.Adapters.Ecto.{RunSchema, StepResultSchema}
  alias PipelineMonitor.Domain.{Run, StepResult}

  @impl true
  def insert(run) do
    attrs = %{
      id: run.id,
      pipeline_id: run.pipeline_id,
      status: to_string(run.status),
      started_at: run.started_at,
      finished_at: run.finished_at,
      inserted_at: DateTime.utc_now()
    }

    case Repo.insert(Ecto.Changeset.cast(%RunSchema{}, attrs, Map.keys(attrs))) do
      {:ok, record} -> {:ok, to_domain(record, [])}
      {:error, cs} -> {:error, inspect(cs.errors)}
    end
  end

  @impl true
  def get(id) do
    case Repo.get(RunSchema, id) do
      nil ->
        {:error, :not_found}

      record ->
        results =
          Repo.all(from sr in StepResultSchema, where: sr.run_id == ^id, order_by: [asc: sr.id])

        {:ok, to_domain(record, results)}
    end
  end

  @impl true
  def list(pipeline_id) do
    records = Repo.all(from r in RunSchema, where: r.pipeline_id == ^pipeline_id, order_by: [desc: r.inserted_at])
    {:ok, Enum.map(records, &to_domain(&1, []))}
  end

  @impl true
  def update_status(run_id, status) do
    updates = %{status: to_string(status)}

    updates =
      case status do
        :running -> Map.put(updates, :started_at, DateTime.utc_now() |> DateTime.truncate(:second))
        s when s in [:completed, :failed] -> Map.put(updates, :finished_at, DateTime.utc_now() |> DateTime.truncate(:second))
        _ -> updates
      end

    case Repo.get(RunSchema, run_id) do
      nil ->
        {:error, :not_found}

      record ->
        {:ok, updated} = record |> Ecto.Changeset.cast(updates, Map.keys(updates)) |> Repo.update()
        {:ok, to_domain(updated, [])}
    end
  end

  @impl true
  def insert_step_result(result) do
    attrs = %{
      id: result.id,
      run_id: result.run_id,
      step_id: result.step_id,
      status: to_string(result.status),
      input: result.input,
      output: result.output,
      error: result.error,
      duration_ms: result.duration_ms
    }

    case Repo.insert(Ecto.Changeset.cast(%StepResultSchema{}, attrs, Map.keys(attrs))) do
      {:ok, record} -> {:ok, result_to_domain(record)}
      {:error, cs} -> {:error, inspect(cs.errors)}
    end
  end

  @impl true
  def update_step_result(result) do
    attrs = %{
      status: to_string(result.status),
      output: result.output,
      error: result.error,
      duration_ms: result.duration_ms
    }

    case Repo.get(StepResultSchema, result.id) do
      nil ->
        {:error, :not_found}

      record ->
        {:ok, updated} = record |> Ecto.Changeset.cast(attrs, Map.keys(attrs)) |> Repo.update()
        {:ok, result_to_domain(updated)}
    end
  end

  defp to_domain(%RunSchema{} = r, step_results) do
    %Run{
      id: r.id,
      pipeline_id: r.pipeline_id,
      status: String.to_existing_atom(r.status),
      step_results: Enum.map(step_results, &result_to_domain/1),
      started_at: r.started_at,
      finished_at: r.finished_at
    }
  end

  defp result_to_domain(%StepResultSchema{} = r) do
    %StepResult{
      id: r.id,
      run_id: r.run_id,
      step_id: r.step_id,
      status: String.to_existing_atom(r.status),
      input: r.input,
      output: r.output,
      error: r.error,
      duration_ms: r.duration_ms
    }
  end
end
