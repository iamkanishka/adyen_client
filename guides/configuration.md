# Configuration Guide

Complete reference for all `AdyenClient` configuration options.

## Application config

```elixir
# config/config.exs
config :adyen_client,
  api_key:          System.get_env("ADYEN_API_KEY"),
  environment:      :test,
  merchant_account: "YourMerchantECOM",
  timeout:          30_000,
  max_retries:      3,
  webhook_hmac_key: System.get_env("ADYEN_HMAC_KEY")

# config/prod.exs
config :adyen_client, environment: :live
```

## Runtime override

```elixir
custom = AdyenClient.Config.load!(%{api_key: "other_key", environment: :live})
AdyenClient.Checkout.Sessions.create(%{...}, config: custom)
```

## Validation

`AdyenClient.Config.load/1` returns `{:ok, config}` or `{:error, message}`.
`AdyenClient.Config.load!/1` raises `ArgumentError` on invalid config.

Required: `:api_key`. All other keys have defaults.
