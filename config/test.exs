import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mojodojo, MojodojoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Qxuu8UOdti9+p0dM2fKt9DFCO1glL5KfCMbKhzqJYwmhRZjBIkGih/HdoWAkDykK",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime