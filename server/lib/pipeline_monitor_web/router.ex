defmodule PipelineMonitorWeb.Router do
  use PipelineMonitorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  scope "/api", PipelineMonitorWeb do
    pipe_through :api

    resources "/pipelines", PipelineController, only: [:index, :show, :create, :delete] do
      resources "/runs", RunController, only: [:index, :create]
    end

    get "/runs/:id", RunController, :show
  end
end
