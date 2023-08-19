defmodule Mojodojo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MojodojoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mojodojo.PubSub},
      # Start the Endpoint (http/https)
      MojodojoWeb.Endpoint,
      # Start a worker by calling: Mojodojo.Worker.start_link(arg)
      # {Mojodojo.Worker, arg}
      Mojodojo.Flux
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mojodojo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MojodojoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
