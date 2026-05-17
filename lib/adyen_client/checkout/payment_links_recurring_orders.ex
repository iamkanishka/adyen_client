defmodule AdyenClient.Checkout.PaymentLinks do
  @moduledoc "Adyen Checkout Payment Links API."

  alias AdyenClient.{Client, Config}

  @doc "Create a payment link."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/paymentLinks",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a payment link by ID."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(link_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.checkout_url(config) <> "/paymentLinks/#{link_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update the status of a payment link (e.g. expire it)."
  @spec update(String.t(), map(), keyword()) :: Client.response()
  def update(link_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.checkout_url(config) <> "/paymentLinks/#{link_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Checkout.Recurring do
  @moduledoc "Adyen Checkout Recurring / Token Management."

  alias AdyenClient.{Client, Config}

  @doc "Forward stored payment details for a new transaction."
  @spec forward(map(), keyword()) :: Client.response()
  def forward(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/forward",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get all stored payment tokens for a shopper."
  @spec list_tokens(map(), keyword()) :: Client.response()
  def list_tokens(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.checkout_url(config) <> "/storedPaymentMethods",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Create a token to store payment details."
  @spec create_token(map(), keyword()) :: Client.response()
  def create_token(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/storedPaymentMethods",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a stored payment token."
  @spec delete_token(String.t(), keyword()) :: Client.response()
  def delete_token(stored_payment_method_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.checkout_url(config) <> "/storedPaymentMethods/#{stored_payment_method_id}",
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Checkout.Orders do
  @moduledoc "Adyen Checkout Orders (partial payments / gift cards)."

  alias AdyenClient.{Client, Config}

  @doc "Get the balance of a gift card."
  @spec get_balance(map(), keyword()) :: Client.response()
  def get_balance(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/paymentMethods/balance",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a partial-payment order."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/orders",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel a partial-payment order."
  @spec cancel(map(), keyword()) :: Client.response()
  def cancel(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/orders/cancel",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Checkout.Donations do
  @moduledoc "Adyen Checkout Donations API."

  alias AdyenClient.{Client, Config}

  @doc "List donation campaigns."
  @spec list_campaigns(map(), keyword()) :: Client.response()
  def list_campaigns(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/donationCampaigns",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Make a donation."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/donations",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Checkout.Utility do
  @moduledoc "Adyen Checkout Utility endpoints."

  alias AdyenClient.{Client, Config}

  @doc "Create originKey values for domains."
  @spec create_origin_keys(map(), keyword()) :: Client.response()
  def create_origin_keys(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/originKeys",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get an Apple Pay session."
  @spec get_apple_pay_session(map(), keyword()) :: Client.response()
  def get_apple_pay_session(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/applePay/sessions",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update order for PayPal Express Checkout."
  @spec update_paypal_order(map(), keyword()) :: Client.response()
  def update_paypal_order(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/paypal/updateOrder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Validate shopper ID (Riverty / AfterPay)."
  @spec validate_shopper_id(map(), keyword()) :: Client.response()
  def validate_shopper_id(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.checkout_url(config) <> "/validateShopperId",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
