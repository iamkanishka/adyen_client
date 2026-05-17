defmodule AdyenClient.Management.Webhooks do
  @moduledoc "Management API — Webhook configuration (company and merchant level)."

  alias AdyenClient.{Client, Config}

  # Company-level
  @doc "Set up a webhook at company level."
  @spec create_company(String.t(), map(), keyword()) :: Client.response()
  def create_company(company_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/companies/#{company_id}/webhooks",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all webhooks at company level."
  @spec list_company(String.t(), keyword()) :: Client.response()
  def list_company(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/webhooks",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a company-level webhook."
  @spec get_company(String.t(), String.t(), keyword()) :: Client.response()
  def get_company(company_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/webhooks/#{webhook_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a company-level webhook."
  @spec update_company(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_company(company_id, webhook_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/companies/#{company_id}/webhooks/#{webhook_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Remove a company-level webhook."
  @spec delete_company(String.t(), String.t(), keyword()) :: Client.response()
  def delete_company(company_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.management_url(config) <> "/companies/#{company_id}/webhooks/#{webhook_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Generate an HMAC key for a company-level webhook."
  @spec generate_company_hmac(String.t(), String.t(), keyword()) :: Client.response()
  def generate_company_hmac(company_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/webhooks/#{webhook_id}/generateHmac"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  @doc "Test a company-level webhook."
  @spec test_company(String.t(), String.t(), map(), keyword()) :: Client.response()
  def test_company(company_id, webhook_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/webhooks/#{webhook_id}/test"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  # Merchant-level
  @doc "Set up a webhook at merchant level."
  @spec create_merchant(String.t(), map(), keyword()) :: Client.response()
  def create_merchant(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/webhooks",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all webhooks at merchant level."
  @spec list_merchant(String.t(), keyword()) :: Client.response()
  def list_merchant(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/webhooks",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a merchant-level webhook."
  @spec get_merchant(String.t(), String.t(), keyword()) :: Client.response()
  def get_merchant(merchant_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/webhooks/#{webhook_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a merchant-level webhook."
  @spec update_merchant(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_merchant(merchant_id, webhook_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/merchants/#{merchant_id}/webhooks/#{webhook_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Remove a merchant-level webhook."
  @spec delete_merchant(String.t(), String.t(), keyword()) :: Client.response()
  def delete_merchant(merchant_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.management_url(config) <> "/merchants/#{merchant_id}/webhooks/#{webhook_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Generate an HMAC key for a merchant-level webhook."
  @spec generate_merchant_hmac(String.t(), String.t(), keyword()) :: Client.response()
  def generate_merchant_hmac(merchant_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/webhooks/#{webhook_id}/generateHmac"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  @doc "Test a merchant-level webhook."
  @spec test_merchant(String.t(), String.t(), map(), keyword()) :: Client.response()
  def test_merchant(merchant_id, webhook_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/webhooks/#{webhook_id}/test"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.PaymentMethods do
  @moduledoc "Management API — Payment method settings."

  alias AdyenClient.{Client, Config}

  @doc "Request a new payment method for a merchant."
  @spec request(String.t(), map(), keyword()) :: Client.response()
  def request(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/paymentMethodSettings",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get all payment methods configured for a merchant."
  @spec list(String.t(), keyword()) :: Client.response()
  def list(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/paymentMethodSettings",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get details of a specific payment method."
  @spec get(String.t(), String.t(), keyword()) :: Client.response()
  def get(merchant_id, payment_method_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/paymentMethodSettings/#{payment_method_id}"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update a payment method configuration."
  @spec update(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update(merchant_id, payment_method_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/paymentMethodSettings/#{payment_method_id}"

    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Add an Apple Pay domain to a payment method."
  @spec add_apple_pay_domain(String.t(), String.t(), map(), keyword()) :: Client.response()
  def add_apple_pay_domain(merchant_id, payment_method_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/paymentMethodSettings/#{payment_method_id}/addApplePayDomains"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get Apple Pay domains for a payment method."
  @spec get_apple_pay_domains(String.t(), String.t(), keyword()) :: Client.response()
  def get_apple_pay_domains(merchant_id, payment_method_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/paymentMethodSettings/#{payment_method_id}/getApplePayDomains"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.Terminals do
  @moduledoc "Management API — Terminal management."

  alias AdyenClient.{Client, Config}

  @doc "Get a list of all terminals."
  @spec list(map(), keyword()) :: Client.response()
  def list(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/terminals",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Reassign a terminal to a store or inventory."
  @spec reassign(String.t(), map(), keyword()) :: Client.response()
  def reassign(terminal_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/terminals/#{terminal_id}/reassign",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List terminal actions at company level."
  @spec list_company_actions(String.t(), map(), keyword()) :: Client.response()
  def list_company_actions(company_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalActions"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Get a specific terminal action."
  @spec get_company_action(String.t(), String.t(), keyword()) :: Client.response()
  def get_company_action(company_id, action_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalActions/#{action_id}"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Schedule terminal actions across terminals."
  @spec schedule_action(map(), keyword()) :: Client.response()
  def schedule_action(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/terminals/scheduleActions",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.TerminalOrders do
  @moduledoc "Management API — Terminal hardware ordering."

  alias AdyenClient.{Client, Config}

  @doc "List terminal models at company level."
  @spec list_models_company(String.t(), keyword()) :: Client.response()
  def list_models_company(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/terminalModels",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List terminal products at company level."
  @spec list_products_company(String.t(), map(), keyword()) :: Client.response()
  def list_products_company(company_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalProducts"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "List billing entities at company level."
  @spec list_billing_entities_company(String.t(), keyword()) :: Client.response()
  def list_billing_entities_company(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/billingEntities",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List shipping locations at company level."
  @spec list_shipping_locations_company(String.t(), keyword()) :: Client.response()
  def list_shipping_locations_company(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/shippingLocations",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a shipping location at company level."
  @spec create_shipping_location_company(String.t(), map(), keyword()) :: Client.response()
  def create_shipping_location_company(company_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/companies/#{company_id}/shippingLocations",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a terminal order at company level."
  @spec create_company(String.t(), map(), keyword()) :: Client.response()
  def create_company(company_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/companies/#{company_id}/terminalOrders",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List terminal orders at company level."
  @spec list_company(String.t(), map(), keyword()) :: Client.response()
  def list_company(company_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalOrders"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Get a terminal order at company level."
  @spec get_company(String.t(), String.t(), keyword()) :: Client.response()
  def get_company(company_id, order_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/terminalOrders/#{order_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a terminal order at company level."
  @spec update_company(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_company(company_id, order_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/companies/#{company_id}/terminalOrders/#{order_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel a terminal order at company level."
  @spec cancel_company(String.t(), String.t(), keyword()) :: Client.response()
  def cancel_company(company_id, order_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/terminalOrders/#{order_id}/cancel"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  # Merchant-level mirrors
  @doc "List terminal models at merchant level."
  @spec list_models_merchant(String.t(), keyword()) :: Client.response()
  def list_models_merchant(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/terminalModels",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List terminal products at merchant level."
  @spec list_products_merchant(String.t(), map(), keyword()) :: Client.response()
  def list_products_merchant(merchant_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/terminalProducts"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Create a terminal order at merchant level."
  @spec create_merchant(String.t(), map(), keyword()) :: Client.response()
  def create_merchant(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/terminalOrders",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List terminal orders at merchant level."
  @spec list_merchant(String.t(), map(), keyword()) :: Client.response()
  def list_merchant(merchant_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/terminalOrders"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Get a terminal order at merchant level."
  @spec get_merchant(String.t(), String.t(), keyword()) :: Client.response()
  def get_merchant(merchant_id, order_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/terminalOrders/#{order_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a terminal order at merchant level."
  @spec update_merchant(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_merchant(merchant_id, order_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/merchants/#{merchant_id}/terminalOrders/#{order_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel a terminal order at merchant level."
  @spec cancel_merchant(String.t(), String.t(), keyword()) :: Client.response()
  def cancel_merchant(merchant_id, order_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/terminalOrders/#{order_id}/cancel"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.TerminalSettings do
  @moduledoc "Management API — Terminal settings and logos at all hierarchy levels."

  alias AdyenClient.{Client, Config}

  # ── Company level ─────────────────────────────────────────────────────────

  @doc "Get terminal settings at company level."
  @spec get_company_settings(String.t(), keyword()) ::
          {:ok, map()} | {:error, AdyenClient.Error.t()}
  def get_company_settings(company_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalSettings"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update terminal settings at company level."
  @spec update_company_settings(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, AdyenClient.Error.t()}
  def update_company_settings(company_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalSettings"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get terminal logo at company level."
  @spec get_company_logo(String.t(), keyword()) :: {:ok, map()} | {:error, AdyenClient.Error.t()}
  def get_company_logo(company_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalLogos"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update terminal logo at company level."
  @spec update_company_logo(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, AdyenClient.Error.t()}
  def update_company_logo(company_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/terminalLogos"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  # ── Merchant level ─────────────────────────────────────────────────────────

  @doc "Get terminal settings at merchant level."
  @spec get_merchant_settings(String.t(), keyword()) ::
          {:ok, map()} | {:error, AdyenClient.Error.t()}
  def get_merchant_settings(merchant_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/terminalSettings"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update terminal settings at merchant level."
  @spec update_merchant_settings(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, AdyenClient.Error.t()}
  def update_merchant_settings(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/terminalSettings"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get terminal logo at merchant level."
  @spec get_merchant_logo(String.t(), keyword()) :: {:ok, map()} | {:error, AdyenClient.Error.t()}
  def get_merchant_logo(merchant_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/terminalLogos"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update terminal logo at merchant level."
  @spec update_merchant_logo(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, AdyenClient.Error.t()}
  def update_merchant_logo(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/terminalLogos"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get terminal settings at store level."
  @spec get_store_settings(String.t(), String.t(), keyword()) :: Client.response()
  def get_store_settings(merchant_id, store_ref, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/stores/#{store_ref}/terminalSettings"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update terminal settings at store level."
  @spec update_store_settings(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_store_settings(merchant_id, store_ref, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/stores/#{store_ref}/terminalSettings"

    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  # Store-level logo (merchant_id + store_ref path)
  @doc "Get the terminal logo at store level (merchant + store ref path)."
  @spec get_store_logo(String.t(), String.t(), keyword()) :: Client.response()
  def get_store_logo(merchant_id, store_ref, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/stores/#{store_ref}/terminalLogos"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update the terminal logo at store level (merchant + store ref path)."
  @spec update_store_logo(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_store_logo(merchant_id, store_ref, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/stores/#{store_ref}/terminalLogos"

    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  # Store-level settings / logo via store ID only (store_id variant paths)
  @doc "Get terminal settings at store level by store ID only."
  @spec get_store_settings_by_id(String.t(), map(), keyword()) :: Client.response()
  def get_store_settings_by_id(store_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/stores/#{store_id}/terminalSettings"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Update terminal settings at store level by store ID only."
  @spec update_store_settings_by_id(String.t(), map(), keyword()) :: Client.response()
  def update_store_settings_by_id(store_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/stores/#{store_id}/terminalSettings"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get the terminal logo at store level by store ID only."
  @spec get_store_logo_by_id(String.t(), map(), keyword()) :: Client.response()
  def get_store_logo_by_id(store_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/stores/#{store_id}/terminalLogos"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Update the terminal logo at store level by store ID only."
  @spec update_store_logo_by_id(String.t(), map(), keyword()) :: Client.response()
  def update_store_logo_by_id(store_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/stores/#{store_id}/terminalLogos"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  # Terminal-level settings
  @doc "Get terminal settings at terminal level."
  @spec get_terminal_settings(String.t(), keyword()) :: Client.response()
  def get_terminal_settings(terminal_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/terminals/#{terminal_id}/terminalSettings",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update terminal settings at terminal level."
  @spec update_terminal_settings(String.t(), map(), keyword()) :: Client.response()
  def update_terminal_settings(terminal_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/terminals/#{terminal_id}/terminalSettings",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Terminal-level logo
  @doc "Get the terminal logo at terminal level."
  @spec get_terminal_logo(String.t(), map(), keyword()) :: Client.response()
  def get_terminal_logo(terminal_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/terminals/#{terminal_id}/terminalLogos"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Update the terminal logo at terminal level."
  @spec update_terminal_logo(String.t(), map(), keyword()) :: Client.response()
  def update_terminal_logo(terminal_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/terminals/#{terminal_id}/terminalLogos"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.AndroidFiles do
  @moduledoc "Management API — Android app/certificate management for terminals."

  alias AdyenClient.{Client, Config}

  @doc "List Android apps at company level."
  @spec list_apps(String.t(), keyword()) :: Client.response()
  def list_apps(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/androidApps",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a specific Android app."
  @spec get_app(String.t(), String.t(), keyword()) :: Client.response()
  def get_app(company_id, app_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/androidApps/#{app_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Upload an Android app."
  @spec upload_app(String.t(), map(), keyword()) :: Client.response()
  def upload_app(company_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/companies/#{company_id}/androidApps",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Reprocess (re-sign) an Android app."
  @spec reprocess_app(String.t(), String.t(), map(), keyword()) :: Client.response()
  def reprocess_app(company_id, app_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/companies/#{company_id}/androidApps/#{app_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List Android certificates."
  @spec list_certificates(String.t(), keyword()) :: Client.response()
  def list_certificates(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/androidCertificates",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Upload an Android certificate."
  @spec upload_certificate(String.t(), map(), keyword()) :: Client.response()
  def upload_certificate(company_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/companies/#{company_id}/androidCertificates",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.SplitConfigurations do
  @moduledoc "Management API — Split configuration profiles for marketplaces."

  alias AdyenClient.{Client, Config}

  @doc "Create a split configuration profile."
  @spec create(String.t(), map(), keyword()) :: Client.response()
  def create(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/splitConfigurations",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all split configuration profiles."
  @spec list(String.t(), keyword()) :: Client.response()
  def list(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/splitConfigurations",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a split configuration profile."
  @spec get(String.t(), String.t(), keyword()) :: Client.response()
  def get(merchant_id, config_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/splitConfigurations/#{config_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update the description of a split configuration profile."
  @spec update(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update(merchant_id, config_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/splitConfigurations/#{config_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a split configuration profile."
  @spec delete(String.t(), String.t(), keyword()) :: Client.response()
  def delete(merchant_id, config_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/splitConfigurations/#{config_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a rule within a split configuration."
  @spec create_rule(String.t(), String.t(), map(), keyword()) :: Client.response()
  def create_rule(merchant_id, config_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/splitConfigurations/#{config_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update split conditions for a rule."
  @spec update_rule(String.t(), String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_rule(merchant_id, config_id, rule_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/splitConfigurations/#{config_id}/rules/#{rule_id}"

    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Update split logic for a rule."
  @spec update_split_logic(String.t(), String.t(), String.t(), String.t(), map(), keyword()) ::
          Client.response()
  def update_split_logic(merchant_id, config_id, rule_id, logic_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/splitConfigurations/#{config_id}/rules/#{rule_id}/splitLogic/#{logic_id}"

    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Delete a rule from a split configuration."
  @spec delete_rule(String.t(), String.t(), String.t(), keyword()) :: Client.response()
  def delete_rule(merchant_id, config_id, rule_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/splitConfigurations/#{config_id}/rules/#{rule_id}"

    Client.delete(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalanceControl do
  @moduledoc "Adyen Balance Control API (v2) — balance overviews and transfers."

  alias AdyenClient.{Client, Config}

  @doc "View balances for all merchants under a company."
  @spec company_balances(String.t(), keyword()) :: Client.response()
  def company_balances(company_code, opts \\ []) do
    config = resolve_config(opts)

    base =
      if config.environment == :live,
        do: "https://balancecontrol-live.adyen.com/v2",
        else: "https://balancecontrol-test.adyen.com/v2"

    Client.get(
      base <> "/balanceOverview/companies/#{company_code}/balances",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "View all balances for a merchant account."
  @spec merchant_balances(String.t(), keyword()) :: Client.response()
  def merchant_balances(merchant_code, opts \\ []) do
    config = resolve_config(opts)

    base =
      if config.environment == :live,
        do: "https://balancecontrol-live.adyen.com/v2",
        else: "https://balancecontrol-test.adyen.com/v2"

    Client.get(
      base <> "/balanceOverview/merchants/#{merchant_code}/balances",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Perform a balance transfer between merchant accounts."
  @spec transfer(map(), keyword()) :: Client.response()
  def transfer(params, opts \\ []) do
    config = resolve_config(opts)

    base =
      if config.environment == :live,
        do: "https://balancecontrol-live.adyen.com/v2",
        else: "https://balancecontrol-test.adyen.com/v2"

    Client.post(base <> "/balanceTransfers", params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
