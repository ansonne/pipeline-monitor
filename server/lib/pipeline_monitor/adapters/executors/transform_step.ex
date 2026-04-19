defmodule PipelineMonitor.Adapters.Executors.TransformStep do
  @behaviour PipelineMonitor.Ports.StepExecutor

  @impl true
  def execute(%{config: config}, input) do
    mappings = Map.get(config, "mappings", %{})
    drop_keys = Map.get(config, "drop", [])
    merge = Map.get(config, "merge", %{})

    output =
      input
      |> apply_mappings(mappings)
      |> Map.drop(drop_keys)
      |> Map.merge(merge)

    {:ok, output}
  end

  defp apply_mappings(input, mappings) do
    Enum.reduce(mappings, input, fn {from, to}, acc ->
      case Map.fetch(acc, from) do
        {:ok, val} -> acc |> Map.delete(from) |> Map.put(to, val)
        :error -> acc
      end
    end)
  end
end
