defmodule MojodojoWeb.API.Manager do
  use MojodojoWeb, :controller

  require Logger

  alias Mojodojo.Lights
  alias Mojodojo.Flux

  def toggle_light(conn, %{"entity_id" => entity_id}) do
    res = Lights.turn_off(entity_id)
    json(conn, res)
  end

  def state(conn, _data) do
    Logger.debug(conn |> inspect(pretty: true))
    json(conn, %{is_active: Flux.is_active?()})
  end
end
