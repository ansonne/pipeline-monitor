defmodule PipelineMonitor.Domain.Step do
  @type step_type :: :http | :mock_ai | :transform | :notification

  @type t :: %__MODULE__{
          id: String.t(),
          pipeline_id: String.t(),
          type: step_type(),
          order: pos_integer(),
          config: map()
        }

  @enforce_keys [:id, :pipeline_id, :type, :order, :config]
  defstruct [:id, :pipeline_id, :type, :order, :config]

  @spec new(String.t(), String.t(), step_type(), pos_integer(), map()) :: t()
  def new(id, pipeline_id, type, order, config)
      when type in [:http, :mock_ai, :transform, :notification] do
    %__MODULE__{
      id: id,
      pipeline_id: pipeline_id,
      type: type,
      order: order,
      config: config
    }
  end
end
