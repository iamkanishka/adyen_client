# Error Handling Guide

All `AdyenClient` functions return `{:ok, body}` or `{:error, %AdyenClient.Error{}}`.

## Error struct

```elixir
%AdyenClient.Error{
  type:          :server_error,
  status:        503,
  message:       "Service unavailable",
  error_code:    nil,
  psp_reference: nil,
  raw:           %{"message" => "Service unavailable"},
  retryable:     true
}
```

## Pattern matching

```elixir
case AdyenClient.Checkout.Payments.create(params) do
  {:ok, %{"resultCode" => "Authorised"} = resp} -> handle_success(resp)
  {:error, %AdyenClient.Error{type: :auth_error}} -> handle_auth_error()
  {:error, %AdyenClient.Error{retryable: true}}   -> schedule_retry()
  {:error, err}                                   -> handle_generic(err)
end
```

## Error types

| type | HTTP | retryable |
|---|---|---|
| `:auth_error` | 401, 403 | false |
| `:not_found` | 404 | false |
| `:validation_error` | 422 | false |
| `:api_error` | 400–499 | false |
| `:rate_limited` | 429 | true |
| `:server_error` | 500–599 | true |
| `:network_error` | — | true |
| `:timeout` | — | true |
| `:config_error` | — | false |
| `:webhook_validation_error` | — | false |
