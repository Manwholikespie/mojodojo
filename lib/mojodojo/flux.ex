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

    state = %{counter: 0}

    Process.send_after(self(), :tick, @update_interval)
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    tick(state)
    Process.send_after(self(), :tick, @update_interval)
    {:noreply, nil}
  end

  defp tick(_state) do
    _new_kelvin = swag()
    # Logger.debug("Light temp: #{new_kelvin}")
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

  defp ticker(%{"rising" => false, "next_dusk" => nd}) when nd > 60 and nd < 180 do
    p = (nd - 60) / 120
    k = 3000 + trunc(1500 * p)
    Lights.set_kelvin("light.den_1", k)
    k
  end

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

  defp ticker(%{"rising" => true}) do
    Lights.set_rgb("light.den_1", 255, 0, 0)
    Lights.set_brightness("light.den_1", 200)
  end
end
