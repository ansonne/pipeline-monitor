defmodule PipelineMonitor.UseCases.TriggerRunTest do
  use ExUnit.Case, async: false

  alias PipelineMonitor.UseCases.{CreatePipeline, TriggerRun}
  alias PipelineMonitor.Fakes

  setup do
    Fakes.PipelineRepo.reset()
    Fakes.RunRepo.reset()
    :ok
  end

  defp create_pipeline(steps \\ [%{type: :mock_ai, order: 1, config: %{}}]) do
    {:ok, pipeline} =
      CreatePipeline.execute(%{name: "Test Pipeline", steps: steps}, Fakes.PipelineRepo)
    pipeline
  end

  test "returns :pending run immediately" do
    pipeline = create_pipeline()
    assert {:ok, run} = TriggerRun.execute(pipeline.id, Fakes.PipelineRepo, Fakes.RunRepo, Fakes.OkExecutor, Fakes.SilentNotifier)
    assert run.status == :pending
  end

  test "returns error when pipeline not found" do
    assert {:error, :not_found} = TriggerRun.execute("nonexistent", Fakes.PipelineRepo, Fakes.RunRepo, Fakes.OkExecutor, Fakes.SilentNotifier)
  end

  test "run eventually completes when all steps succeed" do
    pipeline = create_pipeline()
    {:ok, run} = TriggerRun.execute(pipeline.id, Fakes.PipelineRepo, Fakes.RunRepo, Fakes.OkExecutor, Fakes.SilentNotifier)

    # Give the Task time to complete
    Process.sleep(100)

    {:ok, updated_run} = Fakes.RunRepo.get(run.id)
    assert updated_run.status == :completed
  end

  test "run fails when executor returns error" do
    pipeline = create_pipeline()
    {:ok, run} = TriggerRun.execute(pipeline.id, Fakes.PipelineRepo, Fakes.RunRepo, Fakes.FailExecutor, Fakes.SilentNotifier)

    Process.sleep(100)

    {:ok, updated_run} = Fakes.RunRepo.get(run.id)
    assert updated_run.status == :failed
  end

  test "step results stored after execution" do
    pipeline = create_pipeline([
      %{type: :mock_ai, order: 1, config: %{}},
      %{type: :notification, order: 2, config: %{}}
    ])
    {:ok, run} = TriggerRun.execute(pipeline.id, Fakes.PipelineRepo, Fakes.RunRepo, Fakes.OkExecutor, Fakes.SilentNotifier)

    Process.sleep(150)

    {:ok, updated_run} = Fakes.RunRepo.get(run.id)
    assert length(updated_run.step_results) == 2
    assert Enum.all?(updated_run.step_results, &(&1.status == :completed))
  end
end
