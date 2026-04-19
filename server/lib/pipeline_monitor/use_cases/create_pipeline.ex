defmodule PipelineMonitor.UseCases.CreatePipeline do
  alias PipelineMonitor.Domain.{Pipeline, Step}
  alias PipelineMonitor.Ports.PipelineRepository

  @type step_params :: %{
          type: Step.step_type(),
          order: pos_integer(),
          config: map()
        }

  @type params :: %{
          name: String.t(),
          steps: [step_params()]
        }

  @spec execute(params(), module()) :: {:ok, Pipeline.t()} | {:error, String.t()}
  def execute(%{name: name, steps: steps_params}, repo \\ PipelineRepository) do
    with :ok <- validate_name(name),
         :ok <- validate_steps(steps_params) do
      pipeline_id = generate_id()

      steps =
        Enum.map(steps_params, fn %{type: type, order: order, config: config} ->
          Step.new(generate_id(), pipeline_id, type, order, config)
        end)

      pipeline = Pipeline.new(pipeline_id, name, steps)
      repo.insert(pipeline)
    end
  end

  defp validate_name(name) when is_binary(name) and byte_size(name) > 0, do: :ok
  defp validate_name(_), do: {:error, "name is required"}

  defp validate_steps([_ | _]), do: :ok
  defp validate_steps(_), do: {:error, "pipeline must have at least one step"}

  defp generate_id, do: Ecto.UUID.generate()
end
