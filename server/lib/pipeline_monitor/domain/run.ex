defmodule PipelineMonitor.Domain.Run do
  alias PipelineMonitor.Domain.StepResult

  @type status :: :pending | :running | :completed | :failed

  @type t :: %__MODULE__{
          id: String.t(),
          pipeline_id: String.t(),
          status: status(),
          step_results: [StepResult.t()],
          started_at: DateTime.t() | nil,
          finished_at: DateTime.t() | nil
        }

  @enforce_keys [:id, :pipeline_id, :status, :step_results]
  defstruct [:id, :pipeline_id, :status, :step_results, :started_at, :finished_at]

  @spec new(String.t(), String.t()) :: t()
  def new(id, pipeline_id) do
    %__MODULE__{
      id: id,
      pipeline_id: pipeline_id,
      status: :pending,
      step_results: [],
      started_at: nil,
      finished_at: nil
    }
  end
end
