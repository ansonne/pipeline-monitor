defmodule PipelineMonitor.Repo.Migrations.CreateRuns do
  use Ecto.Migration

  def change do
    create table(:runs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :pipeline_id, references(:pipelines, type: :uuid, on_delete: :delete_all), null: false
      add :status, :string, null: false, default: "pending"
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime
      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:runs, [:pipeline_id])
    create index(:runs, [:status])
  end
end
