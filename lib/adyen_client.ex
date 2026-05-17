defmodule AdyenClient do
  @moduledoc """
  # AdyenClient

  Production-grade Elixir client for the [Adyen Payments Platform](https://docs.adyen.com/api-explorer/).

  Covers all Adyen APIs: Checkout, BinLookup, Disputes, Recurring, Payout,
  Terminal, CloudDevice, SoftPOS, PaymentsApp, Management, BalanceControl,
  ForeignExchange, LegalEntity, BalancePlatform, SessionAuth, Transfers,
  Capital, OpenBanking, ClassicPayments, and ClassicPlatforms.

  ## Configuration

      config :adyen_client,
        api_key: System.get_env("ADYEN_API_KEY"),
        environment: :test,
        merchant_account: "YourMerchantECOM",
        webhook_hmac_key: System.get_env("ADYEN_HMAC_KEY")

  ## Quick example

      {:ok, session} = AdyenClient.Checkout.Sessions.create(%{
        amount: %{currency: "EUR", value: 1000},
        merchantAccount: "YourMerchantECOM",
        returnUrl: "https://yourapp.com/result",
        reference: "order-1234"
      })

  ## Error handling

      case AdyenClient.Checkout.Payments.create(params) do
        {:ok, %{"resultCode" => "Authorised"} = resp} -> handle_success(resp)
        {:error, %AdyenClient.Error{type: :auth_error}} -> Logger.error("Bad API key")
        {:error, %AdyenClient.Error{retryable: true} = err} -> schedule_retry(err)
      end
  """

  @spec version() :: String.t()
  def version, do: "1.0.0"
end
