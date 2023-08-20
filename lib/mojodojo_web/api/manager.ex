defmodule MojodojoWeb.API.Manager do
  use MojodojoWeb, :controller

  require Logger

  alias Mojodojo.Flux

  def flux_post(conn, %{"entity_id" => _entity_id, "service" => "turn_on"}) do
    res = Flux.turn_on()
    json(conn, res)
  end

  def flux_post(conn, %{"entity_id" => _entity_id, "service" => "turn_off"}) do
    res = Flux.turn_off()
    json(conn, res)
  end

  def flux_get(conn, _data) do
    Logger.debug(conn |> inspect(pretty: true))
    json(conn, %{is_active: Flux.is_active?()})
  end
end
