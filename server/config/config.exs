# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pipeline_monitor,
  ecto_repos: [PipelineMonitor.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :pipeline_monitor, PipelineMonitorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PipelineMonitorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PipelineMonitor.PubSub,
  live_view: [signing_salt: "xBu35jyh"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
