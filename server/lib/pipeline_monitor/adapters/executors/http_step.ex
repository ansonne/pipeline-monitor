defmodule PipelineMonitor.Adapters.Executors.HttpStep do
  @behaviour PipelineMonitor.Ports.StepExecutor

  @impl true
  def execute(%{config: %{"url" => url} = config}, input) do
    method = Map.get(config, "method", "GET") |> String.downcase() |> String.to_existing_atom()
    headers = Map.get(config, "headers", %{})

    opts = [headers: headers, receive_timeout: 10_000]
    opts = if method == :post, do: Keyword.put(opts, :json, input), else: opts

    case apply(Req, method, [url, opts]) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, Map.put(input, "http_response", body)}

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end

  def execute(_step, _input), do: {:error, "http step requires url in config"}
end
