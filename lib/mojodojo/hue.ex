defmodule Mojodojo.Hue do
  @moduledoc """
  For managing my smart lights (currently just two light strips connected to a
    Philips Hue bridge)
  """

  @spec discover_ip :: %{id: bitstring(), ip: bitstring()}
  def discover_ip() do
    %Req.Response{
      body: [
        %{
          "id" => id,
          "internalipaddress" => ip
        }
      ]
    } = Req.get!("https://discovery.meethue.com")

    %{id: id, ip: ip}
  end

  @doc """
  Register your application with the bridge after pressing its link button.

  Example devicetype: "my_hue_app#iphone peter"
  """
  @spec get_username(bitstring(), bitstring()) :: bitstring()
  def get_username(ip, devicetype) do
    endpoint = "http://#{ip}/api"

    with {:ok, username} <-
           Req.post!(endpoint, json: %{"devicetype" => devicetype}).body
           |> helper_process_username() do
      username
    end
  end

  @spec get_lights(bitstring(), bitstring()) :: map()
  def get_lights(ip, username) do
    endpoint = helper_endpoint(ip, username) <> "/lights"
    Req.get!(endpoint).body
  end

  def update_light(ip, username, light_id, state) do
    endpoint = helper_endpoint(ip, username) <> "/lights/#{light_id}/state"
    Req.put!(endpoint, json: state)
  end

  def helper_endpoint(ip, username), do: "http://#{ip}/api/#{username}"

  def helper_process_username(_request_body)

  def helper_process_username([%{"error" => %{"description" => desc}}]) do
    {:error, desc}
  end

  def helper_process_username([%{"success" => %{"username" => username}}]) do
    {:ok, username}
  end
end
