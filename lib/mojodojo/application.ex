defmodule Mojodojo.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [Mojodojo.Flux]

    opts = [strategy: :one_for_one, name: Mojodojo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
