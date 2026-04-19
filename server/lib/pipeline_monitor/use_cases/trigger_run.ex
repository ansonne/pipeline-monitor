defmodule PipelineMonitor.UseCases.TriggerRun do
  alias PipelineMonitor.Domain.{Run, StepResult}
  alias PipelineMonitor.Ports.{PipelineRepository, RunRepository, StepExecutor, Notifier}

  @spec execute(String.t(), module(), module(), module(), module()) ::
          {:ok, Run.t()} | {:error, :not_found} | {:error, String.t()}
  def execute(
        pipeline_id,
        pipeline_repo \\ PipelineRepository,
        run_repo \\ RunRepository,
        executor \\ StepExecutor,
        notifier \\ Notifier
      ) do
    with {:ok, pipeline} <- pipeline_repo.get(pipeline_id) do
      run = Run.new(generate_id(), pipeline_id)
      {:ok, run} = run_repo.insert(run)

      Task.Supervisor.start_child(PipelineMonitor.TaskSupervisor, fn ->
        execute_run(run, pipeline.steps, run_repo, executor, notifier)
      end)

      {:ok, run}
    end
  end

  defp execute_run(run, steps, run_repo, executor, notifier) do
    {:ok, run} = run_repo.update_status(run.id, :running)
    notifier.broadcast_run_status(run.id, :running)

    result =
      Enum.reduce_while(steps, {:ok, %{}}, fn step, {:ok, input} ->
        step_result = StepResult.new(generate_id(), run.id, step.id, input)
        {:ok, step_result} = run_repo.insert_step_result(%{step_result | status: :running})
        notifier.broadcast_step_result(step_result)

        start = System.monotonic_time(:millisecond)

        case executor.execute(step, input) do
          {:ok, output} ->
            duration = System.monotonic_time(:millisecond) - start
            updated = %{step_result | status: :completed, output: output, duration_ms: duration}
            {:ok, updated} = run_repo.update_step_result(updated)
            notifier.broadcast_step_result(updated)
            {:cont, {:ok, output}}

          {:error, reason} ->
            duration = System.monotonic_time(:millisecond) - start
            updated = %{step_result | status: :failed, error: reason, duration_ms: duration}
            {:ok, updated} = run_repo.update_step_result(updated)
            notifier.broadcast_step_result(updated)
            {:halt, {:error, reason}}
        end
      end)

    final_status = if match?({:ok, _}, result), do: :completed, else: :failed
    {:ok, _run} = run_repo.update_status(run.id, final_status)
    notifier.broadcast_run_status(run.id, final_status)
  end

  defp generate_id, do: Ecto.UUID.generate()
end
