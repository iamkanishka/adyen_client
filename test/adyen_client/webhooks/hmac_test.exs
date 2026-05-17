defmodule AdyenClient.Webhooks.HMACTest do
  use ExUnit.Case, async: true

  alias AdyenClient.Webhooks.HMAC

  # Official Adyen test vector from their documentation
  @test_hmac_key "44782DEF547AAA06C910C43932B1EB0C71FC68D9D0C057550C48EC2ACF6BA056"

  @test_notification_item %{
    "pspReference" => "test_AUTHORISATION_1",
    "originalReference" => "",
    "merchantAccountCode" => "TestMerchant",
    "merchantReference" => "TestPayment-1407325143704",
    "amount" => %{"value" => 1130, "currency" => "EUR"},
    "eventCode" => "AUTHORISATION",
    "success" => "true",
    "additionalData" => %{}
  }

  describe "compute/2" do
    test "returns a base64 encoded string" do
      sig = HMAC.compute(@test_notification_item, @test_hmac_key)
      assert is_binary(sig)
      assert byte_size(sig) > 0
      # Must be valid base64
      assert {:ok, _} = Base.decode64(sig)
    end

    test "is deterministic for the same input" do
      sig1 = HMAC.compute(@test_notification_item, @test_hmac_key)
      sig2 = HMAC.compute(@test_notification_item, @test_hmac_key)
      assert sig1 == sig2
    end

    test "differs for different event codes" do
      item_auth = @test_notification_item
      item_capture = Map.put(@test_notification_item, "eventCode", "CAPTURE")

      sig1 = HMAC.compute(item_auth, @test_hmac_key)
      sig2 = HMAC.compute(item_capture, @test_hmac_key)
      assert sig1 != sig2
    end

    test "differs for different PSP references" do
      item1 = @test_notification_item
      item2 = Map.put(@test_notification_item, "pspReference", "different_psp")

      sig1 = HMAC.compute(item1, @test_hmac_key)
      sig2 = HMAC.compute(item2, @test_hmac_key)
      assert sig1 != sig2
    end

    test "differs for different amounts" do
      item1 = @test_notification_item
      item2 = put_in(@test_notification_item, ["amount", "value"], 9999)

      sig1 = HMAC.compute(item1, @test_hmac_key)
      sig2 = HMAC.compute(item2, @test_hmac_key)
      assert sig1 != sig2
    end

    test "handles missing optional fields gracefully" do
      minimal = %{
        "pspReference" => "PSP123",
        "originalReference" => nil,
        "merchantAccountCode" => "Merchant",
        "merchantReference" => "order-1",
        "amount" => %{"value" => 100, "currency" => "USD"},
        "eventCode" => "AUTHORISATION",
        "success" => "true"
      }

      sig = HMAC.compute(minimal, @test_hmac_key)
      assert is_binary(sig)
    end
  end

  describe "validate/2" do
    test "returns :ok when signature matches" do
      computed = HMAC.compute(@test_notification_item, @test_hmac_key)

      item_with_sig =
        put_in(@test_notification_item, ["additionalData", "hmacSignature"], computed)

      assert :ok = HMAC.validate(item_with_sig, @test_hmac_key)
    end

    test "returns error when signature does not match" do
      item_with_bad_sig =
        put_in(@test_notification_item, ["additionalData", "hmacSignature"], "bad_signature==")

      assert {:error, %AdyenClient.Error{type: :webhook_validation_error}} =
               HMAC.validate(item_with_bad_sig, @test_hmac_key)
    end

    test "returns error when hmacSignature is missing" do
      assert {:error, %AdyenClient.Error{type: :webhook_validation_error, message: msg}} =
               HMAC.validate(@test_notification_item, @test_hmac_key)

      assert msg =~ "Missing hmacSignature"
    end

    test "returns error when additionalData is missing entirely" do
      item = Map.delete(@test_notification_item, "additionalData")

      assert {:error, %AdyenClient.Error{type: :webhook_validation_error}} =
               HMAC.validate(item, @test_hmac_key)
    end

    test "handles CAPTURE event code" do
      capture_item = Map.put(@test_notification_item, "eventCode", "CAPTURE")
      computed = HMAC.compute(capture_item, @test_hmac_key)
      item_with_sig = put_in(capture_item, ["additionalData", "hmacSignature"], computed)
      assert :ok = HMAC.validate(item_with_sig, @test_hmac_key)
    end

    test "handles REFUND event code" do
      refund_item = Map.put(@test_notification_item, "eventCode", "REFUND")
      computed = HMAC.compute(refund_item, @test_hmac_key)
      item_with_sig = put_in(refund_item, ["additionalData", "hmacSignature"], computed)
      assert :ok = HMAC.validate(item_with_sig, @test_hmac_key)
    end

    test "computed sig for auth item doesn't validate capture item" do
      auth_sig = HMAC.compute(@test_notification_item, @test_hmac_key)
      capture_item = Map.put(@test_notification_item, "eventCode", "CAPTURE")
      item_with_auth_sig = put_in(capture_item, ["additionalData", "hmacSignature"], auth_sig)

      assert {:error, _} = HMAC.validate(item_with_auth_sig, @test_hmac_key)
    end
  end

  describe "validate_balance_platform/3" do
    test "returns :ok for matching signature" do
      raw_body = ~s({"type":"balancePlatform.transfer.created","data":{}})
      key = @test_hmac_key
      decoded_key = Base.decode16!(key, case: :mixed)
      sig = :crypto.mac(:hmac, :sha256, decoded_key, raw_body) |> Base.encode64()
      assert :ok = HMAC.validate_balance_platform(raw_body, sig, key)
    end

    test "returns error for mismatched signature" do
      raw_body = ~s({"type":"balancePlatform.transfer.created"})
      assert {:error, _} = HMAC.validate_balance_platform(raw_body, "badsig==", @test_hmac_key)
    end
  end
end
