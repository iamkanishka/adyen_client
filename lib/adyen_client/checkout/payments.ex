defmodule AdyenClient.Checkout.Payments do
  @moduledoc """
  Adyen Checkout Payments API.

  Handles payment method listing, transaction initiation, detail submission,
  and card BIN details.
  """

  alias AdyenClient.{Client, Config}

  @doc """
  Get a list of available payment methods for the given context.

  ## Required fields
  - `merchantAccount`
  - `amount` — used to filter methods that support the currency/amount
  - `countryCode` — ISO 3166-1 alpha-2

  ## Example

      AdyenClient.Checkout.Payments.list_payment_methods(%{
        merchantAccount: "YourMerchantECOM",
        amount: %{currency: "EUR", value: 1000},
        countryCode: "NL"
      })
  """
  @spec list_payment_methods(map(), keyword()) :: Client.response()
  def list_payment_methods(params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/paymentMethods"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Start a payment transaction (Advanced flow).

  ## Required fields
  - `amount`
  - `merchantAccount`
  - `reference`
  - `paymentMethod` — payment method details or encrypted data
  - `returnUrl`

  ## Optional notable fields
  - `shopperReference` — for tokenization
  - `storePaymentMethod` — boolean
  - `recurringProcessingModel` — `"CardOnFile"` | `"Subscription"` | `"UnscheduledCardOnFile"`
  - `additionalData` — map of extra fields
  - `lineItems` — for Level 2/3 data
  - `browserInfo` — required for 3DS
  - `channel` — `"Web"` | `"iOS"` | `"Android"`
  """
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/payments"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Submit additional details for a payment (e.g. after 3DS redirect).

  ## Required fields
  - `details` — map of additional data (e.g. `%{"redirectResult" => "..."}`)
  - `paymentData` — the `paymentData` value returned by the initial `create/2`
  """
  @spec submit_details(map(), keyword()) :: Client.response()
  def submit_details(params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/payments/details"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Get the brand and other details of a card based on partial card number.

  ## Required fields
  - `merchantAccount`
  - `cardNumber` — at least 6 digits
  """
  @spec get_card_details(map(), keyword()) :: Client.response()
  def get_card_details(params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/cardDetails"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
