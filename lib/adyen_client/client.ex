defmodule AdyenClient.Client do
  @moduledoc """
  Core HTTP client for AdyenClient.

  Features:
  - Automatic retry with exponential backoff for retryable errors (5xx, 429)
  - Telemetry events on every request
  - Idempotency key injection for POST
  - Configurable timeouts
  - JSON encode/decode with Jason
  - Structured `AdyenClient.Error` on failure
  """

  alias AdyenClient.{Config, Error, Telemetry}

  @type method :: :get | :post | :patch | :put | :delete
  @type response :: {:ok, map() | list() | nil} | {:error, Error.t()}

  @doc """
  Make an authenticated API request.

  ## Options
  - `:body` — request body (map), JSON-encoded automatically
  - `:query` — map of query string params
  - `:config` — `AdyenClient.Config.t()` (defaults to `Config.load!()`)
  - `:idempotency_key` — override the auto-generated POST idempotency key
  """
  @spec request(method(), String.t(), keyword()) :: response()
  def request(method, url, opts \\ []) do
    config = Keyword.get(opts, :config, Config.load!())
    body = Keyword.get(opts, :body)
    query = Keyword.get(opts, :query, %{})
    idempotency_key = resolve_idempotency_key(method, opts)

    headers = build_headers(config, idempotency_key)

    start_time = System.monotonic_time()
    Telemetry.request_start(method, url, body)

    result = do_request_with_retry(method, url, headers, body, query, config)

    duration = System.monotonic_time() - start_time
    Telemetry.request_stop(method, url, result, duration)

    result
  end

  @spec get(String.t(), keyword()) :: response()
  def get(url, opts \\ []), do: request(:get, url, opts)

  @spec post(String.t(), map(), keyword()) :: response()
  def post(url, body, opts \\ []), do: request(:post, url, Keyword.put(opts, :body, body))

  @spec patch(String.t(), map(), keyword()) :: response()
  def patch(url, body, opts \\ []), do: request(:patch, url, Keyword.put(opts, :body, body))

  @spec delete(String.t(), keyword()) :: response()
  def delete(url, opts \\ []), do: request(:delete, url, opts)

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp do_request_with_retry(method, url, headers, body, query, config, attempt \\ 0) do
    case do_request(method, url, headers, body, query, config) do
      {:error, %Error{retryable: true}} = _error when attempt < config.max_retries ->
        delay = trunc(config.retry_delay * :math.pow(2, attempt))
        Process.sleep(delay)
        do_request_with_retry(method, url, headers, body, query, config, attempt + 1)

      other ->
        other
    end
  end

  defp do_request(method, url, headers, body, query, config) do
    req =
      [
        method: method,
        url: url,
        headers: headers,
        receive_timeout: config.timeout,
        connect_options: [timeout: config.connect_timeout]
      ]
      |> maybe_put_body(body)
      |> maybe_put_params(query)

    case Req.request(req) do
      {:ok, %{status: status, body: resp_body}} when status in 200..299 ->
        {:ok, resp_body}

      {:ok, %{status: status, body: resp_body}} when is_map(resp_body) ->
        {:error, Error.from_response(resp_body, status)}

      {:ok, %{status: status}} ->
        {:error, Error.from_response(%{"message" => "HTTP #{status}"}, status)}

      {:error, %{reason: :timeout}} ->
        {:error,
         %Error{
           type: :timeout,
           message: "Request timed out",
           retryable: true,
           status: nil,
           error_code: nil,
           psp_reference: nil,
           raw: nil
         }}

      {:error, exception} ->
        {:error, Error.network("Request failed: #{inspect(exception)}")}
    end
  end

  defp build_headers(config, idempotency_key) do
    headers = [
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"x-api-key", config.api_key},
      {"user-agent", config.user_agent}
    ]

    if idempotency_key do
      [{"idempotency-key", idempotency_key} | headers]
    else
      headers
    end
  end

  defp resolve_idempotency_key(:post, opts) do
    Keyword.get(opts, :idempotency_key) || generate_idempotency_key()
  end

  defp resolve_idempotency_key(_, opts), do: Keyword.get(opts, :idempotency_key)

  defp generate_idempotency_key do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
  end

  defp maybe_put_body(opts, nil), do: opts

  defp maybe_put_body(opts, body) when is_map(body) or is_list(body) do
    Keyword.put(opts, :body, Jason.encode!(body))
  end

  defp maybe_put_params(opts, params) when map_size(params) == 0, do: opts
  defp maybe_put_params(opts, params), do: Keyword.put(opts, :params, params)
end
