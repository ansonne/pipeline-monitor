defmodule PipelineMonitor.Fakes do
  @moduledoc """
  In-memory fakes implementing port behaviours for tests.
  Each fake uses an Agent to hold state so tests remain isolated.
  """

  defmodule PipelineRepo do
    @behaviour PipelineMonitor.Ports.PipelineRepository

    def start_link, do: Agent.start_link(fn -> %{} end, name: __MODULE__)
    def reset, do: Agent.update(__MODULE__, fn _ -> %{} end)

    @impl true
    def insert(pipeline) do
      Agent.update(__MODULE__, &Map.put(&1, pipeline.id, pipeline))
      {:ok, pipeline}
    end

    @impl true
    def get(id) do
      case Agent.get(__MODULE__, &Map.get(&1, id)) do
        nil -> {:error, :not_found}
        p -> {:ok, p}
      end
    end

    @impl true
    def list, do: {:ok, Agent.get(__MODULE__, &Map.values(&1))}

    @impl true
    def delete(id) do
      if Agent.get(__MODULE__, &Map.has_key?(&1, id)) do
        Agent.update(__MODULE__, &Map.delete(&1, id))
        :ok
      else
        {:error, :not_found}
      end
    end
  end

  defmodule RunRepo do
    @behaviour PipelineMonitor.Ports.RunRepository

    def start_link, do: Agent.start_link(fn -> %{runs: %{}, results: %{}} end, name: __MODULE__)
    def reset, do: Agent.update(__MODULE__, fn _ -> %{runs: %{}, results: %{}} end)

    @impl true
    def insert(run) do
      Agent.update(__MODULE__, &put_in(&1, [:runs, run.id], run))
      {:ok, run}
    end

    @impl true
    def get(id) do
      case Agent.get(__MODULE__, &get_in(&1, [:runs, id])) do
        nil -> {:error, :not_found}
        run ->
          results = Agent.get(__MODULE__, &Map.values(&1.results))
          run_results = Enum.filter(results, &(&1.run_id == id))
          {:ok, %{run | step_results: run_results}}
      end
    end

    @impl true
    def list(pipeline_id) do
      runs =
        Agent.get(__MODULE__, &Map.values(&1.runs))
        |> Enum.filter(&(&1.pipeline_id == pipeline_id))
      {:ok, runs}
    end

    @impl true
    def update_status(run_id, status) do
      Agent.update(__MODULE__, fn state ->
        update_in(state, [:runs, run_id], fn
          nil -> nil
          run -> %{run | status: status}
        end)
      end)

      case Agent.get(__MODULE__, &get_in(&1, [:runs, run_id])) do
        nil -> {:error, :not_found}
        run -> {:ok, run}
      end
    end

    @impl true
    def insert_step_result(result) do
      Agent.update(__MODULE__, &put_in(&1, [:results, result.id], result))
      {:ok, result}
    end

    @impl true
    def update_step_result(result) do
      Agent.update(__MODULE__, &put_in(&1, [:results, result.id], result))
      {:ok, result}
    end
  end

  defmodule OkExecutor do
    @behaviour PipelineMonitor.Ports.StepExecutor

    @impl true
    def execute(_step, input), do: {:ok, Map.put(input, "executed", true)}
  end

  defmodule FailExecutor do
    @behaviour PipelineMonitor.Ports.StepExecutor

    @impl true
    def execute(_step, _input), do: {:error, "step failed"}
  end

  defmodule SilentNotifier do
    @behaviour PipelineMonitor.Ports.Notifier

    @impl true
    def broadcast_step_result(_result), do: :ok

    @impl true
    def broadcast_run_status(_run_id, _status), do: :ok
  end
end
