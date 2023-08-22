defmodule MojodojoWeb.API.Manager do
  use MojodojoWeb, :controller

  require Logger

  alias Mojodojo.{Flux, Party}

  def flux_post(conn, %{"service" => "turn_on"}) do
    res = Flux.turn_on()
    json(conn, res)
  end

  def flux_post(conn, %{"service" => "turn_off"}) do
    res = Flux.turn_off()
    json(conn, res)
  end

  def flux_get(conn, _data) do
    Logger.debug(conn |> inspect(pretty: true))
    json(conn, %{is_active: Flux.is_active?()})
  end

  def party_post(conn, %{"service" => "turn_on"}) do
    res = Party.turn_on()
    json(conn, res)
  end

  def party_post(conn, %{"service" => "turn_off"}) do
    res = Party.turn_off()
    json(conn, res)
  end

  def party_get(conn, _data) do
    Logger.debug(conn |> inspect(pretty: true))
    json(conn, %{is_active: Party.is_active?()})
  end
end
