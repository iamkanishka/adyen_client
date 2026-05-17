defmodule AdyenClient.Management.PayoutSettingsTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  test "add/3 POSTs to /merchants/:id/payoutSettings", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/v3/merchants/MERCH_1/payoutSettings", fn conn ->
      {:ok, raw, conn} = Plug.Conn.read_body(conn)
      body = Jason.decode!(raw)
      assert body["enabled"] == true

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "PS_1", "enabled" => true}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/payoutSettings"

    assert {:ok, %{"id" => "PS_1"}} =
             AdyenClient.Client.post(url, %{enabled: true, transferInstrumentId: "TI_1"},
               config: config
             )
  end

  test "list/2 GETs /merchants/:id/payoutSettings", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/merchants/MERCH_1/payoutSettings", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/payoutSettings"
    assert {:ok, %{"data" => []}} = AdyenClient.Client.get(url, config: config)
  end

  test "get/3 GETs /merchants/:id/payoutSettings/:setting_id", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/merchants/MERCH_1/payoutSettings/PS_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "PS_1"}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/payoutSettings/PS_1"
    assert {:ok, %{"id" => "PS_1"}} = AdyenClient.Client.get(url, config: config)
  end

  test "update/4 PATCHes /merchants/:id/payoutSettings/:setting_id", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "PATCH", "/v3/merchants/MERCH_1/payoutSettings/PS_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "PS_1", "enabled" => false}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/payoutSettings/PS_1"

    assert {:ok, %{"enabled" => false}} =
             AdyenClient.Client.patch(url, %{enabled: false}, config: config)
  end

  test "delete/3 DELETEs /merchants/:id/payoutSettings/:setting_id", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "DELETE", "/v3/merchants/MERCH_1/payoutSettings/PS_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(204, "")
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/payoutSettings/PS_1"
    assert {:ok, _} = AdyenClient.Client.delete(url, config: config)
  end
end

defmodule AdyenClient.Management.AllowedOriginsTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  test "get_my_origin/2 GETs /me/allowedOrigins/:id", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/me/allowedOrigins/OID_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "OID_1", "domain" => "example.com"}))
    end)

    url = "http://localhost:#{bypass.port}/v3/me/allowedOrigins/OID_1"
    assert {:ok, %{"id" => "OID_1"}} = AdyenClient.Client.get(url, config: config)
  end

  test "list_merchant_origins/3 GETs merchant credential origins", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "GET",
      "/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
      end
    )

    url =
      "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins"

    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "create_merchant_origin/4 POSTs merchant credential origin", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "POST",
      "/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "OID_NEW"}))
      end
    )

    url =
      "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins"

    assert {:ok, %{"id" => "OID_NEW"}} =
             AdyenClient.Client.post(url, %{domain: "example.com"}, config: config)
  end

  test "get_merchant_origin/4 GETs specific merchant credential origin", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "GET",
      "/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins/OID_1",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "OID_1"}))
      end
    )

    url =
      "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins/OID_1"

    assert {:ok, %{"id" => "OID_1"}} = AdyenClient.Client.get(url, config: config)
  end

  test "delete_merchant_origin/4 DELETEs merchant credential origin", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "DELETE",
      "/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins/OID_1",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(204, "")
      end
    )

    url =
      "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/apiCredentials/CRED_1/allowedOrigins/OID_1"

    assert {:ok, _} = AdyenClient.Client.delete(url, config: config)
  end
end

defmodule AdyenClient.Management.TerminalSettingsLogoTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  test "get_store_logo/3 GETs merchant+store_ref logo", %{bypass: bypass, config: config} do
    Bypass.expect_once(
      bypass,
      "GET",
      "/v3/merchants/MERCH_1/stores/STORE_1/terminalLogos",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => "base64..."}))
      end
    )

    url = "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/stores/STORE_1/terminalLogos"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "update_store_logo/4 PATCHes merchant+store_ref logo", %{bypass: bypass, config: config} do
    Bypass.expect_once(
      bypass,
      "PATCH",
      "/v3/merchants/MERCH_1/stores/STORE_1/terminalLogos",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"updated" => true}))
      end
    )

    url = "http://localhost:#{bypass.port}/v3/merchants/MERCH_1/stores/STORE_1/terminalLogos"
    assert {:ok, _} = AdyenClient.Client.patch(url, %{data: "base64..."}, config: config)
  end

  test "get_store_logo_by_id/2 GETs store-ID-only logo", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/stores/STORE_1/terminalLogos", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => "base64..."}))
    end)

    url = "http://localhost:#{bypass.port}/v3/stores/STORE_1/terminalLogos"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "get_store_settings_by_id/2 GETs store-ID-only settings", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/stores/STORE_1/terminalSettings", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "STORE_1"}))
    end)

    url = "http://localhost:#{bypass.port}/v3/stores/STORE_1/terminalSettings"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "get_terminal_logo/2 GETs terminal-level logo", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/terminals/TERM_1/terminalLogos", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => "base64..."}))
    end)

    url = "http://localhost:#{bypass.port}/v3/terminals/TERM_1/terminalLogos"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "update_terminal_logo/3 PATCHes terminal-level logo", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "PATCH", "/v3/terminals/TERM_1/terminalLogos", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"updated" => true}))
    end)

    url = "http://localhost:#{bypass.port}/v3/terminals/TERM_1/terminalLogos"
    assert {:ok, _} = AdyenClient.Client.patch(url, %{data: "base64..."}, config: config)
  end
end

defmodule AdyenClient.Management.TerminalManagementTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  for {action, path} <- [
        {"assign", "assignTerminals"},
        {"find_terminal", "findTerminal"},
        {"get_stores", "getStoresUnderAccount"},
        {"get_terminal", "getTerminalDetails"},
        {"list_terminals", "getTerminalsUnderAccount"}
      ] do
    test "#{action}/2 POSTs to postfmapi/#{path}", %{bypass: bypass, config: config} do
      path = unquote(path)

      Bypass.expect_once(bypass, "POST", "/postfmapi/terminal/v1/#{path}", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"response" => "ok"}))
      end)

      url = "http://localhost:#{bypass.port}/postfmapi/terminal/v1/#{path}"
      assert {:ok, _} = AdyenClient.Client.post(url, %{companyAccount: "Test"}, config: config)
    end
  end
end

defmodule AdyenClient.RaiseDisputesTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  test "list/2 GETs /disputes", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/btl/v4/disputes", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes"
    assert {:ok, %{"data" => []}} = AdyenClient.Client.get(url, config: config)
  end

  test "raise_dispute/2 POSTs to /disputes", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/btl/v4/disputes", fn conn ->
      {:ok, raw, conn} = Plug.Conn.read_body(conn)
      body = Jason.decode!(raw)
      assert body["transactionId"] == "TXN_123"

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "DISP_1", "status" => "Open"}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes"

    assert {:ok, %{"id" => "DISP_1"}} =
             AdyenClient.Client.post(url, %{transactionId: "TXN_123", reason: "itemNotReceived"},
               config: config
             )
  end

  test "get/2 GETs /disputes/:id", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/btl/v4/disputes/DISP_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "DISP_1", "status" => "Open"}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes/DISP_1"
    assert {:ok, %{"id" => "DISP_1"}} = AdyenClient.Client.get(url, config: config)
  end

  test "update/3 PATCHes /disputes/:id", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "PATCH", "/btl/v4/disputes/DISP_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "DISP_1", "status" => "Updated"}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes/DISP_1"

    assert {:ok, _} =
             AdyenClient.Client.patch(url, %{description: "Updated description"}, config: config)
  end

  test "list_attachments/2 GETs /disputes/:id/attachments", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/btl/v4/disputes/DISP_1/attachments", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes/DISP_1/attachments"
    assert {:ok, %{"data" => []}} = AdyenClient.Client.get(url, config: config)
  end

  test "add_attachment/3 POSTs to /disputes/:id/attachments", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/btl/v4/disputes/DISP_1/attachments", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "ATT_1"}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes/DISP_1/attachments"

    assert {:ok, %{"id" => "ATT_1"}} =
             AdyenClient.Client.post(url, %{content: "base64...", contentType: "image/jpeg"},
               config: config
             )
  end

  test "get_attachment/3 GETs /disputes/:id/attachments/:att_id", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "GET", "/btl/v4/disputes/DISP_1/attachments/ATT_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "ATT_1"}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes/DISP_1/attachments/ATT_1"
    assert {:ok, %{"id" => "ATT_1"}} = AdyenClient.Client.get(url, config: config)
  end

  test "delete_attachment/3 DELETEs /disputes/:id/attachments/:att_id", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "DELETE", "/btl/v4/disputes/DISP_1/attachments/ATT_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(204, "")
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/disputes/DISP_1/attachments/ATT_1"
    assert {:ok, _} = AdyenClient.Client.delete(url, config: config)
  end
end

defmodule AdyenClient.BalancePlatform.ExtrasTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  # Transaction rules scoped queries
  test "list_for_platform/2 GETs platform transaction rules", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/balancePlatforms/BP_1/transactionRules", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"transactionRules" => []}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balancePlatforms/BP_1/transactionRules"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "list_for_account_holder/2 GETs account holder transaction rules", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/accountHolders/AH_1/transactionRules", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"transactionRules" => []}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/accountHolders/AH_1/transactionRules"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "list_for_balance_account/2 GETs balance account transaction rules", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/balanceAccounts/BA_1/transactionRules", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"transactionRules" => []}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balanceAccounts/BA_1/transactionRules"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "list_for_payment_instrument/2 GETs instrument transaction rules", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "GET",
      "/bcl/v2/paymentInstruments/PI_1/transactionRules",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"transactionRules" => []}))
      end
    )

    url = "http://localhost:#{bypass.port}/bcl/v2/paymentInstruments/PI_1/transactionRules"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "list_for_payment_instrument_group/2 GETs group transaction rules", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "GET",
      "/bcl/v2/paymentInstrumentGroups/PIG_1/transactionRules",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"transactionRules" => []}))
      end
    )

    url = "http://localhost:#{bypass.port}/bcl/v2/paymentInstrumentGroups/PIG_1/transactionRules"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  # Webhook settings
  test "WebhookSettings.create/3 POSTs balance webhook setting", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/balanceAccounts/BA_1/balanceWebhooks", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "BWH_1"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balanceAccounts/BA_1/balanceWebhooks"

    assert {:ok, %{"id" => "BWH_1"}} =
             AdyenClient.Client.post(url, %{url: "https://example.com/hook"}, config: config)
  end

  test "WebhookSettings.list/2 GETs balance webhook settings", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/balanceAccounts/BA_1/balanceWebhooks", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balanceAccounts/BA_1/balanceWebhooks"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "WebhookSettings.delete/3 DELETEs balance webhook setting", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "DELETE",
      "/bcl/v2/balanceAccounts/BA_1/balanceWebhooks/BWH_1",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(204, "")
      end
    )

    url = "http://localhost:#{bypass.port}/bcl/v2/balanceAccounts/BA_1/balanceWebhooks/BWH_1"
    assert {:ok, _} = AdyenClient.Client.delete(url, config: config)
  end

  # Payment Instrument Groups
  test "PaymentInstrumentGroups.create/2 POSTs to /paymentInstrumentGroups", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/paymentInstrumentGroups", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "PIG_1"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/paymentInstrumentGroups"

    assert {:ok, %{"id" => "PIG_1"}} =
             AdyenClient.Client.post(url, %{balancePlatform: "BP_1"}, config: config)
  end

  test "PaymentInstrumentGroups.get/2 GETs /paymentInstrumentGroups/:id", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/paymentInstrumentGroups/PIG_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "PIG_1"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/paymentInstrumentGroups/PIG_1"
    assert {:ok, %{"id" => "PIG_1"}} = AdyenClient.Client.get(url, config: config)
  end

  # SCA Devices
  test "SCADevices.begin_registration/2 POSTs to /scaDevices", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/scaDevices", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "SCA_1", "status" => "pending"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/scaDevices"

    assert {:ok, %{"id" => "SCA_1"}} =
             AdyenClient.Client.post(url, %{paymentInstrumentId: "PI_1"}, config: config)
  end

  test "SCADevices.finish_registration/3 PATCHes /scaDevices/:id", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "PATCH", "/bcl/v2/scaDevices/SCA_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "SCA_1", "status" => "registered"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/scaDevices/SCA_1"

    assert {:ok, %{"status" => "registered"}} =
             AdyenClient.Client.patch(url, %{registrationCode: "CODE_123"}, config: config)
  end

  test "SCADevices.create_association/3 POSTs /scaDevices/:id/associations", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/scaDevices/SCA_1/associations", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "ASSOC_1"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/scaDevices/SCA_1/associations"
    assert {:ok, _} = AdyenClient.Client.post(url, %{paymentInstrumentId: "PI_1"}, config: config)
  end

  # SCA Associations
  test "SCAAssociations.list_for_entity/2 GETs entity SCA devices", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/entities/PI_1/scaDevices", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/entities/PI_1/scaDevices"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "SCAAssociations.delete_for_entity/2 DELETEs entity SCA devices", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "DELETE", "/bcl/v2/entities/PI_1/scaDevices", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(204, "")
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/entities/PI_1/scaDevices"
    assert {:ok, _} = AdyenClient.Client.delete(url, config: config)
  end

  test "SCAAssociations.approve_pending/4 POSTs entity SCA approval", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "POST",
      "/bcl/v2/entities/PI_1/scaDevices/SCA_1/approve",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"status" => "approved"}))
      end
    )

    url = "http://localhost:#{bypass.port}/bcl/v2/entities/PI_1/scaDevices/SCA_1/approve"
    assert {:ok, %{"status" => "approved"}} = AdyenClient.Client.post(url, %{}, config: config)
  end

  # Transfer Limits
  test "TransferLimits.approve_balance_account_limits/3 POSTs limit approval", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "POST",
      "/bcl/v2/balanceAccounts/BA_1/transferLimits/approve",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"status" => "approved"}))
      end
    )

    url = "http://localhost:#{bypass.port}/bcl/v2/balanceAccounts/BA_1/transferLimits/approve"
    assert {:ok, _} = AdyenClient.Client.post(url, %{}, config: config)
  end

  test "TransferLimits.create_platform_limit/3 POSTs platform limit", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/balancePlatforms/BP_1/transferLimits", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "LIMIT_1"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balancePlatforms/BP_1/transferLimits"

    assert {:ok, %{"id" => "LIMIT_1"}} =
             AdyenClient.Client.post(url, %{amount: %{currency: "EUR", value: 10_000}},
               config: config
             )
  end

  test "TransferLimits.list_platform_limits/2 GETs platform limits", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/balancePlatforms/BP_1/transferLimits", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balancePlatforms/BP_1/transferLimits"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "TransferLimits.delete_platform_limit/3 DELETEs platform limit", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(
      bypass,
      "DELETE",
      "/bcl/v2/balancePlatforms/BP_1/transferLimits/LIMIT_1",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(204, "")
      end
    )

    url = "http://localhost:#{bypass.port}/bcl/v2/balancePlatforms/BP_1/transferLimits/LIMIT_1"
    assert {:ok, _} = AdyenClient.Client.delete(url, config: config)
  end

  # Tax form summary
  test "AccountHolders.get_tax_form_summary/3 GETs tax form summary", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "GET", "/bcl/v2/accountHolders/AH_1/taxFormSummary", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/accountHolders/AH_1/taxFormSummary"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end
end
