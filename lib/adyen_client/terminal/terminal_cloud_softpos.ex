defmodule AdyenClient.Terminal do
  @moduledoc """
  Adyen Terminal API (NEXO-based, v1).

  Used for in-person POS payments. Supports both synchronous (cloud) and
  local (LAN) communication. For cloud communication prefer `AdyenClient.CloudDevice`.

  All requests follow the NEXO SaleToPOI envelope structure:
  `%{SaleToPOIRequest: %{MessageHeader: %{...}, <ServiceType>Request: %{...}}}`
  """

  alias AdyenClient.{Client, Config}

  @doc "Send a Login request to a terminal."
  @spec login(map(), keyword()) :: Client.response()
  def login(params, opts \\ []), do: terminal_request("login", params, opts)

  @doc "Send a Logout request."
  @spec logout(map(), keyword()) :: Client.response()
  def logout(params, opts \\ []), do: terminal_request("logout", params, opts)

  @doc "Send an EnableService request."
  @spec enable_service(map(), keyword()) :: Client.response()
  def enable_service(params, opts \\ []), do: terminal_request("enableservice", params, opts)

  @doc "Send an Admin request."
  @spec admin(map(), keyword()) :: Client.response()
  def admin(params, opts \\ []), do: terminal_request("admin", params, opts)

  @doc "Send a Payment request."
  @spec payment(map(), keyword()) :: Client.response()
  def payment(params, opts \\ []), do: terminal_request("payment", params, opts)

  @doc "Send a CardAcquisition request (read card without charging)."
  @spec card_acquisition(map(), keyword()) :: Client.response()
  def card_acquisition(params, opts \\ []), do: terminal_request("cardacquisition", params, opts)

  @doc "Send a StoredValue request (gift card operations)."
  @spec stored_value(map(), keyword()) :: Client.response()
  def stored_value(params, opts \\ []), do: terminal_request("storedvalue", params, opts)

  @doc "Send a Reversal request."
  @spec reversal(map(), keyword()) :: Client.response()
  def reversal(params, opts \\ []), do: terminal_request("reversal", params, opts)

  @doc "Send a Reconciliation request (end-of-day)."
  @spec reconciliation(map(), keyword()) :: Client.response()
  def reconciliation(params, opts \\ []), do: terminal_request("reconciliation", params, opts)

  @doc "Send a GetTotals request."
  @spec get_totals(map(), keyword()) :: Client.response()
  def get_totals(params, opts \\ []), do: terminal_request("gettotals", params, opts)

  @doc "Send a BalanceInquiry request."
  @spec balance_inquiry(map(), keyword()) :: Client.response()
  def balance_inquiry(params, opts \\ []), do: terminal_request("balanceinquiry", params, opts)

  @doc "Send a TransactionStatus request."
  @spec transaction_status(map(), keyword()) :: Client.response()
  def transaction_status(params, opts \\ []),
    do: terminal_request("transactionstatus", params, opts)

  @doc "Send an Abort request."
  @spec abort(map(), keyword()) :: Client.response()
  def abort(params, opts \\ []), do: terminal_request("abort", params, opts)

  @doc "Send a Diagnosis request."
  @spec diagnosis(map(), keyword()) :: Client.response()
  def diagnosis(params, opts \\ []), do: terminal_request("diagnosis", params, opts)

  @doc "Send a Display request."
  @spec display(map(), keyword()) :: Client.response()
  def display(params, opts \\ []), do: terminal_request("display", params, opts)

  @doc "Send an Input request."
  @spec input(map(), keyword()) :: Client.response()
  def input(params, opts \\ []), do: terminal_request("input", params, opts)

  @doc "Send a Print request."
  @spec print(map(), keyword()) :: Client.response()
  def print(params, opts \\ []), do: terminal_request("print", params, opts)

  @doc "Send a CardReaderAPDU request."
  @spec card_reader_apdu(map(), keyword()) :: Client.response()
  def card_reader_apdu(params, opts \\ []), do: terminal_request("cardreaderapdu", params, opts)

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp terminal_request(action, params, opts) do
    config = Keyword.get(opts, :config, Config.load!())
    url = Config.terminal_sync_url(config) <> "/async/#{action}"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end
end

defmodule AdyenClient.CloudDevice do
  @moduledoc """
  Adyen Cloud Device API (v1).

  REST wrapper to send Terminal API messages to cloud-connected terminals
  without needing direct network access to the terminal.
  """

  alias AdyenClient.{Client, Config}

  @doc "Send a Terminal API request and receive a synchronous response."
  @spec sync(String.t(), String.t(), map(), keyword()) :: Client.response()
  def sync(merchant_account, device_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.cloud_device_url(config) <>
        "/merchants/#{merchant_account}/devices/#{device_id}/sync"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Send a Terminal API request and receive an asynchronous response."
  @spec async(String.t(), String.t(), map(), keyword()) :: Client.response()
  def async(merchant_account, device_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.cloud_device_url(config) <>
        "/merchants/#{merchant_account}/devices/#{device_id}/async"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get the connection status of a device."
  @spec get_status(String.t(), String.t(), keyword()) :: Client.response()
  def get_status(merchant_account, device_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.cloud_device_url(config) <>
        "/merchants/#{merchant_account}/devices/#{device_id}/status"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Get a list of connected devices for a merchant account."
  @spec list_connected(String.t(), keyword()) :: Client.response()
  def list_connected(merchant_account, opts \\ []) do
    config = resolve_config(opts)
    url = Config.cloud_device_url(config) <> "/merchants/#{merchant_account}/connectedDevices"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.SoftPOS do
  @moduledoc "Adyen SoftPOS Configuration API (v3) — Tap to Pay on mobile."

  alias AdyenClient.{Client, Config}

  @doc "Create a communication session via certificate-based auth."
  @spec create_session(map(), keyword()) :: Client.response()
  def create_session(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.softpos_url(config) <> "/auth/certificate",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.PaymentsApp do
  @moduledoc "Adyen Payments App API (v1) — Android-based POS app management."

  alias AdyenClient.{Client, Config}

  @doc "Create a boarding token at merchant level."
  @spec create_boarding_token_merchant(String.t(), map(), keyword()) :: Client.response()
  def create_boarding_token_merchant(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.payments_app_url(config) <>
        "/merchants/#{merchant_id}/generatePaymentsAppBoardingToken"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Create a boarding token at store level."
  @spec create_boarding_token_store(String.t(), String.t(), map(), keyword()) :: Client.response()
  def create_boarding_token_store(merchant_id, store_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.payments_app_url(config) <>
        "/merchants/#{merchant_id}/stores/#{store_id}/generatePaymentsAppBoardingToken"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "List Payments App installations at merchant level."
  @spec list_merchant(String.t(), keyword()) :: Client.response()
  def list_merchant(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.payments_app_url(config) <> "/merchants/#{merchant_id}/paymentsApps",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List Payments App installations at store level."
  @spec list_store(String.t(), String.t(), keyword()) :: Client.response()
  def list_store(merchant_id, store_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.payments_app_url(config) <>
        "/merchants/#{merchant_id}/stores/#{store_id}/paymentsApps"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Revoke a Payments App installation's authentication."
  @spec revoke(String.t(), String.t(), keyword()) :: Client.response()
  def revoke(merchant_id, installation_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.payments_app_url(config) <>
        "/merchants/#{merchant_id}/paymentsApps/#{installation_id}/revoke"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
