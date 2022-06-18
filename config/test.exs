import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :skies, SkiesWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "G24DYdwW+U0JkdArviqAU4ZrD8Z6cU4+36CBFTE4ALLzDZFR8/42YHFKw5k7JzKT",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
