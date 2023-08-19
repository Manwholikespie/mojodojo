defmodule Mojodojo.Flux do
  use GenServer

  require Logger

  alias Mojodojo.Lights
  alias Mojodojo.HomeAssistant, as: HA

  @update_interval 2_000

  def start_link(args) do
    Logger.info("Starting F.lux Genserver...")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Lights.turn_off("light.den_0")
    Lights.turn_on("light.den_1")

    state = %{active: true}

    Process.send_after(self(), :tick, @update_interval)
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    if state.active do
      tick(state)
    end

    Process.send_after(self(), :tick, @update_interval)
    {:noreply, state}
  end

  @impl true
  def handle_call(:toggle, _from, %{active: truthy} = state) do
    {:reply, !truthy, %{state | active: !truthy}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  defp tick(_state) do
    _new_kelvin = swag()
    # Logger.debug("Light temp: #{new_kelvin}")
  end

  def toggle() do
    GenServer.call(__MODULE__, :toggle)
  end

  def is_active?() do
    %{active: truthy} = GenServer.call(__MODULE__, :get_state)
    truthy
  end

  def sun() do
    ss = HA.states("sun.sun")
    now = DateTime.utc_now()

    attributes =
      for {x, y} <- ss["attributes"] do
        case x do
          "next_" <> _ ->
            {:ok, t, _} = DateTime.from_iso8601(y)
            {x, DateTime.diff(t, now, :second) / 60}

          _ ->
            {x, y}
        end
      end

    Map.new(attributes)
  end

  def swag() do
    sun()
    |> ticker()
  end

  # Past noon, not yet close to dawn. Set to default noonish temp of 6500K
  defp ticker(%{"rising" => false, "next_dusk" => nd}) when nd >= 180 do
    Lights.set_kelvin("light.den_1", 6500)
    Lights.set_brightness("light.den_1", 255)
    Lights.set_brightness("light.den_0", 255)
  end

  # Starting 3 hours from dusk (up until 1 hour), transition from 4500K to 3000K
  # Also dim our other light.
  defp ticker(%{"rising" => false, "next_dusk" => nd}) when nd > 60 and nd < 180 do
    p = (nd - 60) / 120
    k = 3000 + trunc(1500 * p)
    Lights.set_kelvin("light.den_1", k)
    Lights.set_brightness("light.den_0", trunc(255 * p))
    k
  end

  # The hour before dusk, transition from 3000K down to 2000K
  defp ticker(%{"rising" => false, "next_dusk" => nd}) when nd < 60 do
    p = nd / 60
    k = 2000 + trunc(1000 * p)
    Lights.set_kelvin("light.den_1", k)
    k
  end

  defp ticker(%{"rising" => false, "next_midnight" => nm}) when nm < 60 do
    # Kelvin 2000 = RGB [255, 136, 13]
    p = nm / 60
    Lights.set_rgb("light.den_1", 255, trunc(136 * p), trunc(13 * p))
    Lights.set_brightness("light.den_1", 200 + trunc(55 * p))
    2000
  end

  # The hour leading up until dawn. Transition from red to 2500k.
  defp ticker(%{"rising" => true, "next_dawn" => nd}) when nd < 60 do
    p = 1.0 - nd / 60
    Lights.set_rgb("light.den_1", 255, trunc(136 * p), trunc(13 * p))
    Lights.set_brightness("light.den_1", 200 + trunc(55 * p))
    2500
  end

  # From dawn until noon. Linear transition from 2500K to 6500K at noon.
  defp ticker(%{"rising" => true, "next_dawn" => nd, "next_noon" => nn}) when nd > nn do
    # linearly across 5 hours til noon
    p = 1.0 - min(5, nn / 60) / 5
    k = 2500 + trunc(4000 * p)
    Lights.set_kelvin("light.den_1", k)
    Lights.set_brightness("light.den_1", 255)
    Lights.set_brightness("light.den_0", trunc(255 * p))
    # Logger.debug("p = #{p}, k = #{k}")
  end

  defp ticker(%{"rising" => true} = sun) do
    Logger.error("This shouldn't be triggerable. Sun: #{sun |> inspect()}")
  end
end
