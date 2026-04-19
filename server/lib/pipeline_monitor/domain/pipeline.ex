defmodule PipelineMonitor.Domain.Pipeline do
  alias PipelineMonitor.Domain.Step

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          steps: [Step.t()],
          inserted_at: DateTime.t()
        }

  @enforce_keys [:id, :name, :steps, :inserted_at]
  defstruct [:id, :name, :steps, :inserted_at]

  @spec new(String.t(), String.t(), [Step.t()]) :: t()
  def new(id, name, steps \\ []) do
    %__MODULE__{
      id: id,
      name: name,
      steps: Enum.sort_by(steps, & &1.order),
      inserted_at: DateTime.utc_now()
    }
  end
end
