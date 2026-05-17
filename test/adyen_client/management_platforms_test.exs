defmodule AdyenClient.Management.CompaniesTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  test "list/2 sends GET to /companies", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/companies", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => [], "itemsTotal" => 0}))
    end)

    url = "http://localhost:#{bypass.port}/v3/companies"
    assert {:ok, %{"data" => []}} = AdyenClient.Client.get(url, config: config)
  end

  test "get/2 sends GET to /companies/:id", %{bypass: bypass, config: config} do
    company_id = "comp_123"

    Bypass.expect_once(bypass, "GET", "/v3/companies/#{company_id}", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => company_id, "name" => "Test Corp"}))
    end)

    url = "http://localhost:#{bypass.port}/v3/companies/#{company_id}"
    assert {:ok, %{"id" => ^company_id}} = AdyenClient.Client.get(url, config: config)
  end
end

defmodule AdyenClient.Management.MerchantsTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  test "list/2 sends GET to /merchants", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v3/merchants", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => [], "itemsTotal" => 0}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "create/2 sends POST to /merchants", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/v3/merchants", fn conn ->
      {:ok, raw, conn} = Plug.Conn.read_body(conn)
      body = Jason.decode!(raw)
      assert body["legalEntityId"] == "LE123"

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "MERCHANT_NEW"}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants"

    assert {:ok, %{"id" => "MERCHANT_NEW"}} =
             AdyenClient.Client.post(url, %{legalEntityId: "LE123"}, config: config)
  end

  test "activate/2 sends POST to /merchants/:id/activate", %{bypass: bypass, config: config} do
    merchant_id = "MERCH_123"

    Bypass.expect_once(bypass, "POST", "/v3/merchants/#{merchant_id}/activate", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"status" => "Active"}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants/#{merchant_id}/activate"
    assert {:ok, %{"status" => "Active"}} = AdyenClient.Client.post(url, %{}, config: config)
  end
end

defmodule AdyenClient.Management.StoresTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "test_key"})}
  end

  test "create/3 sends POST to /merchants/:id/stores", %{bypass: bypass, config: config} do
    merchant_id = "MERCH_1"

    Bypass.expect_once(bypass, "POST", "/v3/merchants/#{merchant_id}/stores", fn conn ->
      {:ok, raw, conn} = Plug.Conn.read_body(conn)
      body = Jason.decode!(raw)
      assert body["shopperStatement"] == "My Store"

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "ST_NEW", "status" => "active"}))
    end)

    url = "http://localhost:#{bypass.port}/v3/merchants/#{merchant_id}/stores"

    assert {:ok, %{"id" => "ST_NEW"}} =
             AdyenClient.Client.post(url, %{shopperStatement: "My Store"}, config: config)
  end

  test "update/4 sends PATCH to /merchants/:id/stores/:store_id", %{
    bypass: bypass,
    config: config
  } do
    merchant_id = "MERCH_1"
    store_id = "ST_1"

    Bypass.expect_once(
      bypass,
      "PATCH",
      "/v3/merchants/#{merchant_id}/stores/#{store_id}",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => store_id}))
      end
    )

    url = "http://localhost:#{bypass.port}/v3/merchants/#{merchant_id}/stores/#{store_id}"
    assert {:ok, _} = AdyenClient.Client.patch(url, %{status: "inactive"}, config: config)
  end
end

defmodule AdyenClient.BinLookupTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "k"})}
  end

  test "get_3ds_availability/2 posts to /get3dsAvailability", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/v54/get3dsAvailability", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"threeDS2CardRanges" => []}))
    end)

    url = "http://localhost:#{bypass.port}/v54/get3dsAvailability"

    assert {:ok, _} =
             AdyenClient.Client.post(
               url,
               %{merchantAccount: "M", cardNumber: "411111"},
               config: config
             )
  end

  test "get_cost_estimate/2 posts to /getCostEstimate", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/v54/getCostEstimate", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"costEstimateAmount" => %{"value" => 5}}))
    end)

    url = "http://localhost:#{bypass.port}/v54/getCostEstimate"

    assert {:ok, %{"costEstimateAmount" => _}} =
             AdyenClient.Client.post(url, %{merchantAccount: "M"}, config: config)
  end
end

defmodule AdyenClient.DisputesTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "k"})}
  end

  for {action, path} <- [
        {"accept", "acceptDispute"},
        {"defend", "defendDispute"},
        {"delete_defense_document", "deleteDisputeDefenseDocument"},
        {"get_applicable_defense_reasons", "retrieveApplicableDefenseReasons"},
        {"supply_defense_document", "supplyDefenseDocument"}
      ] do
    test "#{action}/2 sends POST to /#{path}", %{bypass: bypass, config: config} do
      path = unquote(path)

      Bypass.expect_once(bypass, "POST", "/v30/#{path}", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"status" => "ok"}))
      end)

      url = "http://localhost:#{bypass.port}/v30/#{path}"

      assert {:ok, _} =
               AdyenClient.Client.post(url, %{disputePspReference: "D123"}, config: config)
    end
  end
end

defmodule AdyenClient.TransfersTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "k"})}
  end

  test "create/2 posts to /transfers", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/btl/v4/transfers", fn conn ->
      {:ok, raw, conn} = Plug.Conn.read_body(conn)
      body = Jason.decode!(raw)
      assert body["amount"]["value"] == 5000

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "TRF_123", "status" => "Authorised"}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/transfers"

    assert {:ok, %{"id" => "TRF_123"}} =
             AdyenClient.Client.post(
               url,
               %{amount: %{value: 5000, currency: "EUR"}, category: "internal"},
               config: config
             )
  end

  test "list/2 sends GET to /transfers", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/btl/v4/transfers", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => [], "total" => 0}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/transfers"
    assert {:ok, %{"data" => []}} = AdyenClient.Client.get(url, config: config)
  end

  test "list_transactions/2 sends GET to /transactions", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/btl/v4/transactions", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"data" => []}))
    end)

    url = "http://localhost:#{bypass.port}/btl/v4/transactions"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end
end

defmodule AdyenClient.CapitalTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "k"})}
  end

  test "list_dynamic_offers/1 GETs /dynamicOffers", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/v1/dynamicOffers", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"dynamicOffers" => []}))
    end)

    url = "http://localhost:#{bypass.port}/v1/dynamicOffers"
    assert {:ok, _} = AdyenClient.Client.get(url, config: config)
  end

  test "request_grant/2 POSTs to /grants", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/v1/grants", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "GRANT_1", "status" => "Pending"}))
    end)

    url = "http://localhost:#{bypass.port}/v1/grants"

    assert {:ok, %{"id" => "GRANT_1"}} =
             AdyenClient.Client.post(url, %{grantOfferId: "OFFER_1"}, config: config)
  end
end

defmodule AdyenClient.ClassicPaymentsTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "k"})}
  end

  for action <- ~w(authorise authorise3d authorise3ds2 capture cancel refund cancelOrRefund
                   technicalCancel adjustAuthorisation donate voidPendingRefund) do
    test "#{action}/2 POSTs to /#{action}", %{bypass: bypass, config: config} do
      action = unquote(action)

      Bypass.expect_once(bypass, "POST", "/pal/servlet/Payment/v68/#{action}", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          200,
          Jason.encode!(%{"pspReference" => "PSP1", "resultCode" => "Authorised"})
        )
      end)

      url = "http://localhost:#{bypass.port}/pal/servlet/Payment/v68/#{action}"

      assert {:ok, %{"resultCode" => "Authorised"}} =
               AdyenClient.Client.post(url, %{merchantAccount: "M"}, config: config)
    end
  end
end

defmodule AdyenClient.LegalEntityTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "k"})}
  end

  test "create/2 POSTs to /legalEntities", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/lem/v4/legalEntities", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "LE_1", "type" => "individual"}))
    end)

    url = "http://localhost:#{bypass.port}/lem/v4/legalEntities"

    assert {:ok, %{"id" => "LE_1"}} =
             AdyenClient.Client.post(url, %{type: "individual"}, config: config)
  end

  test "get/2 GETs /legalEntities/:id", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "GET", "/lem/v4/legalEntities/LE_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "LE_1"}))
    end)

    url = "http://localhost:#{bypass.port}/lem/v4/legalEntities/LE_1"
    assert {:ok, %{"id" => "LE_1"}} = AdyenClient.Client.get(url, config: config)
  end

  test "update/3 PATCHes /legalEntities/:id", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "PATCH", "/lem/v4/legalEntities/LE_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "LE_1"}))
    end)

    url = "http://localhost:#{bypass.port}/lem/v4/legalEntities/LE_1"
    assert {:ok, _} = AdyenClient.Client.patch(url, %{}, config: config)
  end

  test "upload_document/2 POSTs to /documents", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/lem/v4/documents", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "DOC_1"}))
    end)

    url = "http://localhost:#{bypass.port}/lem/v4/documents"

    assert {:ok, %{"id" => "DOC_1"}} =
             AdyenClient.Client.post(url, %{type: "PASSPORT"}, config: config)
  end
end

defmodule AdyenClient.BalancePlatformTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, config: AdyenClient.Config.load!(%{api_key: "k"})}
  end

  test "create_account_holder/2 POSTs to /accountHolders", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/accountHolders", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "AH_1", "status" => "Active"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/accountHolders"

    assert {:ok, %{"id" => "AH_1"}} =
             AdyenClient.Client.post(url, %{legalEntityId: "LE_1"}, config: config)
  end

  test "create_balance_account/2 POSTs to /balanceAccounts", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/balanceAccounts", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "BA_1"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balanceAccounts"

    assert {:ok, %{"id" => "BA_1"}} =
             AdyenClient.Client.post(url, %{accountHolderId: "AH_1"}, config: config)
  end

  test "create_sweep/3 POSTs to /balanceAccounts/:id/sweeps", %{bypass: bypass, config: config} do
    account_id = "BA_1"

    Bypass.expect_once(bypass, "POST", "/bcl/v2/balanceAccounts/#{account_id}/sweeps", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "SWP_1", "status" => "active"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/balanceAccounts/#{account_id}/sweeps"

    assert {:ok, %{"id" => "SWP_1"}} =
             AdyenClient.Client.post(url, %{schedule: %{type: "daily"}}, config: config)
  end

  test "create_payment_instrument/2 POSTs to /paymentInstruments", %{
    bypass: bypass,
    config: config
  } do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/paymentInstruments", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "PI_1", "type" => "card"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/paymentInstruments"

    assert {:ok, %{"id" => "PI_1"}} =
             AdyenClient.Client.post(url, %{type: "card", balanceAccountId: "BA_1"},
               config: config
             )
  end

  test "create_transaction_rule/2 POSTs to /transactionRules", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "POST", "/bcl/v2/transactionRules", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "TR_1"}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/transactionRules"
    assert {:ok, _} = AdyenClient.Client.post(url, %{type: "velocity"}, config: config)
  end

  test "delete_transaction_rule/2 sends DELETE", %{bypass: bypass, config: config} do
    Bypass.expect_once(bypass, "DELETE", "/bcl/v2/transactionRules/TR_1", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{}))
    end)

    url = "http://localhost:#{bypass.port}/bcl/v2/transactionRules/TR_1"
    assert {:ok, _} = AdyenClient.Client.delete(url, config: config)
  end
end
