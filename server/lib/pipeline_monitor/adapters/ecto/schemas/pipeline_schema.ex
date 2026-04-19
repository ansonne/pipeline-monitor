defmodule PipelineMonitor.Adapters.Ecto.PipelineSchema do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "pipelines" do
    field :name, :string
    has_many :steps, PipelineMonitor.Adapters.Ecto.StepSchema, foreign_key: :pipeline_id
    timestamps(type: :utc_datetime, updated_at: false)
  end
end
