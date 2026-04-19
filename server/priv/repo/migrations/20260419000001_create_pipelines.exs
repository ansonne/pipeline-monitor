defmodule PipelineMonitor.Repo.Migrations.CreatePipelines do
  use Ecto.Migration

  def change do
    create table(:pipelines, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end
