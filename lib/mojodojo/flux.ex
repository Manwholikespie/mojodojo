defmodule Mojodojo.Flux do
  use GenServer

  require Logger

  @update_interval 2_000

  def start_link(args) do
    Logger.info("Starting F.lux Genserver...")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    # https://blog.appsignal.com/2019/05/14/elixir-alchemy-background-processing.html
    Process.send_after(self(), :tick, @update_interval)
    {:ok, nil}
  end

  @impl true
  def handle_info(:tick, state) do
    tick()
    Process.send_after(self(), :tick, @update_interval)
    Logger.debug("State: #{state |> inspect()}")

    {:noreply, :calendar.local_time()}
  end

  @spec tick :: :ok
  def tick() do
    Logger.debug("running tick()")
    :ok
  end
end
