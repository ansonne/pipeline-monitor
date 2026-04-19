defmodule PipelineMonitor.Repo.Migrations.CreateSteps do
  use Ecto.Migration

  def change do
    create table(:steps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :pipeline_id, references(:pipelines, type: :uuid, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :order, :integer, null: false
      add :config, :map, null: false, default: %{}
    end

    create index(:steps, [:pipeline_id])
    create index(:steps, [:pipeline_id, :order])
  end
end
