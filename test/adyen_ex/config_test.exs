defmodule AdyenEx.ConfigTest do
  use ExUnit.Case, async: true

  alias AdyenEx.Config

  describe "load/1" do
    test "returns ok with valid config" do
      assert {:ok, config} = Config.load(%{api_key: "test_key_123"})
      assert config.api_key == "test_key_123"
      assert config.environment == :test
      assert config.timeout == 30_000
      assert config.max_retries == 3
    end

    test "returns error when api_key missing" do
      assert {:error, _} = Config.load(%{})
    end

    test "accepts :live environment" do
      assert {:ok, config} = Config.load(%{api_key: "k", environment: :live})
      assert config.environment == :live
    end

    test "rejects invalid environment" do
      assert {:error, _} = Config.load(%{api_key: "k", environment: :staging})
    end

    test "applies defaults for all version fields" do
      {:ok, config} = Config.load(%{api_key: "k"})
      assert config.checkout_api_version == "72"
      assert config.management_api_version == "3"
      assert config.balance_platform_api_version == "2"
      assert config.transfer_api_version == "4"
      assert config.legal_entity_api_version == "4"
      assert config.capital_api_version == "1"
    end

    test "allows version overrides" do
      {:ok, config} = Config.load(%{api_key: "k", checkout_api_version: "71"})
      assert config.checkout_api_version == "71"
    end

    test "merges overrides over app env" do
      {:ok, config} = Config.load(%{api_key: "override_key"})
      assert config.api_key == "override_key"
    end
  end

  describe "load!/1" do
    test "returns config map on success" do
      config = Config.load!(%{api_key: "k"})
      assert is_map(config)
      assert config.api_key == "k"
    end

    test "raises on invalid config" do
      assert_raise ArgumentError, fn -> Config.load!(%{}) end
    end
  end

  describe "URL builders" do
    setup do
      {:ok, config} = Config.load(%{api_key: "k"})
      {:ok, live_config} = Config.load(%{api_key: "k", environment: :live})
      %{config: config, live_config: live_config}
    end

    test "checkout_url/1 returns test URL", %{config: config} do
      url = Config.checkout_url(config)
      assert url =~ "checkout-test.adyen.com"
      assert url =~ "/v72"
    end

    test "checkout_url/1 returns live URL", %{live_config: live_config} do
      url = Config.checkout_url(live_config)
      assert url =~ "checkout-live.adyen.com"
    end

    test "management_url/1 returns test URL", %{config: config} do
      url = Config.management_url(config)
      assert url =~ "management-test.adyen.com"
      assert url =~ "/v3"
    end

    test "management_url/1 returns live URL", %{live_config: live_config} do
      url = Config.management_url(live_config)
      assert url =~ "management-live.adyen.com"
    end

    test "balance_platform_url/1 test", %{config: config} do
      url = Config.balance_platform_url(config)
      assert url =~ "balanceplatform-api-test.adyen.com"
      assert url =~ "/v2"
    end

    test "transfers_url/1 test", %{config: config} do
      url = Config.transfers_url(config)
      assert url =~ "balanceplatform-api-test.adyen.com"
      assert url =~ "/btl/v4"
    end

    test "legal_entity_url/1 test", %{config: config} do
      url = Config.legal_entity_url(config)
      assert url =~ "kyc-test.adyen.com"
      assert url =~ "/v4"
    end

    test "capital_url/1 test", %{config: config} do
      url = Config.capital_url(config)
      assert url =~ "capital-test.adyen.com"
    end

    test "terminal_sync_url/1 returns no version suffix", %{config: config} do
      url = Config.terminal_sync_url(config)
      assert url == "https://terminal-api-test.adyen.com"
    end

    test "payment_url/1 test", %{config: config} do
      url = Config.payment_url(config)
      assert url =~ "pal-test.adyen.com"
      assert url =~ "/Payment/v68"
    end

    test "payout_url/1 test", %{config: config} do
      url = Config.payout_url(config)
      assert url =~ "/Payout/v68"
    end

    test "bin_lookup_url/1 test", %{config: config} do
      url = Config.bin_lookup_url(config)
      assert url =~ "/BinLookup/v54"
    end

    test "disputes_url/1 test", %{config: config} do
      url = Config.disputes_url(config)
      assert url =~ "ca-test.adyen.com"
      assert url =~ "/v30"
    end

    test "foreign_exchange_url/1 test", %{config: config} do
      url = Config.foreign_exchange_url(config)
      assert url =~ "/fx/v1"
    end

    test "open_banking_url/1 test", %{config: config} do
      url = Config.open_banking_url(config)
      assert url =~ "/openbanking/v1"
    end

    test "session_auth_url/1 test", %{config: config} do
      url = Config.session_auth_url(config)
      assert url =~ "/sessionauth/v1"
    end

    test "classic_account_url/1 test", %{config: config} do
      url = Config.classic_account_url(config)
      assert url =~ "cal-test.adyen.com"
      assert url =~ "/Account/v6"
    end

    test "classic_fund_url/1 test", %{config: config} do
      url = Config.classic_fund_url(config)
      assert url =~ "/Fund/v6"
    end

    test "classic_hop_url/1 test", %{config: config} do
      url = Config.classic_hop_url(config)
      assert url =~ "/Hop/v6"
    end

    test "classic_notification_config_url/1 test", %{config: config} do
      url = Config.classic_notification_config_url(config)
      assert url =~ "/Notification/v6"
    end

    test "softpos_url/1 test", %{config: config} do
      url = Config.softpos_url(config)
      assert url =~ "terminal-api-test.adyen.com"
    end
  end
end
