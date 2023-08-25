defmodule Mojodojo.Flux do
  use GenServer

  require Logger

  alias Mojodojo.Lights
  alias Mojodojo.HomeAssistant, as: HA

  @update_interval 2_000
  @minutes_per_day 1440

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

  defp tick(_state) do
    new_kelvin = swag()
    Logger.debug("Light temp: #{new_kelvin}")
  end

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

  def sun() do
    HA.states("sun.sun")
    |> sun_helper()
    |> sun_helper_prev()
  end

  defp sun_helper(%{"attributes" => _} = ss) when is_map(ss) do
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

  # If HA is down, we get an empty map. Just pass it along and don't process.
  # There is also a possibility we get %{"message" => "Entity not found."} on
  #   startup. Ignore.
  defp sun_helper(_), do: %{}

  defp sun_helper_prev(attrs) do
    attrs
    |> Map.filter(fn {k,_v} -> String.starts_with?(k, "next_") end)
    |> Enum.map(fn {"next_" <> k, v} -> {"prev_" <> k, @minutes_per_day - v} end)
    |> Map.new()
    |> Map.merge(attrs)
  end

  def swag() do
    sun()
    |> ticker()
  end

  defp ticker(%{} = sun_val) when map_size(sun_val) == 0 do
    Logger.debug("Not getting sun value")
    -1
  end

  # Default post-noon setting. Linearly down from 6500K to 3000K across 6 hours.
  defp ticker(%{"rising" => false, "next_dusk" => nd, "next_midnight" => nm})
       when nd > 120 and nd < nm do
    p = min(6, nd / 60) / 6
    k = 3000 + trunc(3500 * p)

    Lights.set_kelvin("light.den_1", k)
    Lights.set_brightness("light.den_1", 255)
    Lights.set_brightness("light.den_0", trunc(255 * p))
    k
  end

  # The 2 hours before dusk, transition from 3000K down to 2000K
  defp ticker(%{"rising" => false, "next_dusk" => nd}) when nd < 120 do
    p = nd / 120
    k = 2000 + trunc(1000 * p)
    Lights.set_kelvin("light.den_1", k)
    Lights.set_brightness("light.den_1", 100 + trunc(155 * p))
    Lights.set_brightness("light.den_0", 0)
    k
  end

  # Default post-dusk setting
  defp ticker(%{"rising" => false, "next_midnight" => nm}) when nm >= 180 do
    Lights.set_kelvin("light.den_1", 2000)
    Lights.set_brightness("light.den_1", 100)
    Lights.set_brightness("light.den_0", 0)
    2000
  end

  # The 3 hours before midnight, transition from 2000K to red.
  defp ticker(%{"rising" => false, "next_midnight" => nm}) when nm < 180 do
    # Kelvin 2000 = RGB [255, 178, 67]
    p = nm / 180
    Lights.set_rgb("light.den_1", 255, trunc(178 * p), trunc(67 * p))
    Lights.set_brightness("light.den_1", 100)
    Lights.set_brightness("light.den_0", 0)
    2000
  end

  # ===== RISING true =====

  # Default early morning / before dawn
  defp ticker(%{"rising" => true, "next_rising" => nr, "next_noon" => nn})
       when nr > 60 and nr < nn do
    Lights.set_rgb("light.den_1", 255, 0, 0)
    Lights.set_brightness("light.den_1", 100)
    Lights.set_brightness("light.den_0", 0)
    2000
  end

  # The hour leading up until "dawn". Transition from red to 2000.
  defp ticker(%{"rising" => true, "next_rising" => nr}) when nr <= 60 do
    p = 1.0 - nr / 60
    Lights.set_rgb("light.den_1", 255, trunc(178 * p), trunc(67 * p))
    Lights.set_brightness("light.den_1", 100 + trunc(155 * p))
    Lights.set_brightness("light.den_0", 0)
    2000
  end

  # From dawn-ish until noon. Linear transition from 2000K to 6500K at noon.
  defp ticker(%{"rising" => true, "next_rising" => nr, "next_noon" => nn}) when nr > nn do
    p = 1.0 - min(5, nn / 60) / 5
    k = 2000 + trunc(4500 * p)
    Lights.set_kelvin("light.den_1", k)
    Lights.set_brightness("light.den_1", 255)
    Lights.set_brightness("light.den_0", trunc(255 * p))
    k
  end

  defp ticker(%{"rising" => true} = sun) do
    Logger.error("This shouldn't be triggerable. Sun: #{sun |> inspect()}")
    -1
  end
end
