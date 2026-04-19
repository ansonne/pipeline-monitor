defmodule PipelineMonitor.Adapters.Ecto.StepResultSchema do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "step_results" do
    field :status, :string
    field :input, :map
    field :output, :map
    field :error, :string
    field :duration_ms, :integer
    belongs_to :run, PipelineMonitor.Adapters.Ecto.RunSchema
    belongs_to :step, PipelineMonitor.Adapters.Ecto.StepSchema
  end
end
