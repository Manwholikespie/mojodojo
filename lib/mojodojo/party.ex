defmodule Mojodojo.Party do
  use GenServer

  require Logger

  alias Mojodojo.Lights

  @update_interval 50

  def start_link(args) do
    Logger.info("Starting Party Lights Genserver...")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    state = %{active: false, counter: 0}

    Process.send_after(self(), :tick, @update_interval)
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    newstate = tick(state)

    Process.send_after(self(), :tick, @update_interval)
    {:noreply, newstate}
  end

  @impl true
  def handle_call(:toggle, _from, %{active: truthy} = state) do
    {:reply, !truthy, %{state | active: !truthy}}
  end

  @impl true
  def handle_call(:turn_on, _from, state) do
    {:reply, true, %{state | active: true}}
  end

  @impl true
  def handle_call(:turn_off, _from, state) do
    {:reply, false, %{state | active: false}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @spec tick(map()) :: map()
  defp tick(%{active: true, counter: i} = state) do
    r = 255 - abs(i - 255)
    g = abs(i - 255)

    Lights.set_rgb("light.den_1", r, g, 255)
    Lights.set_brightness("light.den_0", 0)
    %{state | counter: rem(i + 8, 510)}
  end

  defp tick(%{active: false} = state), do: state

  def toggle() do
    GenServer.call(__MODULE__, :toggle)
  end

  def turn_on() do
    GenServer.call(__MODULE__, :turn_on)
  end

  def turn_off() do
    GenServer.call(__MODULE__, :turn_off)
  end

  def is_active?() do
    %{active: truthy} = GenServer.call(__MODULE__, :get_state)
    truthy
  end
end
