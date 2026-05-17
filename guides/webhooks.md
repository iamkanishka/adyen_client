# Webhooks Guide

## Setup checklist

1. Implement `AdyenClient.Webhooks.Handler`
2. Add `body_reader` to `Plug.Parsers` in `endpoint.ex`
3. Forward a route to `AdyenClient.Webhooks.Plug`
4. Set `ADYEN_HMAC_KEY` in your environment

## Handler skeleton

```elixir
defmodule MyApp.AdyenHandler do
  @behaviour AdyenClient.Webhooks.Handler

  @impl true
  def handle_event("AUTHORISATION", %{"success" => "true"} = item) do
    Orders.mark_paid(item["merchantReference"], item["pspReference"])
    :ok
  end

  def handle_event(_event_code, _item), do: :ok
end
```

## Phoenix setup

```elixir
# endpoint.ex — before Plug.Parsers
plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  body_reader: {AdyenClient.Webhooks.Plug, :read_body, []},
  json_decoder: Jason

# router.ex
forward "/webhooks/adyen", AdyenClient.Webhooks.Plug,
  handler:       MyApp.AdyenHandler,
  hmac_key:      System.get_env("ADYEN_HMAC_KEY"),
  validate_hmac: true
```

## Manual processing

```elixir
case AdyenClient.Webhooks.process(raw_body, hmac_key, MyApp.AdyenHandler) do
  :ok                                              -> respond_accepted(conn)
  {:error, %AdyenClient.Error{type: :webhook_validation_error}} -> respond_401(conn)
end
```
