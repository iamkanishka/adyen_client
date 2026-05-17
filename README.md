# AdyenClient

[![Hex.pm](https://img.shields.io/hexpm/v/adyen_client.svg)](https://hex.pm/packages/adyen_client)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Production-grade Elixir client for the [Adyen Payments Platform](https://docs.adyen.com/api-explorer/).**

Covers every Adyen API — 200+ endpoints across 30+ namespaces — with retry, circuit breaker,
rate limiting, HMAC webhook validation, Plug integration, Dialyzer-clean typespecs, and
structured error handling throughout.

See **[USAGE_GUIDE.md](USAGE_GUIDE.md)** for the complete usage reference.

---

## Installation

```elixir
# mix.exs
def deps do
  [
    {:adyen_client, "~> 1.0"},
    {:plug, "~> 1.15"}   # only needed for AdyenClient.Webhooks.Plug
  ]
end
```

## Configuration

```elixir
# config/config.exs
config :adyen_client,
  api_key:          System.get_env("ADYEN_API_KEY"),
  environment:      :test,                # :test | :live
  merchant_account: "YourMerchantECOM",
  timeout:          30_000,
  max_retries:      3,
  webhook_hmac_key: System.get_env("ADYEN_HMAC_KEY")

# config/prod.exs
config :adyen_client, environment: :live
```

## Quick Example

```elixir
# Create a payment session (Drop-in / Components)
{:ok, session} =
  AdyenClient.Checkout.Sessions.create(%{
    amount:          %{currency: "EUR", value: 1000},
    merchantAccount: "YourMerchantECOM",
    reference:       "order-1234",
    returnUrl:       "https://yourapp.com/result"
  })

# Capture an authorised payment
{:ok, _} =
  AdyenClient.Checkout.Modifications.capture("PSP-REF", %{
    merchantAccount: "YourMerchantECOM",
    amount: %{currency: "EUR", value: 1000}
  })

# Receive and validate a webhook
:ok = AdyenClient.Webhooks.process(raw_body, hmac_key, MyApp.AdyenHandler)
```

## Error Handling

Every function returns `{:ok, body}` or `{:error, %AdyenClient.Error{}}`:

```elixir
case AdyenClient.Checkout.Payments.create(params) do
  {:ok, %{"resultCode" => "Authorised"} = resp} -> handle_success(resp)
  {:error, %AdyenClient.Error{type: :auth_error}} -> Logger.error("Bad API key")
  {:error, %AdyenClient.Error{retryable: true}}   -> schedule_retry()
end
```

## License

MIT
