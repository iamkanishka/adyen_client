defmodule AdyenClient.BinLookup do
  @moduledoc """
  Adyen BinLookup API (v54).

  Retrieve 3D Secure availability and interchange/scheme fee estimates
  based on a card BIN (first 6–11 digits).
  """

  alias AdyenClient.{Client, Config}

  @doc """
  Check if 3D Secure is available for a BIN.

  ## Required fields
  - `merchantAccount`
  - `cardNumber` — at least 6 digits
  - `amount`
  """
  @spec get_3ds_availability(map(), keyword()) :: Client.response()
  def get_3ds_availability(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.bin_lookup_url(config) <> "/get3dsAvailability",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc """
  Get a cost estimate (interchange + scheme fees) for a transaction.

  ## Required fields
  - `merchantAccount`
  - `amount`
  - `assumptions` — `%{assumeLevel3Data: true, assume3DS: true}`
  - `cardNumber` or `additionalData.cardBin`
  """
  @spec get_cost_estimate(map(), keyword()) :: Client.response()
  def get_cost_estimate(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.bin_lookup_url(config) <> "/getCostEstimate",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Disputes do
  @moduledoc """
  Adyen Disputes API (v30) — defend chargebacks on the merchant side.
  """

  alias AdyenClient.{Client, Config}

  @doc "Accept a dispute (waive defense)."
  @spec accept(map(), keyword()) :: Client.response()
  def accept(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.disputes_url(config) <> "/acceptDispute",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Defend a dispute with previously uploaded documents."
  @spec defend(map(), keyword()) :: Client.response()
  def defend(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.disputes_url(config) <> "/defendDispute",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a defense document."
  @spec delete_defense_document(map(), keyword()) :: Client.response()
  def delete_defense_document(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.disputes_url(config) <> "/deleteDisputeDefenseDocument",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Retrieve applicable defense reasons for a dispute."
  @spec get_applicable_defense_reasons(map(), keyword()) :: Client.response()
  def get_applicable_defense_reasons(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.disputes_url(config) <> "/retrieveApplicableDefenseReasons",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Supply a defense document for a dispute."
  @spec supply_defense_document(map(), keyword()) :: Client.response()
  def supply_defense_document(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.disputes_url(config) <> "/supplyDefenseDocument",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Recurring do
  @moduledoc """
  Adyen Recurring API (v68).

  Manage stored payment contracts, permits, and schedule Account Updater.
  Note: For new integrations prefer `AdyenClient.Checkout.Recurring`.
  """

  alias AdyenClient.{Client, Config}

  @doc "Create new permits linked to a recurring contract."
  @spec create_permit(map(), keyword()) :: Client.response()
  def create_permit(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.recurring_url(config) <> "/createPermit",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Disable stored payment details."
  @spec disable(map(), keyword()) :: Client.response()
  def disable(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.recurring_url(config) <> "/disable",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Disable an existing permit."
  @spec disable_permit(map(), keyword()) :: Client.response()
  def disable_permit(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.recurring_url(config) <> "/disablePermit",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List stored payment details for a shopper."
  @spec list_details(map(), keyword()) :: Client.response()
  def list_details(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.recurring_url(config) <> "/listRecurringDetails",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Ask the issuer to notify the shopper about a recurring contract."
  @spec notify_shopper(map(), keyword()) :: Client.response()
  def notify_shopper(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.recurring_url(config) <> "/notifyShopper",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Schedule running the Account Updater for a shopper's stored details."
  @spec schedule_account_updater(map(), keyword()) :: Client.response()
  def schedule_account_updater(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.recurring_url(config) <> "/scheduleAccountUpdater",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Payout do
  @moduledoc """
  Adyen Payout API (v68) — deprecated in favour of Transfers API.

  Supports third-party payouts and instant card payouts.
  """

  alias AdyenClient.{Client, Config}

  @doc "Store details and submit a third-party payout in one call."
  @spec store_detail_and_submit(map(), keyword()) :: Client.response()
  def store_detail_and_submit(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payout_url(config) <> "/storeDetailAndSubmitThirdParty",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Store payout details without submitting."
  @spec store_detail(map(), keyword()) :: Client.response()
  def store_detail(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payout_url(config) <> "/storeDetail",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Submit a previously stored payout."
  @spec submit(map(), keyword()) :: Client.response()
  def submit(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payout_url(config) <> "/submitThirdParty",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Confirm a pending payout."
  @spec confirm(map(), keyword()) :: Client.response()
  def confirm(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payout_url(config) <> "/confirmThirdParty",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Decline / cancel a pending payout."
  @spec decline(map(), keyword()) :: Client.response()
  def decline(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payout_url(config) <> "/declineThirdParty",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Make an instant card payout."
  @spec instant_payout(map(), keyword()) :: Client.response()
  def instant_payout(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payout_url(config) <> "/payout",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
