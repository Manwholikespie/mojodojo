defmodule Mojodojo.Lights do
  alias Mojodojo.HomeAssistant, as: HA

  def set_rgb(entity_id, r, g, b) do
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
end
