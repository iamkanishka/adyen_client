defmodule AdyenClient.BalancePlatform.TransactionRules do
  @moduledoc """
  Balance Platform — Transaction Rules scoped to platform, account holder,
  balance account, and payment instrument.

  These are additional query endpoints beyond the create/get/update/delete
  already on `AdyenClient.BalancePlatform`.
  """

  alias AdyenClient.{Client, Config}

  @doc "Get all transaction rules for a balance platform."
  @spec list_for_platform(String.t(), keyword()) :: Client.response()
  def list_for_platform(platform_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <> "/balancePlatforms/#{platform_id}/transactionRules"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Get all transaction rules for an account holder."
  @spec list_for_account_holder(String.t(), keyword()) :: Client.response()
  def list_for_account_holder(holder_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/accountHolders/#{holder_id}/transactionRules"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Get all transaction rules for a balance account."
  @spec list_for_balance_account(String.t(), keyword()) :: Client.response()
  def list_for_balance_account(account_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/transactionRules"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Get all transaction rules for a payment instrument."
  @spec list_for_payment_instrument(String.t(), keyword()) :: Client.response()
  def list_for_payment_instrument(instrument_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/paymentInstruments/#{instrument_id}/transactionRules"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Get all transaction rules for a payment instrument group."
  @spec list_for_payment_instrument_group(String.t(), keyword()) :: Client.response()
  def list_for_payment_instrument_group(group_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/paymentInstrumentGroups/#{group_id}/transactionRules"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalancePlatform.WebhookSettings do
  @moduledoc """
  Balance Platform — Balance Webhook Settings.

  Configure per-balance-account webhook URLs to receive `balancePlatform.balanceAccount.balance.updated`
  and related balance events.
  """

  alias AdyenClient.{Client, Config}

  @doc "Create a balance webhook setting for a balance account."
  @spec create(String.t(), map(), keyword()) :: Client.response()
  def create(account_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/balanceWebhooks"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get all balance webhook settings for a balance account."
  @spec list(String.t(), keyword()) :: Client.response()
  def list(account_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/balanceWebhooks"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Get a specific balance webhook setting."
  @spec get(String.t(), String.t(), keyword()) :: Client.response()
  def get(account_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/balanceAccounts/#{account_id}/balanceWebhooks/#{webhook_id}"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update a balance webhook setting."
  @spec update(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update(account_id, webhook_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/balanceAccounts/#{account_id}/balanceWebhooks/#{webhook_id}"

    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Delete a balance webhook setting."
  @spec delete(String.t(), String.t(), keyword()) :: Client.response()
  def delete(account_id, webhook_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/balanceAccounts/#{account_id}/balanceWebhooks/#{webhook_id}"

    Client.delete(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalancePlatform.PaymentInstrumentGroups do
  @moduledoc """
  Balance Platform — Payment Instrument Groups.

  Group payment instruments under a shared set of transaction rules.
  """

  alias AdyenClient.{Client, Config}

  @doc "Create a payment instrument group."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/paymentInstrumentGroups",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a payment instrument group."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(group_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/paymentInstrumentGroups/#{group_id}",
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalancePlatform.AccountHolders do
  @moduledoc """
  Balance Platform — Additional Account Holder endpoints.

  Supplements `AdyenClient.BalancePlatform` with tax form summary and
  transaction rule listing for account holders.
  """

  alias AdyenClient.{Client, Config}

  @doc "Get a summary of tax forms for an account holder."
  @spec get_tax_form_summary(String.t(), map(), keyword()) :: Client.response()
  def get_tax_form_summary(holder_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/accountHolders/#{holder_id}/taxFormSummary"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalancePlatform.SCADevices do
  @moduledoc """
  Balance Platform — SCA Device Management (scaDevices endpoint set).

  The `scaDevices` endpoints are the first registration step (begin/finish + association).
  See also `AdyenClient.BalancePlatform` for the `registeredDevices` endpoint set.
  """

  alias AdyenClient.{Client, Config}

  @doc "Begin SCA device registration (scaDevices)."
  @spec begin_registration(map(), keyword()) :: Client.response()
  def begin_registration(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/scaDevices",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Finish registration process for an SCA device."
  @spec finish_registration(String.t(), map(), keyword()) :: Client.response()
  def finish_registration(device_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/scaDevices/#{device_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a new SCA association for a device."
  @spec create_association(String.t(), map(), keyword()) :: Client.response()
  def create_association(device_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/scaDevices/#{device_id}/associations"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalancePlatform.SCAAssociations do
  @moduledoc """
  Balance Platform — SCA Association Management.

  Manage the relationships between SCA devices and Balance Platform resources
  (balance accounts, payment instruments, etc.).
  """

  alias AdyenClient.{Client, Config}

  @doc "Get a list of SCA devices associated with an entity."
  @spec list_for_entity(String.t(), map(), keyword()) :: Client.response()
  def list_for_entity(entity_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/entities/#{entity_id}/scaDevices"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Delete association between SCA devices and an entity."
  @spec delete_for_entity(String.t(), keyword()) :: Client.response()
  def delete_for_entity(entity_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/entities/#{entity_id}/scaDevices"
    Client.delete(url, Keyword.put(opts, :config, config))
  end

  @doc "Approve a pending SCA association."
  @spec approve_pending(String.t(), String.t(), map(), keyword()) :: Client.response()
  def approve_pending(entity_id, device_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/entities/#{entity_id}/scaDevices/#{device_id}/approve"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalancePlatform.TransferLimits do
  @moduledoc """
  Balance Platform — Transfer Limits at both balance account and balance platform level.

  Supplements `AdyenClient.BalancePlatform` with the full set of transfer limit
  operations including approve-pending and platform-level CRUD.
  """

  alias AdyenClient.{Client, Config}

  # ── Balance Account Level ──────────────────────────────────────────────────

  @doc "Approve pending transfer limits for a balance account."
  @spec approve_balance_account_limits(String.t(), map(), keyword()) :: Client.response()
  def approve_balance_account_limits(account_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/balanceAccounts/#{account_id}/transferLimits/approve"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get a specific transfer limit for a balance account."
  @spec get_balance_account_limit(String.t(), String.t(), keyword()) :: Client.response()
  def get_balance_account_limit(account_id, limit_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/balanceAccounts/#{account_id}/transferLimits/#{limit_id}"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  # ── Balance Platform Level ─────────────────────────────────────────────────

  @doc "Create a transfer limit at balance platform level."
  @spec create_platform_limit(String.t(), map(), keyword()) :: Client.response()
  def create_platform_limit(platform_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/balancePlatforms/#{platform_id}/transferLimits"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "List transfer limits at balance platform level."
  @spec list_platform_limits(String.t(), map(), keyword()) :: Client.response()
  def list_platform_limits(platform_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/balancePlatforms/#{platform_id}/transferLimits"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Get a specific transfer limit at balance platform level."
  @spec get_platform_limit(String.t(), String.t(), keyword()) :: Client.response()
  def get_platform_limit(platform_id, limit_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/balancePlatforms/#{platform_id}/transferLimits/#{limit_id}"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Delete a transfer limit at balance platform level."
  @spec delete_platform_limit(String.t(), String.t(), keyword()) :: Client.response()
  def delete_platform_limit(platform_id, limit_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.balance_platform_url(config) <>
        "/balancePlatforms/#{platform_id}/transferLimits/#{limit_id}"

    Client.delete(url, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
