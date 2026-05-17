defmodule AdyenClient.Config do
  @moduledoc """
  Configuration management for AdyenClient.

  ## Configuration

      config :adyen_client,
        api_key: "AQEyhmfxK...",
        environment: :live,
        merchant_account: "YourMerchantECOM",
        timeout: 30_000,
        max_retries: 3

  ## Runtime override

      AdyenClient.Checkout.Sessions.create(%{...}, config: AdyenClient.Config.load!(%{api_key: "other"}))
  """

  @type t :: %{
          api_key: String.t(),
          environment: :test | :live,
          merchant_account: String.t() | nil,
          timeout: non_neg_integer(),
          connect_timeout: non_neg_integer(),
          max_retries: non_neg_integer(),
          retry_delay: non_neg_integer(),
          checkout_api_version: String.t(),
          management_api_version: String.t(),
          terminal_api_version: String.t(),
          cloud_device_api_version: String.t(),
          bin_lookup_api_version: String.t(),
          disputes_api_version: String.t(),
          payout_api_version: String.t(),
          recurring_api_version: String.t(),
          balance_platform_api_version: String.t(),
          transfer_api_version: String.t(),
          legal_entity_api_version: String.t(),
          capital_api_version: String.t(),
          classic_payment_api_version: String.t(),
          classic_account_api_version: String.t(),
          classic_fund_api_version: String.t(),
          classic_hop_api_version: String.t(),
          classic_notification_api_version: String.t(),
          foreign_exchange_api_version: String.t(),
          open_banking_api_version: String.t(),
          webhook_hmac_key: String.t() | nil,
          user_agent: String.t()
        }

  @defaults %{
    environment: :test,
    timeout: 30_000,
    connect_timeout: 10_000,
    max_retries: 3,
    retry_delay: 500,
    checkout_api_version: "72",
    management_api_version: "3",
    terminal_api_version: "1",
    cloud_device_api_version: "1",
    bin_lookup_api_version: "54",
    disputes_api_version: "30",
    payout_api_version: "68",
    recurring_api_version: "68",
    balance_platform_api_version: "2",
    transfer_api_version: "4",
    legal_entity_api_version: "4",
    capital_api_version: "1",
    classic_payment_api_version: "68",
    classic_account_api_version: "6",
    classic_fund_api_version: "6",
    classic_hop_api_version: "6",
    classic_notification_api_version: "6",
    foreign_exchange_api_version: "1",
    open_banking_api_version: "1",
    webhook_hmac_key: nil,
    merchant_account: nil
  }

  @live_hosts %{
    checkout: "https://checkout-live.adyen.com/v{version}",
    management: "https://management-live.adyen.com/v{version}",
    payment: "https://pal-live.adyen.com/pal/servlet/Payment/v{version}",
    payout: "https://pal-live.adyen.com/pal/servlet/Payout/v{version}",
    recurring: "https://pal-live.adyen.com/pal/servlet/Recurring/v{version}",
    bin_lookup: "https://pal-live.adyen.com/pal/servlet/BinLookup/v{version}",
    disputes: "https://ca-live.adyen.com/ca/services/DisputeService/v{version}",
    balance_platform: "https://balanceplatform-api-live.adyen.com/bcl/v{version}",
    transfers: "https://balanceplatform-api-live.adyen.com/btl/v{version}",
    legal_entity: "https://kyc-live.adyen.com/lem/v{version}",
    capital: "https://capital-live.adyen.com/v{version}",
    foreign_exchange: "https://balanceplatform-api-live.adyen.com/fx/v{version}",
    open_banking: "https://balanceplatform-api-live.adyen.com/openbanking/v{version}",
    session_auth: "https://balanceplatform-api-live.adyen.com/sessionauth/v1",
    cloud_device: "https://terminal-api-live.adyen.com/v{version}",
    terminal_sync: "https://terminal-api-live.adyen.com",
    classic_account: "https://cal-live.adyen.com/cal/services/Account/v{version}",
    classic_fund: "https://cal-live.adyen.com/cal/services/Fund/v{version}",
    classic_hop: "https://cal-live.adyen.com/cal/services/Hop/v{version}",
    classic_notification_config:
      "https://cal-live.adyen.com/cal/services/Notification/v{version}",
    softpos: "https://terminal-api-live.adyen.com/v{version}",
    payments_app: "https://management-live.adyen.com/v{version}"
  }

  @test_hosts %{
    checkout: "https://checkout-test.adyen.com/v{version}",
    management: "https://management-test.adyen.com/v{version}",
    payment: "https://pal-test.adyen.com/pal/servlet/Payment/v{version}",
    payout: "https://pal-test.adyen.com/pal/servlet/Payout/v{version}",
    recurring: "https://pal-test.adyen.com/pal/servlet/Recurring/v{version}",
    bin_lookup: "https://pal-test.adyen.com/pal/servlet/BinLookup/v{version}",
    disputes: "https://ca-test.adyen.com/ca/services/DisputeService/v{version}",
    balance_platform: "https://balanceplatform-api-test.adyen.com/bcl/v{version}",
    transfers: "https://balanceplatform-api-test.adyen.com/btl/v{version}",
    legal_entity: "https://kyc-test.adyen.com/lem/v{version}",
    capital: "https://capital-test.adyen.com/v{version}",
    foreign_exchange: "https://balanceplatform-api-test.adyen.com/fx/v{version}",
    open_banking: "https://balanceplatform-api-test.adyen.com/openbanking/v{version}",
    session_auth: "https://balanceplatform-api-test.adyen.com/sessionauth/v1",
    cloud_device: "https://terminal-api-test.adyen.com/v{version}",
    terminal_sync: "https://terminal-api-test.adyen.com",
    classic_account: "https://cal-test.adyen.com/cal/services/Account/v{version}",
    classic_fund: "https://cal-test.adyen.com/cal/services/Fund/v{version}",
    classic_hop: "https://cal-test.adyen.com/cal/services/Hop/v{version}",
    classic_notification_config:
      "https://cal-test.adyen.com/cal/services/Notification/v{version}",
    softpos: "https://terminal-api-test.adyen.com/v{version}",
    payments_app: "https://management-test.adyen.com/v{version}"
  }

  @doc "Load and validate config from application env merged with optional overrides."
  @spec load(map()) :: {:ok, t()} | {:error, String.t()}
  def load(overrides \\ %{}) do
    app_config =
      :adyen_client
      |> Application.get_all_env()
      |> Enum.into(%{})

    merged = Map.merge(Map.merge(@defaults, app_config), overrides)

    with :ok <- validate_required(merged, :api_key),
         :ok <- validate_environment(merged) do
      config =
        merged
        |> Map.put_new(:user_agent, "adyen_client/1.0.0 elixir/#{System.version()}")

      {:ok, config}
    end
  end

  @doc "Load config, raising on invalid."
  @spec load!(map()) :: t()
  def load!(overrides \\ %{}) do
    case load(overrides) do
      {:ok, config} -> config
      {:error, msg} -> raise ArgumentError, msg
    end
  end

  # URL builders
  def checkout_url(%{environment: env, checkout_api_version: v}), do: build_url(env, :checkout, v)

  def management_url(%{environment: env, management_api_version: v}),
    do: build_url(env, :management, v)

  def payment_url(%{environment: env, classic_payment_api_version: v}),
    do: build_url(env, :payment, v)

  def payout_url(%{environment: env, payout_api_version: v}), do: build_url(env, :payout, v)

  def recurring_url(%{environment: env, recurring_api_version: v}),
    do: build_url(env, :recurring, v)

  def bin_lookup_url(%{environment: env, bin_lookup_api_version: v}),
    do: build_url(env, :bin_lookup, v)

  def disputes_url(%{environment: env, disputes_api_version: v}), do: build_url(env, :disputes, v)

  def balance_platform_url(%{environment: env, balance_platform_api_version: v}),
    do: build_url(env, :balance_platform, v)

  def transfers_url(%{environment: env, transfer_api_version: v}),
    do: build_url(env, :transfers, v)

  def legal_entity_url(%{environment: env, legal_entity_api_version: v}),
    do: build_url(env, :legal_entity, v)

  def capital_url(%{environment: env, capital_api_version: v}), do: build_url(env, :capital, v)

  def foreign_exchange_url(%{environment: env, foreign_exchange_api_version: v}),
    do: build_url(env, :foreign_exchange, v)

  def open_banking_url(%{environment: env, open_banking_api_version: v}),
    do: build_url(env, :open_banking, v)

  def session_auth_url(%{environment: env}), do: build_url(env, :session_auth, "1")

  def cloud_device_url(%{environment: env, cloud_device_api_version: v}),
    do: build_url(env, :cloud_device, v)

  def softpos_url(%{environment: env}), do: build_url(env, :softpos, "3")

  def payments_app_url(%{environment: env, management_api_version: v}),
    do: build_url(env, :payments_app, v)

  def classic_account_url(%{environment: env, classic_account_api_version: v}),
    do: build_url(env, :classic_account, v)

  def classic_fund_url(%{environment: env, classic_fund_api_version: v}),
    do: build_url(env, :classic_fund, v)

  def classic_hop_url(%{environment: env, classic_hop_api_version: v}),
    do: build_url(env, :classic_hop, v)

  def classic_notification_config_url(%{environment: env, classic_notification_api_version: v}),
    do: build_url(env, :classic_notification_config, v)

  @doc "Legacy PostFM terminal management URL."
  def postfm_url(%{environment: env}) do
    if env == :live,
      do: "https://postfm-live.adyen.com/postfmapi/terminal/v1",
      else: "https://postfm-test.adyen.com/postfmapi/terminal/v1"
  end

  def terminal_sync_url(%{environment: env}) do
    hosts = if env == :live, do: @live_hosts, else: @test_hosts
    Map.fetch!(hosts, :terminal_sync)
  end

  defp build_url(env, service, version) do
    hosts = if env == :live, do: @live_hosts, else: @test_hosts
    hosts |> Map.fetch!(service) |> String.replace("{version}", version)
  end

  defp validate_required(config, key) do
    case Map.get(config, key) do
      nil -> {:error, "Required config key :#{key} is missing"}
      "" -> {:error, "Required config key :#{key} cannot be empty"}
      _ -> :ok
    end
  end

  defp validate_environment(%{environment: env}) when env in [:test, :live], do: :ok

  defp validate_environment(%{environment: env}),
    do: {:error, "Invalid :environment #{inspect(env)}, must be :test or :live"}
end
