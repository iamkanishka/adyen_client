# Telemetry Guide

`AdyenClient` emits `:telemetry` events on every HTTP request.

## Events

| Event | Measurements | Metadata |
|---|---|---|
| `[:adyen_client, :request, :start]` | `system_time` | `method`, `url`, `body` |
| `[:adyen_client, :request, :stop]` | `duration` (native) | `method`, `url`, `status`, `http_status` |

PCI-sensitive fields (`cardNumber`, `cvv`, `cvc`, `expiryMonth`, `expiryYear`,
`number`, `holderName`) are redacted from `body` before the event is emitted.

## Attaching a handler

```elixir
# In Application.start/2
:telemetry.attach_many(
  "my-adyen-metrics",
  [
    [:adyen_client, :request, :start],
    [:adyen_client, :request, :stop]
  ],
  &MyApp.AdyenTelemetry.handle/4,
  nil
)
```

```elixir
defmodule MyApp.AdyenTelemetry do
  def handle([:adyen_client, :request, :stop], %{duration: dur}, meta, _) do
    ms = System.convert_time_unit(dur, :native, :millisecond)
    MyApp.Metrics.histogram("adyen.request.duration_ms", ms,
      tags: ["method:#{meta.method}", "status:#{meta.http_status}"]
    )
  end

  def handle(_event, _meas, _meta, _cfg), do: :ok
end
```
