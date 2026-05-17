defmodule AdyenEx.WebhooksTest do
  use ExUnit.Case, async: true

  alias AdyenEx.TestSupport.Factory
  alias AdyenEx.Webhooks
  alias AdyenEx.Webhooks.HMAC

  @hmac_key "44782DEF547AAA06C910C43932B1EB0C71FC68D9D0C057550C48EC2ACF6BA056"

  defmodule CaptureHandler do
    @behaviour AdyenEx.Webhooks.Handler

    @impl true
    def handle_event(event_code, item) do
      send(self(), {:handled, event_code, item["pspReference"]})
      :ok
    end
  end

  defp build_signed_payload(event_code) do
    item = Factory.build(:notification_item, %{"eventCode" => event_code})
    sig = HMAC.compute(item, @hmac_key)
    signed_item = put_in(item, ["additionalData", "hmacSignature"], sig)
    payload = Factory.build(:webhook_payload, [signed_item])
    {payload, signed_item}
  end

  describe "parse/1" do
    test "parses valid JSON string" do
      json = ~s({"notificationItems": []})
      assert {:ok, %{"notificationItems" => []}} = Webhooks.parse(json)
    end

    test "returns error for invalid JSON" do
      assert {:error, %AdyenEx.Error{type: :webhook_validation_error}} =
               Webhooks.parse("not json {{{")
    end

    test "returns error for empty string" do
      assert {:error, _} = Webhooks.parse("")
    end
  end

  describe "validate_all/2" do
    test "returns :ok when all items have valid HMAC" do
      {payload, _} = build_signed_payload("AUTHORISATION")
      assert :ok = Webhooks.validate_all(payload, @hmac_key)
    end

    test "returns error when any item has invalid HMAC" do
      item = Factory.build(:notification_item)
      bad_item = put_in(item, ["additionalData", "hmacSignature"], "bad==")
      payload = Factory.build(:webhook_payload, [bad_item])

      assert {:error, %AdyenEx.Error{type: :webhook_validation_error}} =
               Webhooks.validate_all(payload, @hmac_key)
    end

    test "returns :ok for empty notification list" do
      payload = %{"notificationItems" => []}
      assert :ok = Webhooks.validate_all(payload, @hmac_key)
    end

    test "validates multiple items — fails fast on first bad one" do
      {good_payload, _} = build_signed_payload("AUTHORISATION")
      good_item = get_in(good_payload, ["notificationItems"]) |> List.first()

      bad_item =
        Factory.build(:notification_item)
        |> put_in(["additionalData", "hmacSignature"], "invalid==")

      mixed_payload = %{
        "notificationItems" => [
          good_item,
          %{"NotificationRequestItem" => bad_item}
        ]
      }

      assert {:error, _} = Webhooks.validate_all(mixed_payload, @hmac_key)
    end
  end

  describe "process/3" do
    test "parses, validates, dispatches and returns :ok" do
      {payload, signed_item} = build_signed_payload("AUTHORISATION")
      raw_body = Jason.encode!(payload)

      assert :ok = Webhooks.process(raw_body, @hmac_key, CaptureHandler)
      assert_received {:handled, "AUTHORISATION", _psp}
    end

    test "returns error on invalid JSON" do
      assert {:error, %AdyenEx.Error{type: :webhook_validation_error}} =
               Webhooks.process("bad json", @hmac_key, CaptureHandler)
    end

    test "returns error on bad HMAC" do
      item = Factory.build(:notification_item)
      bad_item = put_in(item, ["additionalData", "hmacSignature"], "bad==")
      payload = Factory.build(:webhook_payload, [bad_item])
      raw_body = Jason.encode!(payload)

      assert {:error, %AdyenEx.Error{type: :webhook_validation_error}} =
               Webhooks.process(raw_body, @hmac_key, CaptureHandler)

      refute_received {:handled, _, _}
    end

    test "dispatches all event types correctly" do
      event_codes = ["AUTHORISATION", "CAPTURE", "REFUND", "CHARGEBACK", "PAYOUT_THIRDPARTY"]

      Enum.each(event_codes, fn code ->
        {payload, _} = build_signed_payload(code)
        raw_body = Jason.encode!(payload)
        assert :ok = Webhooks.process(raw_body, @hmac_key, CaptureHandler)
        assert_received {:handled, ^code, _}
      end)
    end
  end
end
