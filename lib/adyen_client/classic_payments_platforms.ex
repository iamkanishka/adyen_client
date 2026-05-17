defmodule AdyenClient.ClassicPayments do
  @moduledoc """
  Adyen Classic Payments API (v68).

  The original payment integration — use `AdyenClient.Checkout` for new integrations.
  """

  alias AdyenClient.{Client, Config}

  @doc "Create an authorisation."
  @spec authorise(map(), keyword()) :: Client.response()
  def authorise(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/authorise",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Complete a 3DS authorisation."
  @spec authorise_3d(map(), keyword()) :: Client.response()
  def authorise_3d(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/authorise3d",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Complete a 3DS2 authorisation."
  @spec authorise_3ds2(map(), keyword()) :: Client.response()
  def authorise_3ds2(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/authorise3ds2",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get the 3DS authentication result."
  @spec get_authentication_result(map(), keyword()) :: Client.response()
  def get_authentication_result(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/getAuthenticationResult",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get the 3DS2 authentication result."
  @spec retrieve_3ds2_result(map(), keyword()) :: Client.response()
  def retrieve_3ds2_result(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/retrieve3ds2Result",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Capture an authorisation."
  @spec capture(map(), keyword()) :: Client.response()
  def capture(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/capture",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel an authorisation."
  @spec cancel(map(), keyword()) :: Client.response()
  def cancel(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/cancel",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Refund a captured payment."
  @spec refund(map(), keyword()) :: Client.response()
  def refund(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/refund",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel or refund a payment."
  @spec cancel_or_refund(map(), keyword()) :: Client.response()
  def cancel_or_refund(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/cancelOrRefund",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel an authorisation using your own reference."
  @spec technical_cancel(map(), keyword()) :: Client.response()
  def technical_cancel(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/technicalCancel",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Adjust the authorised amount."
  @spec adjust_authorisation(map(), keyword()) :: Client.response()
  def adjust_authorisation(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/adjustAuthorisation",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a donation."
  @spec donate(map(), keyword()) :: Client.response()
  def donate(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/donate",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel an in-person refund."
  @spec void_pending_refund(map(), keyword()) :: Client.response()
  def void_pending_refund(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.payment_url(config) <> "/voidPendingRefund",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.ClassicPlatforms.Account do
  @moduledoc "Adyen Classic Platforms Account API (v6)."

  alias AdyenClient.{Client, Config}

  @doc "Create an account holder."
  @spec create_account_holder(map(), keyword()) :: Client.response()
  def create_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/createAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get an account holder."
  @spec get_account_holder(map(), keyword()) :: Client.response()
  def get_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/getAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update an account holder."
  @spec update_account_holder(map(), keyword()) :: Client.response()
  def update_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/updateAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update payout or processing state."
  @spec update_account_holder_state(map(), keyword()) :: Client.response()
  def update_account_holder_state(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/updateAccountHolderState",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Suspend an account holder."
  @spec suspend_account_holder(map(), keyword()) :: Client.response()
  def suspend_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/suspendAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Unsuspend an account holder."
  @spec unsuspend_account_holder(map(), keyword()) :: Client.response()
  def unsuspend_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/unSuspendAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Close an account holder."
  @spec close_account_holder(map(), keyword()) :: Client.response()
  def close_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/closeAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a tax form for an account holder."
  @spec get_tax_form(map(), keyword()) :: Client.response()
  def get_tax_form(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/getTaxForm",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Close stores."
  @spec close_stores(map(), keyword()) :: Client.response()
  def close_stores(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/closeStores",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a sub-account."
  @spec create_account(map(), keyword()) :: Client.response()
  def create_account(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/createAccount",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a sub-account."
  @spec update_account(map(), keyword()) :: Client.response()
  def update_account(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/updateAccount",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Close a sub-account."
  @spec close_account(map(), keyword()) :: Client.response()
  def close_account(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/closeAccount",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Upload a verification document."
  @spec upload_document(map(), keyword()) :: Client.response()
  def upload_document(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/uploadDocument",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get uploaded documents."
  @spec get_uploaded_documents(map(), keyword()) :: Client.response()
  def get_uploaded_documents(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/getUploadedDocuments",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Trigger KYC verification check."
  @spec check_account_holder(map(), keyword()) :: Client.response()
  def check_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/checkAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete bank accounts."
  @spec delete_bank_accounts(map(), keyword()) :: Client.response()
  def delete_bank_accounts(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/deleteBankAccounts",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete payout methods."
  @spec delete_payout_methods(map(), keyword()) :: Client.response()
  def delete_payout_methods(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/deletePayoutMethods",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete legal arrangements."
  @spec delete_legal_arrangements(map(), keyword()) :: Client.response()
  def delete_legal_arrangements(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/deleteLegalArrangements",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete shareholders."
  @spec delete_shareholders(map(), keyword()) :: Client.response()
  def delete_shareholders(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/deleteShareholders",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete signatories."
  @spec delete_signatories(map(), keyword()) :: Client.response()
  def delete_signatories(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_account_url(config) <> "/deleteSignatories",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.ClassicPlatforms.Fund do
  @moduledoc "Adyen Classic Platforms Fund API (v6)."

  alias AdyenClient.{Client, Config}

  @doc "Get the balances of an account holder."
  @spec account_holder_balance(map(), keyword()) :: Client.response()
  def account_holder_balance(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/accountHolderBalance",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a list of transactions for an account holder."
  @spec transaction_list(map(), keyword()) :: Client.response()
  def transaction_list(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/accountHolderTransactionList",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Pay out funds from an account to the account holder."
  @spec payout_account_holder(map(), keyword()) :: Client.response()
  def payout_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/payoutAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Transfer funds between platform accounts."
  @spec transfer_funds(map(), keyword()) :: Client.response()
  def transfer_funds(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/transferFunds",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Refund a funds transfer."
  @spec refund_funds_transfer(map(), keyword()) :: Client.response()
  def refund_funds_transfer(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/refundFundsTransfer",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Set up a beneficiary relationship."
  @spec setup_beneficiary(map(), keyword()) :: Client.response()
  def setup_beneficiary(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/setupBeneficiary",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Refund all unpaid-out transactions since the most recent payout."
  @spec refund_not_paid_out_transfers(map(), keyword()) :: Client.response()
  def refund_not_paid_out_transfers(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/refundNotPaidOutTransfers",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Send a direct debit request."
  @spec debit_account_holder(map(), keyword()) :: Client.response()
  def debit_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_fund_url(config) <> "/debitAccountHolder",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.ClassicPlatforms.HOP do
  @moduledoc "Adyen Classic Platforms Hosted Onboarding API (v6)."

  alias AdyenClient.{Client, Config}

  @doc "Get a link to an Adyen-hosted onboarding page."
  @spec get_onboarding_url(map(), keyword()) :: Client.response()
  def get_onboarding_url(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_hop_url(config) <> "/getOnboardingUrl",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a link to a PCI compliance questionnaire page."
  @spec get_pci_questionnaire_url(map(), keyword()) :: Client.response()
  def get_pci_questionnaire_url(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_hop_url(config) <> "/getPciQuestionnaireUrl",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.ClassicPlatforms.NotificationConfiguration do
  @moduledoc "Adyen Classic Platforms Notification Configuration API (v6)."

  alias AdyenClient.{Client, Config}

  @doc "Subscribe to notifications."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_notification_config_url(config) <> "/createNotificationConfiguration",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a notification subscription configuration."
  @spec get(map(), keyword()) :: Client.response()
  def get(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_notification_config_url(config) <> "/getNotificationConfiguration",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all notification subscription configurations."
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_notification_config_url(config) <> "/getNotificationConfigurationList",
      %{},
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Test a notification configuration."
  @spec test(map(), keyword()) :: Client.response()
  def test(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_notification_config_url(config) <> "/testNotificationConfiguration",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a notification subscription configuration."
  @spec update(map(), keyword()) :: Client.response()
  def update(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_notification_config_url(config) <> "/updateNotificationConfiguration",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a notification subscription configuration."
  @spec delete(map(), keyword()) :: Client.response()
  def delete(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.classic_notification_config_url(config) <> "/deleteNotificationConfigurations",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
