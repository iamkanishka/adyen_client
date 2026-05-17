defmodule AdyenClient.TestSupport.Factory do
  @moduledoc "Test data factories for AdyenClient."

  def build(type, attrs \\ %{})

  def build(:amount, attrs) do
    Map.merge(%{"currency" => "EUR", "value" => 1000}, attrs)
  end

  def build(:payment_params, attrs) do
    Map.merge(
      %{
        "amount" => build(:amount),
        "merchantAccount" => "TestMerchant",
        "reference" => "order-#{System.unique_integer([:positive])}",
        "returnUrl" => "https://example.com/result",
        "paymentMethod" => %{"type" => "scheme", "encryptedCardNumber" => "test_4111111111111111"}
      },
      attrs
    )
  end

  def build(:session_params, attrs) do
    Map.merge(
      %{
        "amount" => build(:amount),
        "merchantAccount" => "TestMerchant",
        "reference" => "order-#{System.unique_integer([:positive])}",
        "returnUrl" => "https://example.com/result"
      },
      attrs
    )
  end

  def build(:notification_item, attrs) do
    Map.merge(
      %{
        "pspReference" => "PSP#{System.unique_integer([:positive])}",
        "originalReference" => "",
        "merchantAccountCode" => "TestMerchant",
        "merchantReference" => "order-123",
        "amount" => %{"value" => 1000, "currency" => "EUR"},
        "eventCode" => "AUTHORISATION",
        "success" => "true",
        "additionalData" => %{}
      },
      attrs
    )
  end

  def build(:webhook_payload, items) when is_list(items) do
    %{
      "live" => "false",
      "notificationItems" =>
        Enum.map(items, fn item ->
          %{"NotificationRequestItem" => item}
        end)
    }
  end

  def build(:api_config, attrs) do
    Map.merge(
      %{
        api_key: "test_api_key_#{System.unique_integer([:positive])}",
        environment: :test,
        merchant_account: "TestMerchant"
      },
      attrs
    )
  end
end
