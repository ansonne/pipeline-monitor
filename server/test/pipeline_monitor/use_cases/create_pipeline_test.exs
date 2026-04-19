defmodule PipelineMonitor.UseCases.CreatePipelineTest do
  use ExUnit.Case, async: false

  alias PipelineMonitor.UseCases.CreatePipeline
  alias PipelineMonitor.Fakes

  setup do
    Fakes.PipelineRepo.reset()
    :ok
  end

  test "creates pipeline with valid params" do
    params = %{
      name: "My Pipeline",
      steps: [%{type: :mock_ai, order: 1, config: %{}}]
    }

    assert {:ok, pipeline} = CreatePipeline.execute(params, Fakes.PipelineRepo)
    assert pipeline.name == "My Pipeline"
    assert length(pipeline.steps) == 1
    assert hd(pipeline.steps).type == :mock_ai
  end

  test "steps sorted by order" do
    params = %{
      name: "Pipeline",
      steps: [
        %{type: :notification, order: 3, config: %{}},
        %{type: :mock_ai, order: 1, config: %{}},
        %{type: :http, order: 2, config: %{url: "http://example.com"}}
      ]
    }

    assert {:ok, pipeline} = CreatePipeline.execute(params, Fakes.PipelineRepo)
    orders = Enum.map(pipeline.steps, & &1.order)
    assert orders == [1, 2, 3]
  end

  test "returns error when name is empty" do
    params = %{name: "", steps: [%{type: :mock_ai, order: 1, config: %{}}]}
    assert {:error, "name is required"} = CreatePipeline.execute(params, Fakes.PipelineRepo)
  end

  test "returns error when steps are empty" do
    params = %{name: "Pipeline", steps: []}
    assert {:error, "pipeline must have at least one step"} = CreatePipeline.execute(params, Fakes.PipelineRepo)
  end

  test "persists pipeline in repository" do
    params = %{name: "Persisted", steps: [%{type: :http, order: 1, config: %{}}]}
    {:ok, pipeline} = CreatePipeline.execute(params, Fakes.PipelineRepo)

    assert {:ok, found} = Fakes.PipelineRepo.get(pipeline.id)
    assert found.name == "Persisted"
  end
end
