defmodule PipelineMonitor.Ports.PipelineRepository do
  alias PipelineMonitor.Domain.Pipeline

  @type error :: {:error, String.t()}

  @callback insert(Pipeline.t()) :: {:ok, Pipeline.t()} | error()
  @callback get(String.t()) :: {:ok, Pipeline.t()} | {:error, :not_found}
  @callback list() :: {:ok, [Pipeline.t()]}
  @callback delete(String.t()) :: :ok | {:error, :not_found}
end
