defmodule LiveChartsDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveChartsDemoWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:live_charts_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveChartsDemo.PubSub},
      # Start a worker by calling: LiveChartsDemo.Worker.start_link(arg)
      # {LiveChartsDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveChartsDemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveChartsDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveChartsDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
