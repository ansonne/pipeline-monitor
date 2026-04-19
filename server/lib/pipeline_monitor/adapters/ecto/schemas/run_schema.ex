defmodule PipelineMonitor.Adapters.Ecto.RunSchema do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "runs" do
    field :status, :string
    field :started_at, :utc_datetime
    field :finished_at, :utc_datetime
    belongs_to :pipeline, PipelineMonitor.Adapters.Ecto.PipelineSchema
    has_many :step_results, PipelineMonitor.Adapters.Ecto.StepResultSchema, foreign_key: :run_id
    timestamps(type: :utc_datetime, updated_at: false)
  end
end
