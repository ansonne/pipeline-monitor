defmodule PipelineMonitor.Adapters.Ecto.StepSchema do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "steps" do
    field :type, :string
    field :order, :integer
    field :config, :map
    belongs_to :pipeline, PipelineMonitor.Adapters.Ecto.PipelineSchema
  end
end
