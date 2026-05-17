defmodule AdyenClient.ForeignExchange do
  @moduledoc "Adyen Foreign Exchange API (v1)."

  alias AdyenClient.{Client, Config}

  @doc "Calculate an amount in a different currency."
  @spec calculate(map(), keyword()) :: Client.response()
  def calculate(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.foreign_exchange_url(config) <> "/rates/calculate",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.LegalEntity do
  @moduledoc """
  Adyen Legal Entity Management API (v4).

  Handles KYC onboarding: legal entities, transfer instruments, business lines,
  documents, Terms of Service, PCI questionnaires, and hosted onboarding links.
  """

  alias AdyenClient.{Client, Config}

  # Legal entities
  @doc "Create a legal entity."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a legal entity."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a legal entity."
  @spec update(String.t(), map(), keyword()) :: Client.response()
  def update(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get all business lines under a legal entity."
  @spec get_business_lines(String.t(), keyword()) :: Client.response()
  def get_business_lines(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/businessLines",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Check verification errors for a legal entity."
  @spec check_verification_errors(String.t(), keyword()) :: Client.response()
  def check_verification_errors(id, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/checkVerificationErrors",
      %{},
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Confirm data review for a legal entity."
  @spec confirm_data_review(String.t(), keyword()) :: Client.response()
  def confirm_data_review(id, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/confirmDataReview",
      %{},
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Request a periodic data review."
  @spec request_periodic_review(String.t(), keyword()) :: Client.response()
  def request_periodic_review(id, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/requestPeriodicReview",
      %{},
      Keyword.put(opts, :config, config)
    )
  end

  # Transfer instruments
  @doc "Create a transfer instrument (bank account)."
  @spec create_transfer_instrument(map(), keyword()) :: Client.response()
  def create_transfer_instrument(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/transferInstruments",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a transfer instrument."
  @spec get_transfer_instrument(String.t(), keyword()) :: Client.response()
  def get_transfer_instrument(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/transferInstruments/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a transfer instrument."
  @spec update_transfer_instrument(String.t(), map(), keyword()) :: Client.response()
  def update_transfer_instrument(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.legal_entity_url(config) <> "/transferInstruments/#{id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a transfer instrument."
  @spec delete_transfer_instrument(String.t(), keyword()) :: Client.response()
  def delete_transfer_instrument(id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.legal_entity_url(config) <> "/transferInstruments/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Business lines
  @doc "Create a business line."
  @spec create_business_line(map(), keyword()) :: Client.response()
  def create_business_line(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/businessLines",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a business line."
  @spec get_business_line(String.t(), keyword()) :: Client.response()
  def get_business_line(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/businessLines/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a business line."
  @spec update_business_line(String.t(), map(), keyword()) :: Client.response()
  def update_business_line(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.legal_entity_url(config) <> "/businessLines/#{id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a business line."
  @spec delete_business_line(String.t(), keyword()) :: Client.response()
  def delete_business_line(id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.legal_entity_url(config) <> "/businessLines/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Documents
  @doc "Upload a document for verification."
  @spec upload_document(map(), keyword()) :: Client.response()
  def upload_document(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/documents",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a document."
  @spec get_document(String.t(), keyword()) :: Client.response()
  def get_document(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/documents/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a document."
  @spec update_document(String.t(), map(), keyword()) :: Client.response()
  def update_document(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.legal_entity_url(config) <> "/documents/#{id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a document."
  @spec delete_document(String.t(), keyword()) :: Client.response()
  def delete_document(id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.legal_entity_url(config) <> "/documents/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Terms of Service
  @doc "Get the Terms of Service document for a legal entity."
  @spec get_tos(String.t(), map(), keyword()) :: Client.response()
  def get_tos(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/termsOfService",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Accept Terms of Service."
  @spec accept_tos(String.t(), String.t(), map(), keyword()) :: Client.response()
  def accept_tos(id, tos_doc_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/termsOfService/#{tos_doc_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get ToS acceptance info for a legal entity."
  @spec get_tos_acceptance_info(String.t(), keyword()) :: Client.response()
  def get_tos_acceptance_info(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/termsOfServiceAcceptanceInfos",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get the accepted Terms of Service document."
  @spec get_accepted_tos_document(String.t(), String.t(), keyword()) :: Client.response()
  def get_accepted_tos_document(id, acceptance_ref, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <>
        "/legalEntities/#{id}/acceptedTermsOfServiceDocument/#{acceptance_ref}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get Terms of Service status."
  @spec get_tos_status(String.t(), keyword()) :: Client.response()
  def get_tos_status(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/termsOfServiceStatus",
      Keyword.put(opts, :config, config)
    )
  end

  # PCI Questionnaires
  @doc "Generate a PCI questionnaire."
  @spec generate_pci_questionnaire(String.t(), map(), keyword()) :: Client.response()
  def generate_pci_questionnaire(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <>
        "/legalEntities/#{id}/pciQuestionnaires/generatePciTemplates",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Sign a PCI questionnaire."
  @spec sign_pci_questionnaire(String.t(), map(), keyword()) :: Client.response()
  def sign_pci_questionnaire(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <>
        "/legalEntities/#{id}/pciQuestionnaires/signPciTemplates",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get PCI questionnaire details."
  @spec get_pci_questionnaires(String.t(), keyword()) :: Client.response()
  def get_pci_questionnaires(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/pciQuestionnaires",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a specific PCI questionnaire."
  @spec get_pci_questionnaire(String.t(), String.t(), keyword()) :: Client.response()
  def get_pci_questionnaire(id, pci_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/pciQuestionnaires/#{pci_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Calculate PCI status."
  @spec calculate_pci_status(String.t(), map(), keyword()) :: Client.response()
  def calculate_pci_status(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/pciQuestionnaires/signingRequired",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Tax eDelivery
  @doc "Set tax e-delivery consent."
  @spec set_tax_edelivery_consent(String.t(), map(), keyword()) :: Client.response()
  def set_tax_edelivery_consent(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/setTaxElectronicDeliveryConsent",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Check tax e-delivery consent status."
  @spec check_tax_edelivery_consent(String.t(), map(), keyword()) :: Client.response()
  def check_tax_edelivery_consent(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/checkTaxElectronicDeliveryConsent",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Hosted Onboarding
  @doc "Get a link to an Adyen-hosted onboarding page."
  @spec get_onboarding_link(String.t(), map(), keyword()) :: Client.response()
  def get_onboarding_link(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.legal_entity_url(config) <> "/legalEntities/#{id}/onboardingLinks",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List hosted onboarding page themes."
  @spec list_onboarding_themes(keyword()) :: Client.response()
  def list_onboarding_themes(opts \\ []) do
    config = resolve_config(opts)
    Client.get(Config.legal_entity_url(config) <> "/themes", Keyword.put(opts, :config, config))
  end

  @doc "Get a specific onboarding theme."
  @spec get_onboarding_theme(String.t(), keyword()) :: Client.response()
  def get_onboarding_theme(theme_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.legal_entity_url(config) <> "/themes/#{theme_id}",
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.BalancePlatform do
  @moduledoc """
  Adyen Balance Platform Configuration API (v2).

  Manages balance platforms, account holders, balance accounts, payment instruments,
  transaction rules, sweeps, card PINs, SCA devices, mandates, and transfer limits.
  """

  alias AdyenClient.{Client, Config}

  # Platform
  @doc "Get a balance platform."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/balancePlatforms/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List account holders under a balance platform."
  @spec list_account_holders(String.t(), map(), keyword()) :: Client.response()
  def list_account_holders(id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/balancePlatforms/#{id}/accountHolders"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  # Account holders
  @doc "Create an account holder."
  @spec create_account_holder(map(), keyword()) :: Client.response()
  def create_account_holder(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/accountHolders",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get an account holder."
  @spec get_account_holder(String.t(), keyword()) :: Client.response()
  def get_account_holder(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/accountHolders/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update an account holder."
  @spec update_account_holder(String.t(), map(), keyword()) :: Client.response()
  def update_account_holder(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/accountHolders/#{id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get all balance accounts of an account holder."
  @spec list_balance_accounts(String.t(), keyword()) :: Client.response()
  def list_balance_accounts(holder_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/accountHolders/#{holder_id}/balanceAccounts",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a tax form for an account holder."
  @spec get_tax_form(String.t(), map(), keyword()) :: Client.response()
  def get_tax_form(holder_id, query, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/accountHolders/#{holder_id}/taxForms"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  # Balance accounts
  @doc "Create a balance account."
  @spec create_balance_account(map(), keyword()) :: Client.response()
  def create_balance_account(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/balanceAccounts",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a balance account."
  @spec get_balance_account(String.t(), keyword()) :: Client.response()
  def get_balance_account(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a balance account."
  @spec update_balance_account(String.t(), map(), keyword()) :: Client.response()
  def update_balance_account(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get payment instruments linked to a balance account."
  @spec list_payment_instruments(String.t(), keyword()) :: Client.response()
  def list_payment_instruments(account_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/paymentInstruments",
      Keyword.put(opts, :config, config)
    )
  end

  # Sweeps
  @doc "Create a sweep on a balance account."
  @spec create_sweep(String.t(), map(), keyword()) :: Client.response()
  def create_sweep(account_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/sweeps",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List sweeps for a balance account."
  @spec list_sweeps(String.t(), keyword()) :: Client.response()
  def list_sweeps(account_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/sweeps",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a sweep."
  @spec get_sweep(String.t(), String.t(), keyword()) :: Client.response()
  def get_sweep(account_id, sweep_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/sweeps/#{sweep_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a sweep."
  @spec update_sweep(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_sweep(account_id, sweep_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/sweeps/#{sweep_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a sweep."
  @spec delete_sweep(String.t(), String.t(), keyword()) :: Client.response()
  def delete_sweep(account_id, sweep_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/sweeps/#{sweep_id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Payment instruments
  @doc "Create a payment instrument (card or bank account)."
  @spec create_payment_instrument(map(), keyword()) :: Client.response()
  def create_payment_instrument(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/paymentInstruments",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a payment instrument."
  @spec get_payment_instrument(String.t(), keyword()) :: Client.response()
  def get_payment_instrument(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/paymentInstruments/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a payment instrument."
  @spec update_payment_instrument(String.t(), map(), keyword()) :: Client.response()
  def update_payment_instrument(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/paymentInstruments/#{id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Reveal the full data of a payment instrument."
  @spec reveal_payment_instrument(map(), keyword()) :: Client.response()
  def reveal_payment_instrument(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/paymentInstruments/reveal",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get the PAN of a payment instrument."
  @spec get_pan(String.t(), keyword()) :: Client.response()
  def get_pan(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/paymentInstruments/#{id}/reveal",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List network tokens for a payment instrument."
  @spec list_network_tokens(String.t(), keyword()) :: Client.response()
  def list_network_tokens(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/paymentInstruments/#{id}/networkTokens",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get network token activation data."
  @spec get_network_token_activation_data(String.t(), keyword()) :: Client.response()
  def get_network_token_activation_data(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <>
        "/paymentInstruments/#{id}/networkTokenActivationData",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create network token provisioning data."
  @spec create_network_token_activation_data(String.t(), map(), keyword()) :: Client.response()
  def create_network_token_activation_data(id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <>
        "/paymentInstruments/#{id}/networkTokenActivationData",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Authorized card users
  @doc "Create authorized users for a card."
  @spec create_authorized_card_users(String.t(), map(), keyword()) :: Client.response()
  def create_authorized_card_users(instrument_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <>
        "/paymentInstruments/#{instrument_id}/authorisedCardUsers",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get authorized users for a card."
  @spec get_authorized_card_users(String.t(), keyword()) :: Client.response()
  def get_authorized_card_users(instrument_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <>
        "/paymentInstruments/#{instrument_id}/authorisedCardUsers",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update authorized users for a card."
  @spec update_authorized_card_users(String.t(), map(), keyword()) :: Client.response()
  def update_authorized_card_users(instrument_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <>
        "/paymentInstruments/#{instrument_id}/authorisedCardUsers",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete authorized users for a card."
  @spec delete_authorized_card_users(String.t(), keyword()) :: Client.response()
  def delete_authorized_card_users(instrument_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.balance_platform_url(config) <>
        "/paymentInstruments/#{instrument_id}/authorisedCardUsers",
      Keyword.put(opts, :config, config)
    )
  end

  # Transaction rules
  @doc "Create a transaction rule."
  @spec create_transaction_rule(map(), keyword()) :: Client.response()
  def create_transaction_rule(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/transactionRules",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a transaction rule."
  @spec get_transaction_rule(String.t(), keyword()) :: Client.response()
  def get_transaction_rule(rule_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/transactionRules/#{rule_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a transaction rule."
  @spec update_transaction_rule(String.t(), map(), keyword()) :: Client.response()
  def update_transaction_rule(rule_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/transactionRules/#{rule_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete a transaction rule."
  @spec delete_transaction_rule(String.t(), keyword()) :: Client.response()
  def delete_transaction_rule(rule_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.balance_platform_url(config) <> "/transactionRules/#{rule_id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Bank account validation
  @doc "Validate a bank account."
  @spec validate_bank_account(map(), keyword()) :: Client.response()
  def validate_bank_account(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/validateBankAccountIdentification",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Network tokens
  @doc "Get a network token."
  @spec get_network_token(String.t(), keyword()) :: Client.response()
  def get_network_token(token_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/networkTokens/#{token_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a network token."
  @spec update_network_token(String.t(), map(), keyword()) :: Client.response()
  def update_network_token(token_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/networkTokens/#{token_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Card orders
  @doc "List card orders."
  @spec list_card_orders(map(), keyword()) :: Client.response()
  def list_card_orders(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/cardorders",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Get items in a card order."
  @spec get_card_order_items(String.t(), keyword()) :: Client.response()
  def get_card_order_items(order_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/cardorders/#{order_id}/items",
      Keyword.put(opts, :config, config)
    )
  end

  # PIN management
  @doc "Get the RSA public key for PIN encryption."
  @spec get_public_key(keyword()) :: Client.response()
  def get_public_key(opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/publicKey",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Change a card PIN."
  @spec change_pin(map(), keyword()) :: Client.response()
  def change_pin(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/pins/change",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Reveal a card PIN."
  @spec reveal_pin(map(), keyword()) :: Client.response()
  def reveal_pin(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/pins/reveal",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Transfer routes
  @doc "Calculate transfer routes."
  @spec calculate_transfer_routes(map(), keyword()) :: Client.response()
  def calculate_transfer_routes(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/transferRoutes/calculate",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Grant accounts & offers
  @doc "Get a grant account."
  @spec get_grant_account(String.t(), keyword()) :: Client.response()
  def get_grant_account(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/grantAccounts/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List available grant offers."
  @spec list_grant_offers(keyword()) :: Client.response()
  def list_grant_offers(opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/grantOffers",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a specific grant offer."
  @spec get_grant_offer(String.t(), keyword()) :: Client.response()
  def get_grant_offer(offer_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/grantOffers/#{offer_id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Direct debit mandates
  @doc "List mandates."
  @spec list_mandates(map(), keyword()) :: Client.response()
  def list_mandates(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/mandates",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Get a specific mandate."
  @spec get_mandate(String.t(), keyword()) :: Client.response()
  def get_mandate(mandate_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/mandates/#{mandate_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Amend a mandate."
  @spec amend_mandate(String.t(), map(), keyword()) :: Client.response()
  def amend_mandate(mandate_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/mandates/#{mandate_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel a mandate."
  @spec cancel_mandate(String.t(), keyword()) :: Client.response()
  def cancel_mandate(mandate_id, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/mandates/#{mandate_id}/cancel",
      %{},
      Keyword.put(opts, :config, config)
    )
  end

  # SCA devices
  @doc "Initiate SCA device registration."
  @spec register_sca_device(map(), keyword()) :: Client.response()
  def register_sca_device(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/registeredDevices",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Complete SCA device registration."
  @spec complete_sca_device_registration(String.t(), map(), keyword()) :: Client.response()
  def complete_sca_device_registration(device_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.balance_platform_url(config) <> "/registeredDevices/#{device_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List registered SCA devices."
  @spec list_sca_devices(keyword()) :: Client.response()
  def list_sca_devices(opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.balance_platform_url(config) <> "/registeredDevices",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Delete an SCA device registration."
  @spec delete_sca_device(String.t(), keyword()) :: Client.response()
  def delete_sca_device(device_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.balance_platform_url(config) <> "/registeredDevices/#{device_id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Transfer limits (balance account level)
  @doc "Create a transfer limit for a balance account."
  @spec create_balance_account_limit(String.t(), map(), keyword()) :: Client.response()
  def create_balance_account_limit(account_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/transferLimits",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List transfer limits for a balance account."
  @spec list_balance_account_limits(String.t(), map(), keyword()) :: Client.response()
  def list_balance_account_limits(account_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.balance_platform_url(config) <> "/balanceAccounts/#{account_id}/transferLimits"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Delete a transfer limit for a balance account."
  @spec delete_balance_account_limit(String.t(), String.t(), keyword()) :: Client.response()
  def delete_balance_account_limit(account_id, limit_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.balance_platform_url(config) <>
        "/balanceAccounts/#{account_id}/transferLimits/#{limit_id}",
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.SessionAuth do
  @moduledoc "Session Authentication API — create short-lived session tokens for client SDKs."

  alias AdyenClient.{Client, Config}

  @doc "Create a session token."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.session_auth_url(config) <> "/sessions",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Transfers do
  @moduledoc """
  Adyen Transfers API (v4).

  Move funds within your platform, return transfers, and query transaction history.
  """

  alias AdyenClient.{Client, Config}

  @doc "Transfer funds."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.transfers_url(config) <> "/transfers",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Approve initiated transfers."
  @spec approve(map(), keyword()) :: Client.response()
  def approve(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.transfers_url(config) <> "/transfers/approve",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Cancel initiated transfers."
  @spec cancel(map(), keyword()) :: Client.response()
  def cancel(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.transfers_url(config) <> "/transfers/cancel",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Return a transfer."
  @spec return_transfer(String.t(), map(), keyword()) :: Client.response()
  def return_transfer(transfer_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.transfers_url(config) <> "/transfers/#{transfer_id}/returns",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all transfers."
  @spec list(map(), keyword()) :: Client.response()
  def list(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.transfers_url(config) <> "/transfers",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Get a specific transfer."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.transfers_url(config) <> "/transfers/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all transactions."
  @spec list_transactions(map(), keyword()) :: Client.response()
  def list_transactions(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.transfers_url(config) <> "/transactions",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Get a specific transaction."
  @spec get_transaction(String.t(), keyword()) :: Client.response()
  def get_transaction(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.transfers_url(config) <> "/transactions/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  # Capital via Transfers API
  @doc "Request a capital grant payout."
  @spec request_grant(map(), keyword()) :: Client.response()
  def request_grant(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.transfers_url(config) <> "/grants",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a capital account."
  @spec get_capital_account(keyword()) :: Client.response()
  def get_capital_account(opts \\ []) do
    config = resolve_config(opts)
    Client.get(Config.transfers_url(config) <> "/grants", Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Capital do
  @moduledoc "Adyen Capital API (v1) — embedded financing / business cash advances."

  alias AdyenClient.{Client, Config}

  @doc "Get all available dynamic offers."
  @spec list_dynamic_offers(keyword()) :: Client.response()
  def list_dynamic_offers(opts \\ []) do
    config = resolve_config(opts)
    Client.get(Config.capital_url(config) <> "/dynamicOffers", Keyword.put(opts, :config, config))
  end

  @doc "Calculate a preliminary offer for a financing amount."
  @spec calculate_dynamic_offer(String.t(), map(), keyword()) :: Client.response()
  def calculate_dynamic_offer(offer_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.capital_url(config) <> "/dynamicOffers/#{offer_id}/calculate",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Convert a dynamic offer to a static grant offer."
  @spec create_grant_offer(String.t(), map(), keyword()) :: Client.response()
  def create_grant_offer(offer_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.capital_url(config) <> "/dynamicOffers/#{offer_id}/grantOffer",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all available static grant offers."
  @spec list_grant_offers(keyword()) :: Client.response()
  def list_grant_offers(opts \\ []) do
    config = resolve_config(opts)
    Client.get(Config.capital_url(config) <> "/grantOffers", Keyword.put(opts, :config, config))
  end

  @doc "Get a static grant offer."
  @spec get_grant_offer(String.t(), keyword()) :: Client.response()
  def get_grant_offer(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.capital_url(config) <> "/grantOffers/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Request a capital grant."
  @spec request_grant(map(), keyword()) :: Client.response()
  def request_grant(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.capital_url(config) <> "/grants",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get all grants for an account holder."
  @spec list_grants(keyword()) :: Client.response()
  def list_grants(opts \\ []) do
    config = resolve_config(opts)
    Client.get(Config.capital_url(config) <> "/grants", Keyword.put(opts, :config, config))
  end

  @doc "Get details of a specific grant."
  @spec get_grant(String.t(), keyword()) :: Client.response()
  def get_grant(grant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.capital_url(config) <> "/grants/#{grant_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "List all disbursements for a grant."
  @spec list_disbursements(String.t(), keyword()) :: Client.response()
  def list_disbursements(grant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.capital_url(config) <> "/grants/#{grant_id}/disbursements",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a specific disbursement."
  @spec get_disbursement(String.t(), String.t(), keyword()) :: Client.response()
  def get_disbursement(grant_id, disbursement_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.capital_url(config) <> "/grants/#{grant_id}/disbursements/#{disbursement_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update repayment configuration for a disbursement."
  @spec update_disbursement(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_disbursement(grant_id, disbursement_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.capital_url(config) <> "/grants/#{grant_id}/disbursements/#{disbursement_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get grant account information."
  @spec get_grant_account(String.t(), keyword()) :: Client.response()
  def get_grant_account(id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.capital_url(config) <> "/grantAccounts/#{id}",
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.OpenBanking do
  @moduledoc "Adyen Open Banking API (v1) — account verification via open banking."

  alias AdyenClient.{Client, Config}

  @doc "Create routes for account verification."
  @spec create_verification_routes(map(), keyword()) :: Client.response()
  def create_verification_routes(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.open_banking_url(config) <> "/accountVerification/routes",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get an account verification report."
  @spec get_verification_report(String.t(), keyword()) :: Client.response()
  def get_verification_report(code, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.open_banking_url(config) <> "/accountVerification/reports/#{code}",
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
