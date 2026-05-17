defmodule AdyenClient.Management.PayoutSettings do
  @moduledoc """
  Management API — Payout Settings at merchant level.

  Manage payout destinations (bank accounts, e-wallets) for a merchant account.
  """

  alias AdyenClient.{Client, Config}

  @doc "Add a payout setting to a merchant account."
  @spec add(String.t(), map(), keyword()) :: Client.response()
  def add(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/payoutSettings",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a list of payout settings for a merchant account."
  @spec list(String.t(), keyword()) :: Client.response()
  def list(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/payoutSettings",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a specific payout setting."
  @spec get(String.t(), String.t(), keyword()) :: Client.response()
  def get(merchant_id, payout_settings_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/payoutSettings/#{payout_settings_id}"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update a payout setting."
  @spec update(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update(merchant_id, payout_settings_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/payoutSettings/#{payout_settings_id}"

    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Delete a payout setting."
  @spec delete(String.t(), String.t(), keyword()) :: Client.response()
  def delete(merchant_id, payout_settings_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/payoutSettings/#{payout_settings_id}"

    Client.delete(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.AllowedOrigins do
  @moduledoc """
  Management API — Allowed Origins at company and merchant credential level.

  Separate from `AdyenClient.Management.ApiCredentials`, these endpoints manage
  allowed origins scoped directly to a credential ID at both company and merchant level.
  """

  alias AdyenClient.{Client, Config}

  # ── My credential origins ────────────────────────────────────────────────

  @doc "Get a specific allowed origin for my own API credential."
  @spec get_my_origin(String.t(), keyword()) :: Client.response()
  def get_my_origin(origin_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/me/allowedOrigins/#{origin_id}",
      Keyword.put(opts, :config, config)
    )
  end

  # ── Company credential origins ────────────────────────────────────────────

  @doc "Get a specific allowed origin for a company-level credential."
  @spec get_company_origin(String.t(), String.t(), String.t(), keyword()) :: Client.response()
  def get_company_origin(company_id, credential_id, origin_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/apiCredentials/#{credential_id}/allowedOrigins/#{origin_id}"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  # ── Merchant credential origins ───────────────────────────────────────────

  @doc "Get a list of allowed origins for a merchant-level credential."
  @spec list_merchant_origins(String.t(), String.t(), keyword()) :: Client.response()
  def list_merchant_origins(merchant_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}/allowedOrigins"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Add an allowed origin to a merchant-level credential."
  @spec create_merchant_origin(String.t(), String.t(), map(), keyword()) :: Client.response()
  def create_merchant_origin(merchant_id, credential_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}/allowedOrigins"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get a specific allowed origin for a merchant-level credential."
  @spec get_merchant_origin(String.t(), String.t(), String.t(), keyword()) :: Client.response()
  def get_merchant_origin(merchant_id, credential_id, origin_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}/allowedOrigins/#{origin_id}"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Delete an allowed origin from a merchant-level credential."
  @spec delete_merchant_origin(String.t(), String.t(), String.t(), keyword()) :: Client.response()
  def delete_merchant_origin(merchant_id, credential_id, origin_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}/allowedOrigins/#{origin_id}"

    Client.delete(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.PosMobile do
  @moduledoc """
  POS Mobile / possdk API (v68) — deprecated.

  Creates a communication session for the legacy POS Mobile SDK.
  """

  alias AdyenClient.{Client, Config}

  @doc "Create a communication session for the POS Mobile SDK."
  @spec create_session(map(), keyword()) :: Client.response()
  def create_session(params, opts \\ []) do
    config = resolve_config(opts)

    base =
      if config.environment == :live,
        do: "https://checkout-live.adyen.com/possdk/v68",
        else: "https://checkout-test.adyen.com/possdk/v68"

    Client.post(base <> "/sessions", params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.TerminalManagement do
  @moduledoc """
  Terminal Management / postfmapi (v1) — deprecated.

  Assign terminals and look up terminal/store/account associations.
  For new integrations use `AdyenClient.Management.Terminals`.
  """

  alias AdyenClient.{Client, Config}

  @doc "Assign terminals to a merchant account or store."
  @spec assign(map(), keyword()) :: Client.response()
  def assign(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.postfm_url(config) <> "/assignTerminals",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get the merchant account or store a terminal is assigned to."
  @spec get_terminal_under(map(), keyword()) :: Client.response()
  def get_terminal_under(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.postfm_url(config) <> "/findTerminal",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get the stores of a merchant account."
  @spec get_stores(map(), keyword()) :: Client.response()
  def get_stores(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.postfm_url(config) <> "/getStoresUnderAccount",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get details of a terminal."
  @spec get_terminal(map(), keyword()) :: Client.response()
  def get_terminal(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.postfm_url(config) <> "/getTerminalDetails",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get the list of terminals under a merchant account or store."
  @spec list_terminals(map(), keyword()) :: Client.response()
  def list_terminals(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.postfm_url(config) <> "/getTerminalsUnderAccount",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
