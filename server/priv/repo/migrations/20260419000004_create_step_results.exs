defmodule PipelineMonitor.Repo.Migrations.CreateStepResults do
  use Ecto.Migration

  def change do
    create table(:step_results, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :run_id, references(:runs, type: :uuid, on_delete: :delete_all), null: false
      add :step_id, references(:steps, type: :uuid, on_delete: :delete_all), null: false
      add :status, :string, null: false, default: "pending"
      add :input, :map, null: false, default: %{}
      add :output, :map
      add :error, :text
      add :duration_ms, :integer
    end

    create index(:step_results, [:run_id])
  end
end
