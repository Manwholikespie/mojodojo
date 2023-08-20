defmodule Mojodojo.HomeAssistant do
  require Logger

  @ha_key Application.compile_env(:mojodojo, :ha_key)
  @ha_endpoint Application.compile_env(:mojodojo, :ha_endpoint)

  defp headers_kw(), do: [{"Authorization", "Bearer #{@ha_key}"}]

  def services() do
    e = Path.join([@ha_endpoint, "/api/services"])
    make_request(e, :get)
  end

  @spec states() :: map()
  def states() do
    e = Path.join([@ha_endpoint, "/api/states"])
    make_request(e, :get)
  end

  @spec states(bitstring) :: map()
  def states(entity_id) do
    e = Path.join([@ha_endpoint, "/api/states", entity_id])
    make_request(e, :get)
  end

  def set_domain_service(domain, service, service_data) do
    e = Path.join([@ha_endpoint, "/api/services", domain, service])
    make_request(e, :post, service_data)
  end

  @spec make_request(bitstring(), :get | :post | :put) :: map()
  defp make_request(endpoint, method, payload \\ nil) do
    body =
      case payload do
        nil -> ""
        _ -> Jason.encode!(payload)
      end

    req =
      Req.Request.new(method: method, url: endpoint, headers: headers_kw(), body: body)
      |> Req.Request.append_response_steps(decompress_body: fn x -> x end)

    with {_req, %Req.Response{body: b}} <- Req.Request.run_request(req) do
      helper_make_request(Jason.decode(b))
    else
      {_req, exception} ->
        Logger.error("Home Assistant request failed: #{exception |> inspect()}")
        %{}
    end
  end

  defp helper_make_request({:ok, json}), do: json
  defp helper_make_request({:error, _e}), do: %{}
end
