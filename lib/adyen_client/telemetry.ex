defmodule AdyenClient.Telemetry do
  @moduledoc """
  Telemetry integration for AdyenClient.

  ## Events

  - `[:adyen_client, :request, :start]` — before each HTTP request
    - metadata: `%{method: method, url: url, body: body}`
  - `[:adyen_client, :request, :stop]` — after each HTTP request
    - measurements: `%{duration: native_time}`
    - metadata: `%{method: method, url: url, status: :ok | :error}`
  - `[:adyen_client, :request, :exception]` — on unexpected exception

  ## Usage

      :telemetry.attach("my-handler", [:adyen_client, :request, :stop], fn event, meas, meta, _ ->
        Logger.info("Adyen \#{meta.method} \#{meta.url} in \#{meas.duration}ns: \#{meta.status}")
      end, nil)
  """

  require Logger

  @start_event [:adyen_client, :request, :start]
  @stop_event [:adyen_client, :request, :stop]

  @spec request_start(atom(), String.t(), map() | nil) :: :ok
  def request_start(method, url, body) do
    :telemetry.execute(@start_event, %{system_time: System.system_time()}, %{
      method: method,
      url: sanitize_url(url),
      body: sanitize_body(body)
    })
  end

  @spec request_stop(atom(), String.t(), term(), integer()) :: :ok
  def request_stop(method, url, result, duration) do
    status = if match?({:ok, _}, result), do: :ok, else: :error
    http_status = extract_status(result)

    :telemetry.execute(@stop_event, %{duration: duration}, %{
      method: method,
      url: sanitize_url(url),
      status: status,
      http_status: http_status
    })
  end

  defp extract_status({:ok, _}), do: 200
  defp extract_status({:error, %{status: s}}), do: s
  defp extract_status(_), do: nil

  defp sanitize_url(url) do
    # Strip query params that might contain sensitive info
    url |> URI.parse() |> Map.put(:query, nil) |> URI.to_string()
  end

  defp sanitize_body(nil), do: nil

  defp sanitize_body(body) when is_map(body) do
    sensitive_keys = ~w(cardNumber cvv cvc expiryMonth expiryYear number holderName)

    Map.new(body, fn
      {k, v} when is_map(v) ->
        {k, sanitize_body(v)}

      {k, _v} = pair ->
        if k in sensitive_keys, do: {k, "[REDACTED]"}, else: pair
    end)
  end

  defp sanitize_body(body), do: body
end
