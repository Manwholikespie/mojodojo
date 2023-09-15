_Originally this document was well written. Out of curiosity I passed it to GPT to see if it could clean it up slightly. It did such a terrible job I wondered what an intentionally bad revision would look like. It was too good not to use._

# 🌈✨MojoDojo🎉🕺

🌟Hey there, fellow light enthusiast!🌟 Step right up and get a dose of the shiniest, flashiest, and absolutely ✨fabulous✨ program that I've whipped up to pimp out my smart lights using Home Assistant! 🏠🤖 

## 🌅Super Cool Features (because basic is sooo last season!):
1. **mojodojo_flux**: 🌞➡️🌙 Ever thought, "Hey, wouldn't it be totes rad if my lights vibed with the sun?" Well, dream no more! 🌅 From sunrise blushes to high noon blues, my lights stay lit💡 (just like me on a Friday night) and dance their way to a snuggly red by midnight. It's like having a sunset party in your room, every day! 🌇💡❤️

2. **mojodojo_party**: 🎉💃 Ever wondered what magenta and cyan have in common? Me neither! But guess what, they're the VIPs at this party! Bounce between these two shades and let the party inside you awaken! (Warning: May bring out your inner disco star.⭐️)

## 🚨Alert! Read this if you're a customization junkie! 🚨
I'm rocking an RGBWW light strip that's split into two personas: Mr. RGB (`den.light_0`) and the always subtle Mrs. Dimmable (`den.light_1`). If your lights have different names or vibes, give the code a little makeover! 💄👠

Now, go sprinkle some MojoDojo magic onto your lights! And if you find joy in this little creation of mine, send some virtual hugs! 🤗🌈 Stay luminous, peeps! 💖🦄🔮🌠🎈

## Installation

Create `config/config.secret.exs` with the following

```
import Config

config :mojodojo,
  ha_key:
    "the home assistant api key you generated",
  ha_endpoint: "the ip of the computer you're running this from",
  api_key: "output of mix phx.gen.secret"

config :mojodojo, MojodojoWeb.Endpoint,
  secret_key_base: "output of mix phx.gen.secret"
```

Go in your Home Assistant configuration.yaml and configure the following. It's important to change the Authorization to "Bearer " + whatever your mojodojo `:api_key` value is.

```
switch:
  - platform: rest
    name: mojodojo_flux
    resource: http://localhost:4000/api/v1/flux
    body_on: '{"service": "turn_on"}'
    body_off: '{"service": "turn_off"}'
    is_on_template: "{{ value_json.is_active }}"
    headers:
      Content-Type: application/json
      Authorization: 'Bearer qwerty123_api_key_here'
  - platform: rest
    name: mojodojo_party
    resource: http://localhost:4000/api/v1/party
    body_on: '{"service": "turn_on"}'
    body_off: '{"service": "turn_off"}'
    is_on_template: "{{ value_json.is_active }}"
    headers:
      Content-Type: application/json
      Authorization: 'Bearer qwerty123_api_key_here'
```