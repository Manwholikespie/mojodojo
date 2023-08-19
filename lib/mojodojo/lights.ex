defmodule Mojodojo.Lights do
  alias Mojodojo.HomeAssistant, as: HA

  def set_rgb(entity_id, r, g, b)
      when r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 do
    HA.set_domain_service("light", "turn_on", %{
      "entity_id" => entity_id,
      "rgb_color" => [r, g, b]
    })
  end

  def set_brightness(entity_id, brightness) when brightness >= 0 and brightness <= 255 do
    HA.set_domain_service("light", "turn_on", %{
      "entity_id" => entity_id,
      "brightness" => brightness
    })
  end

  @doc """
  Set temperature in mireds (micro reciprocal degrees)
  """
  def set_temp(entity_id, color_temp) when color_temp >= 153 and color_temp <= 500 do
    HA.set_domain_service("light", "turn_on", %{
      "entity_id" => entity_id,
      "color_temp" => color_temp
    })
  end

  def set_kelvin(entity_id, kelvin) when kelvin <= 6500 and kelvin >= 2000 do
    HA.set_domain_service("light", "turn_on", %{
      "entity_id" => entity_id,
      "kelvin" => kelvin
    })
  end

  @spec turn_on(bitstring()) :: map()
  def turn_on(entity_id) do
    HA.set_domain_service("light", "turn_on", %{"entity_id" => entity_id})
  end

  @spec turn_off(bitstring()) :: map()
  def turn_off(entity_id) do
    HA.set_domain_service("light", "turn_off", %{"entity_id" => entity_id})
  end
end
