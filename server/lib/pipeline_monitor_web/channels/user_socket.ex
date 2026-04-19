defmodule PipelineMonitorWeb.UserSocket do
  use Phoenix.Socket

  channel "run:*", PipelineMonitorWeb.RunChannel

  def connect(_params, socket, _connect_info), do: {:ok, socket}
  def id(_socket), do: nil
end
