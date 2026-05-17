if Code.ensure_loaded?(Plug) do
  defmodule AdyenClient.Webhooks.Plug do
    @moduledoc """
    A `Plug` that handles Adyen webhook HTTP requests end-to-end.

    Reads the raw body, validates the HMAC signature, dispatches events
    to your handler module, and responds with `[accepted]` as Adyen requires.

    ## Usage in Phoenix router

        # In your endpoint.ex, add raw body passthrough BEFORE Plug.Parsers:
        plug Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          body_reader: {AdyenClient.Webhooks.Plug, :read_body, []},
          json_decoder: Jason

        # In your router.ex:
        forward "/webhooks/adyen", AdyenClient.Webhooks.Plug,
          handler: MyApp.AdyenWebhookHandler,
          hmac_key: System.get_env("ADYEN_HMAC_KEY")

    ## Options

    - `:handler` — module implementing `AdyenClient.Webhooks.Handler` (required)
    - `:hmac_key` — HMAC key string (optional; falls back to config)
    - `:validate_hmac` — boolean, default `true`; set to `false` in dev only
    """

    @behaviour Plug

    import Plug.Conn

    alias AdyenClient.Error
    alias AdyenClient.Webhooks
    alias AdyenClient.Webhooks.Handler

    @impl true
    def init(opts) do
      handler = Keyword.fetch!(opts, :handler)

      hmac_key =
        Keyword.get(opts, :hmac_key) || Application.get_env(:adyen_client, :webhook_hmac_key)

      validate_hmac = Keyword.get(opts, :validate_hmac, true)

      %{handler: handler, hmac_key: hmac_key, validate_hmac: validate_hmac}
    end

    @impl true
    def call(conn, %{handler: handler, hmac_key: hmac_key, validate_hmac: validate_hmac}) do
      with {:ok, raw_body, conn} <- read_full_body(conn),
           {:ok, payload} <- Webhooks.parse(raw_body),
           :ok <- maybe_validate(payload, hmac_key, validate_hmac) do
        Handler.dispatch(payload, handler)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{notificationResponse: "[accepted]"}))
      else
        {:error, %Error{type: :webhook_validation_error, message: msg}} ->
          require Logger
          Logger.warning("AdyenClient: rejected webhook — #{msg}")

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(401, Jason.encode!(%{error: msg}))

        {:error, reason} ->
          require Logger
          Logger.error("AdyenClient: webhook processing error — #{inspect(reason)}")

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(500, Jason.encode!(%{error: "internal error"}))
      end
    end

    @doc "Passthrough body reader — stores raw body in conn private for later HMAC use."
    def read_body(conn, opts) do
      {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
      conn = update_in(conn.private, &Map.put(&1, :raw_body, body))
      {:ok, body, conn}
    end

    defp read_full_body(conn) do
      case conn.private[:raw_body] do
        nil ->
          case Plug.Conn.read_body(conn) do
            {:ok, body, conn} -> {:ok, body, conn}
            {:more, body, conn} -> {:ok, body, conn}
            {:error, reason} -> {:error, reason}
          end

        raw ->
          {:ok, raw, conn}
      end
    end

    defp maybe_validate(_payload, _key, false), do: :ok

    defp maybe_validate(_payload, nil, true),
      do: {:error, Error.webhook_validation("No HMAC key configured")}

    defp maybe_validate(payload, key, true), do: Webhooks.validate_all(payload, key)
  end
end
