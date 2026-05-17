defmodule AdyenEx.Checkout.SessionsTest do
  use ExUnit.Case, async: true

  alias AdyenEx.Checkout.Sessions
  alias AdyenEx.TestSupport.Factory

  setup do
    bypass = Bypass.open()
    config = AdyenEx.Config.load!(%{api_key: "test_key", environment: :test})
    # Override checkout URL to point at bypass
    config = Map.put(config, :_bypass_port, bypass.port)
    %{bypass: bypass, config: config}
  end

  defp bypass_config(port) do
    AdyenEx.Config.load!(%{
      api_key: "test_key",
      environment: :test,
      checkout_api_version: "72"
    })
    |> Map.put(:__bypass_port, port)
  end

  defp session_response do
    %{
      "id" => "CS6DB...",
      "sessionData" => "Ab02b4c...",
      "merchantAccount" => "TestMerchant",
      "amount" => %{"currency" => "EUR", "value" => 1000},
      "expiresAt" => "2024-12-31T23:59:59Z",
      "reference" => "order-123",
      "returnUrl" => "https://example.com/result"
    }
  end

  describe "create/2" do
    test "sends POST to /sessions and returns body on 200", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v72/sessions", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["merchantAccount"] == "TestMerchant"
        assert decoded["amount"]["value"] == 1000

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(session_response()))
      end)

      params = Factory.build(:session_params)
      config = AdyenEx.Config.load!(%{api_key: "test_key", environment: :test})

      # Use Bypass URL directly
      url = "http://localhost:#{bypass.port}/v72/sessions"
      result = AdyenEx.Client.post(url, params, config: config)

      assert {:ok, body} = result
      assert body["id"] == "CS6DB..."
    end

    test "sends x-api-key header", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v72/sessions", fn conn ->
        api_key = conn |> Plug.Conn.get_req_header("x-api-key") |> List.first()
        assert api_key == "test_key"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(session_response()))
      end)

      config = AdyenEx.Config.load!(%{api_key: "test_key", environment: :test})
      url = "http://localhost:#{bypass.port}/v72/sessions"
      AdyenEx.Client.post(url, Factory.build(:session_params), config: config)
    end

    test "sends idempotency-key header on POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v72/sessions", fn conn ->
        idem_key = conn |> Plug.Conn.get_req_header("idempotency-key") |> List.first()
        assert is_binary(idem_key) and byte_size(idem_key) > 0

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(session_response()))
      end)

      config = AdyenEx.Config.load!(%{api_key: "test_key"})
      url = "http://localhost:#{bypass.port}/v72/sessions"
      AdyenEx.Client.post(url, Factory.build(:session_params), config: config)
    end

    test "returns structured error on 401", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v72/sessions", fn conn ->
        body = %{"status" => 401, "message" => "Invalid API key", "errorCode" => "000"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(401, Jason.encode!(body))
      end)

      config = AdyenEx.Config.load!(%{api_key: "bad_key"})
      url = "http://localhost:#{bypass.port}/v72/sessions"
      result = AdyenEx.Client.post(url, %{}, config: config)

      assert {:error, %AdyenEx.Error{type: :auth_error, status: 401}} = result
    end

    test "returns not_found error on 404", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v72/sessions", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(404, Jason.encode!(%{"message" => "Not found"}))
      end)

      config = AdyenEx.Config.load!(%{api_key: "k"})
      url = "http://localhost:#{bypass.port}/v72/sessions"

      assert {:error, %AdyenEx.Error{type: :not_found}} =
               AdyenEx.Client.post(url, %{}, config: config)
    end

    test "returns validation error on 422", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v72/sessions", fn conn ->
        body = %{"message" => "Required field missing: amount", "errorCode" => "130"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(422, Jason.encode!(body))
      end)

      config = AdyenEx.Config.load!(%{api_key: "k"})
      url = "http://localhost:#{bypass.port}/v72/sessions"

      assert {:error, %AdyenEx.Error{type: :validation_error, error_code: "130"}} =
               AdyenEx.Client.post(url, %{}, config: config)
    end
  end

  describe "get/3" do
    test "sends GET to /sessions/:id", %{bypass: bypass} do
      session_id = "CS6DB123"

      Bypass.expect_once(bypass, "GET", "/v72/sessions/#{session_id}", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(session_response()))
      end)

      config = AdyenEx.Config.load!(%{api_key: "k"})
      url = "http://localhost:#{bypass.port}/v72/sessions/#{session_id}"
      assert {:ok, body} = AdyenEx.Client.get(url, config: config)
      assert body["id"] == "CS6DB..."
    end

    test "passes sessionResult as query param when provided", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v72/sessions/CSID", fn conn ->
        params = conn.query_string
        assert params =~ "sessionResult"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(session_response()))
      end)

      config = AdyenEx.Config.load!(%{api_key: "k"})
      url = "http://localhost:#{bypass.port}/v72/sessions/CSID"

      AdyenEx.Client.get(url,
        config: config,
        query: %{"sessionResult" => "UyFxyz"}
      )
    end
  end
end

defmodule AdyenEx.Checkout.ModificationsTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass}
  end

  defp base_config, do: AdyenEx.Config.load!(%{api_key: "test_key"})

  describe "capture/3" do
    test "POSTs to /payments/:psp/captures", %{bypass: bypass} do
      psp = "PSP123"
      capture_resp = %{"pspReference" => "CAP456", "status" => "received"}

      Bypass.expect_once(bypass, "POST", "/v72/payments/#{psp}/captures", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(201, Jason.encode!(capture_resp))
      end)

      url = "http://localhost:#{bypass.port}/v72/payments/#{psp}/captures"

      assert {:ok, body} =
               AdyenEx.Client.post(
                 url,
                 %{merchantAccount: "TestMerchant", amount: %{currency: "EUR", value: 1000}},
                 config: base_config()
               )

      assert body["status"] == "received"
    end
  end

  describe "refund/3" do
    test "POSTs to /payments/:psp/refunds", %{bypass: bypass} do
      psp = "PSP_CAPTURED"

      Bypass.expect_once(bypass, "POST", "/v72/payments/#{psp}/refunds", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["amount"]["value"] == 500

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          201,
          Jason.encode!(%{"pspReference" => "REF789", "status" => "received"})
        )
      end)

      url = "http://localhost:#{bypass.port}/v72/payments/#{psp}/refunds"

      assert {:ok, %{"status" => "received"}} =
               AdyenEx.Client.post(
                 url,
                 %{merchantAccount: "Merchant", amount: %{currency: "EUR", value: 500}},
                 config: base_config()
               )
    end
  end

  describe "cancel/3" do
    test "POSTs to /payments/:psp/cancels", %{bypass: bypass} do
      psp = "PSP_AUTH"

      Bypass.expect_once(bypass, "POST", "/v72/payments/#{psp}/cancels", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          201,
          Jason.encode!(%{"pspReference" => "CAN111", "status" => "received"})
        )
      end)

      url = "http://localhost:#{bypass.port}/v72/payments/#{psp}/cancels"

      assert {:ok, _} =
               AdyenEx.Client.post(url, %{merchantAccount: "Merchant"}, config: base_config())
    end
  end

  describe "cancel_by_reference/2" do
    test "POSTs to /cancels global endpoint", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v72/cancels", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(201, Jason.encode!(%{"status" => "received"}))
      end)

      url = "http://localhost:#{bypass.port}/v72/cancels"

      assert {:ok, _} =
               AdyenEx.Client.post(
                 url,
                 %{merchantAccount: "Merchant", reference: "order-123"},
                 config: base_config()
               )
    end
  end

  describe "reverse/3" do
    test "POSTs to /payments/:psp/reversals", %{bypass: bypass} do
      psp = "PSP_REV"

      Bypass.expect_once(bypass, "POST", "/v72/payments/#{psp}/reversals", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(201, Jason.encode!(%{"status" => "received"}))
      end)

      url = "http://localhost:#{bypass.port}/v72/payments/#{psp}/reversals"
      assert {:ok, _} = AdyenEx.Client.post(url, %{merchantAccount: "M"}, config: base_config())
    end
  end

  describe "update_amount/3" do
    test "POSTs to /payments/:psp/amountUpdates", %{bypass: bypass} do
      psp = "PSP_UPDATE"

      Bypass.expect_once(bypass, "POST", "/v72/payments/#{psp}/amountUpdates", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"status" => "received"}))
      end)

      url = "http://localhost:#{bypass.port}/v72/payments/#{psp}/amountUpdates"

      assert {:ok, _} =
               AdyenEx.Client.post(
                 url,
                 %{
                   merchantAccount: "Merchant",
                   amount: %{currency: "EUR", value: 1100},
                   industryUsage: "DelayedCharge"
                 },
                 config: base_config()
               )
    end
  end
end
