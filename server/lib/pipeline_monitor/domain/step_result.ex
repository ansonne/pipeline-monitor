defmodule PipelineMonitor.Domain.StepResult do
  @type status :: :pending | :running | :completed | :failed

  @type t :: %__MODULE__{
          id: String.t(),
          run_id: String.t(),
          step_id: String.t(),
          status: status(),
          input: map(),
          output: map() | nil,
          error: String.t() | nil,
          duration_ms: non_neg_integer() | nil
        }

  @enforce_keys [:id, :run_id, :step_id, :status, :input]
  defstruct [:id, :run_id, :step_id, :status, :input, :output, :error, :duration_ms]

  @spec new(String.t(), String.t(), String.t(), map()) :: t()
  def new(id, run_id, step_id, input) do
    %__MODULE__{
      id: id,
      run_id: run_id,
      step_id: step_id,
      status: :pending,
      input: input,
      output: nil,
      error: nil,
      duration_ms: nil
    }
  end
end
