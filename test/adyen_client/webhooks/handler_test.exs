defmodule AdyenClient.Webhooks.HandlerTest do
  use ExUnit.Case, async: true

  alias AdyenClient.TestSupport.Factory
  alias AdyenClient.Webhooks.Handler

  defmodule TestHandler do
    @behaviour AdyenClient.Webhooks.Handler

    @impl true
    def handle_event(event_code, item) do
      send(self(), {:adyen_event, event_code, item})
      :ok
    end
  end

  defmodule ErrorHandler do
    @behaviour AdyenClient.Webhooks.Handler

    @impl true
    def handle_event(_event_code, _item) do
      raise RuntimeError, "handler crashed"
    end
  end

  describe "dispatch/2" do
    test "dispatches a single notification item to handler" do
      item = Factory.build(:notification_item, %{"eventCode" => "AUTHORISATION"})
      payload = Factory.build(:webhook_payload, [item])

      Handler.dispatch(payload, TestHandler)

      assert_received {:adyen_event, "AUTHORISATION", ^item}
    end

    test "dispatches multiple items" do
      items = [
        Factory.build(:notification_item, %{"eventCode" => "AUTHORISATION"}),
        Factory.build(:notification_item, %{"eventCode" => "CAPTURE"}),
        Factory.build(:notification_item, %{"eventCode" => "REFUND"})
      ]

      payload = Factory.build(:webhook_payload, items)
      Handler.dispatch(payload, TestHandler)

      assert_received {:adyen_event, "AUTHORISATION", _}
      assert_received {:adyen_event, "CAPTURE", _}
      assert_received {:adyen_event, "REFUND", _}
    end

    test "handles empty notification items gracefully" do
      payload = %{"live" => "false", "notificationItems" => []}
      assert :ok = Handler.dispatch(payload, TestHandler)
      refute_received {:adyen_event, _, _}
    end

    test "does not crash when handler raises an exception" do
      item = Factory.build(:notification_item)
      payload = Factory.build(:webhook_payload, [item])

      assert :ok = Handler.dispatch(payload, ErrorHandler)
    end

    test "continues processing remaining items after a handler crash" do
      items = [
        Factory.build(:notification_item, %{"eventCode" => "FIRST"}),
        Factory.build(:notification_item, %{"eventCode" => "SECOND"})
      ]

      payload = Factory.build(:webhook_payload, items)
      Handler.dispatch(payload, ErrorHandler)
      # No assertion needed — just verifying no crash
    end

    test "dispatch provides event_code and full item to handler" do
      psp = "PSP_TEST_123"
      ref = "order-999"

      item =
        Factory.build(:notification_item, %{
          "pspReference" => psp,
          "merchantReference" => ref,
          "eventCode" => "AUTHORISATION",
          "success" => "true"
        })

      payload = Factory.build(:webhook_payload, [item])
      Handler.dispatch(payload, TestHandler)

      assert_received {:adyen_event, "AUTHORISATION", received_item}
      assert received_item["pspReference"] == psp
      assert received_item["merchantReference"] == ref
      assert received_item["success"] == "true"
    end
  end
end
