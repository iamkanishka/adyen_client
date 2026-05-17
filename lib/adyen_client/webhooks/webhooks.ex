defmodule AdyenClient.Webhooks.HMAC do
  @moduledoc """
  HMAC-SHA256 webhook signature validation for Adyen notifications.

  Adyen signs webhook payloads using HMAC-SHA256 with a hex-encoded key.
  The signature is computed over a pipe-delimited string of specific fields.

  ## Usage

      hmac_key = Application.get_env(:adyen_client, :webhook_hmac_key)

      case AdyenClient.Webhooks.HMAC.validate(notification_item, hmac_key) do
        :ok -> handle_event(notification_item)
        {:error, reason} -> Logger.warning("Webhook rejected: \#{reason}")
      end
  """

  alias AdyenClient.Error

  @type notification_item :: map()

  @doc """
  Validate the HMAC signature of a standard webhook notification item.

  `notification_item` should be the map at `notificationRequestItem` level,
  containing keys: `pspReference`, `originalReference`, `merchantAccountCode`,
  `merchantReference`, `value`, `currency`, `eventCode`, `success`, `additionalData`.
  """
  @spec validate(notification_item(), String.t()) :: :ok | {:error, Error.t()}
  def validate(notification_item, hmac_key) do
    received_hmac = get_in(notification_item, ["additionalData", "hmacSignature"])

    if is_nil(received_hmac) do
      {:error, Error.webhook_validation("Missing hmacSignature in additionalData")}
    else
      expected = compute(notification_item, hmac_key)

      if secure_compare(expected, received_hmac) do
        :ok
      else
        {:error, Error.webhook_validation("HMAC signature mismatch")}
      end
    end
  end

  @doc """
  Compute the HMAC-SHA256 signature for a notification item.

  Returns the base64-encoded signature string.
  """
  @spec compute(notification_item(), String.t()) :: String.t()
  def compute(item, hmac_key) do
    key = Base.decode16!(hmac_key, case: :mixed)
    data = build_signing_string(item)
    :crypto.mac(:hmac, :sha256, key, data) |> Base.encode64()
  end

  @doc """
  Validate the HMAC signature of a Balance Platform webhook.

  Balance Platform webhooks use a different signing approach:
  the full JSON body is signed directly.
  """
  @spec validate_balance_platform(String.t(), String.t(), String.t()) ::
          :ok | {:error, Error.t()}
  def validate_balance_platform(raw_body, received_hmac, hmac_key) do
    key = Base.decode16!(hmac_key, case: :mixed)
    expected = :crypto.mac(:hmac, :sha256, key, raw_body) |> Base.encode64()

    if secure_compare(expected, received_hmac) do
      :ok
    else
      {:error, Error.webhook_validation("Balance Platform HMAC signature mismatch")}
    end
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  # The signing string is a pipe-delimited concatenation of specific fields.
  # Adyen's documented order:
  # pspReference|originalReference|merchantAccountCode|merchantReference|value|currency|eventCode|success
  defp build_signing_string(item) do
    fields = [
      item["pspReference"] || "",
      item["originalReference"] || "",
      item["merchantAccountCode"] || "",
      item["merchantReference"] || "",
      get_in(item, ["amount", "value"]) |> to_string(),
      get_in(item, ["amount", "currency"]) || "",
      item["eventCode"] || "",
      item["success"] || ""
    ]

    Enum.join(fields, "|")
  end

  # Constant-time string comparison to prevent timing attacks.
  defp secure_compare(a, b) when byte_size(a) != byte_size(b), do: false

  defp secure_compare(a, b) do
    :crypto.hash_equals(a, b)
  end
end

defmodule AdyenClient.Webhooks.Handler do
  @moduledoc """
  Behaviour for implementing Adyen webhook event handlers.

  ## Usage

      defmodule MyApp.AdyenWebhookHandler do
        @behaviour AdyenClient.Webhooks.Handler

        @impl true
        def handle_event("AUTHORISATION", %{"success" => "true"} = item) do
          psp = item["pspReference"]
          ref = item["merchantReference"]
          MyApp.Orders.mark_paid(ref, psp)
          :ok
        end

        def handle_event("REFUND", item) do
          MyApp.Refunds.process(item)
          :ok
        end

        def handle_event(event_code, item) do
          Logger.info("Unhandled Adyen event: \#{event_code}", item: item)
          :ok
        end
      end

  Then configure it:

      config :adyen_client, webhook_handler: MyApp.AdyenWebhookHandler
  """

  @type event_code :: String.t()
  @type notification_item :: map()
  @type handle_result :: :ok | {:error, term()}

  @doc """
  Handle an incoming webhook event.

  Called once per notification item. Return `:ok` to acknowledge,
  `{:error, reason}` to signal failure (the Plug will still return [accepted] to Adyen).
  """
  @callback handle_event(event_code(), notification_item()) :: handle_result()

  @doc """
  Process a raw Adyen webhook payload map, dispatching each item to the handler.

  Returns `:ok` if all items were handled successfully.
  """
  @spec dispatch(map(), module()) :: :ok
  def dispatch(payload, handler_module) do
    items =
      payload
      |> get_in(["notificationItems"])
      |> List.wrap()

    Enum.each(items, fn %{"NotificationRequestItem" => item} ->
      event_code = item["eventCode"]

      try do
        handler_module.handle_event(event_code, item)
      rescue
        e ->
          require Logger

          Logger.error(
            "[AdyenClient] Webhook handler raised for #{event_code}: #{Exception.message(e)}"
          )
      end
    end)
  end
end

defmodule AdyenClient.Webhooks do
  @moduledoc """
  Top-level webhook utilities.

  Parses and validates incoming Adyen webhook payloads and dispatches
  them to your configured handler module.

  ## Quick start

  1. Add `AdyenClient.Webhooks.Plug` to your router (requires `:plug` dep).
  2. Or call `AdyenClient.Webhooks.process/3` manually in your controller.

  ## Event codes reference

  Standard events: AUTHORISATION, CAPTURE, CANCEL, REFUND, REFUND_FAILED,
  CANCEL_OR_REFUND, CAPTURE_FAILED, REFUNDED_REVERSED, EXPIRE, VOID_PENDING_REFUND,
  ORDER_OPENED, ORDER_CLOSED, REPORT_AVAILABLE, TECHNICAL_CANCEL.

  Dispute events: NOTIFICATION_OF_CHARGEBACK, CHARGEBACK, CHARGEBACK_REVERSED,
  SECOND_CHARGEBACK, NOTIFICATION_OF_FRAUD, REQUEST_FOR_INFORMATION,
  INFORMATION_SUPPLIED, PREARBITRATION_OPEN, PREARBITRATION_LOST,
  PREARBITRATION_WON, PREARBITRATION_DECLINED, PREARBITRATION_ACCEPTED,
  PREARBITRATION_ISSUER_WITHDRAWN, SCHEME_ARBITRATION, DISPUTE_DEFENSE_PERIOD_ENDED,
  ISSUER_COMMENTS, ISSUER_RESPONSE_TIMEFRAME_EXPIRED.

  Additional: AUTORESCUE, CANCEL_AUTORESCUE, MANUAL_REVIEW_ACCEPT,
  MANUAL_REVIEW_REJECT, OFFER_CLOSED, POSTPONED_REFUND, RECURRING_CONTRACT,
  ACH_NOTIFICATION_OF_CHANGE, DIRECT_DEBIT_NOTICE_OF_CHANGE_NOTIFICATION.
  """

  alias AdyenClient.Error
  alias AdyenClient.Webhooks.Handler
  alias AdyenClient.Webhooks.HMAC

  @doc """
  Parse, validate, and dispatch a raw webhook payload.

  `raw_body` must be the unmodified request body string.
  `hmac_key` is the HMAC key configured in Adyen for this webhook endpoint.
  `handler` is the module implementing `AdyenClient.Webhooks.Handler`.

  Returns `:ok` on success or `{:error, AdyenClient.Error.t()}` on HMAC failure.
  """
  @spec process(String.t(), String.t(), module()) :: :ok | {:error, Error.t()}
  def process(raw_body, hmac_key, handler) do
    with {:ok, payload} <- parse(raw_body),
         :ok <- validate_all(payload, hmac_key) do
      Handler.dispatch(payload, handler)
      :ok
    end
  end

  @doc "Parse the raw JSON body into a map."
  @spec parse(String.t()) :: {:ok, map()} | {:error, Error.t()}
  def parse(raw_body) do
    case Jason.decode(raw_body) do
      {:ok, map} -> {:ok, map}
      {:error, _} -> {:error, Error.webhook_validation("Invalid JSON body")}
    end
  end

  @doc "Validate HMAC for all notification items in a parsed payload."
  @spec validate_all(map(), String.t()) :: :ok | {:error, Error.t()}
  def validate_all(payload, hmac_key) do
    items =
      payload
      |> get_in(["notificationItems"])
      |> List.wrap()

    results =
      Enum.map(items, fn %{"NotificationRequestItem" => item} ->
        HMAC.validate(item, hmac_key)
      end)

    case Enum.find(results, &match?({:error, _}, &1)) do
      nil -> :ok
      error -> error
    end
  end
end
