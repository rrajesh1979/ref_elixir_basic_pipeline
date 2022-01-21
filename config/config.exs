import Config

# # Our Logger general configuration
config :logger,
  backends: [:console],
  level: :info

config :ref_elixir_basic_pipeline,
  experian_endpoint: "https://run.mocky.io/v3/e6113909-57cb-47fe-9cbd-241e6e32b257",
  equifax_endpoint: "https://run.mocky.io/v3/741a50f7-cce9-495b-a094-d4a00c5438a3",
  aml_check_endpoint: "https://run.mocky.io/v3/41189e78-3d40-4ab4-971c-ce5c2bb266d2",
  fraud_check_endpoint: "https://run.mocky.io/v3/a807d47c-8295-4471-acfa-593bcd0bfe27",
  account_balance_endpoint: "https://run.mocky.io/v3/054783f0-2613-413b-bb99-1f0cfeda49e1"
