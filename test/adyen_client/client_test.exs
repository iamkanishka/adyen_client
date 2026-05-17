defmodule AdyenClient.ClientTest do
  use ExUnit.Case, async: true

  alias AdyenClient.Client

  setup do
    bypass = Bypass.open()
    config = AdyenClient.Config.load!(%{api_key: "test_key", max_retries: 2, retry_delay: 10})
    %{bypass: bypass, config: config}
  end

  describe "GET request" do
    test "returns ok with parsed body on 200", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "GET", "/test", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"result" => "ok"}))
      end)

      assert {:ok, %{"result" => "ok"}} =
               Client.get("http://localhost:#{bypass.port}/test", config: config)
    end

    test "returns error on 404", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "GET", "/missing", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(404, Jason.encode!(%{"message" => "not found"}))
      end)

      assert {:error, %AdyenClient.Error{type: :not_found}} =
               Client.get("http://localhost:#{bypass.port}/missing", config: config)
    end
  end

  describe "POST request" do
    test "serialises body as JSON", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "POST", "/items", fn conn ->
        {:ok, raw, conn} = Plug.Conn.read_body(conn)
        body = Jason.decode!(raw)
        assert body["name"] == "test"
        assert body["value"] == 42

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"created" => true}))
      end)

      assert {:ok, %{"created" => true}} =
               Client.post("http://localhost:#{bypass.port}/items", %{name: "test", value: 42},
                 config: config
               )
    end

    test "sends content-type application/json", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "POST", "/ct", fn conn ->
        ct = conn |> Plug.Conn.get_req_header("content-type") |> List.first()
        assert ct =~ "application/json"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{}))
      end)

      Client.post("http://localhost:#{bypass.port}/ct", %{}, config: config)
    end
  end

  describe "PATCH request" do
    test "sends PATCH with body", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "PATCH", "/resource/1", fn conn ->
        {:ok, raw, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(raw)
        assert decoded["status"] == "active"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"updated" => true}))
      end)

      assert {:ok, %{"updated" => true}} =
               Client.patch("http://localhost:#{bypass.port}/resource/1", %{status: "active"},
                 config: config
               )
    end
  end

  describe "DELETE request" do
    test "sends DELETE and returns 204 body", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "DELETE", "/resource/1", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(204, "")
      end)

      assert {:ok, _} =
               Client.delete("http://localhost:#{bypass.port}/resource/1", config: config)
    end
  end

  describe "retry logic" do
    test "retries on 500 up to max_retries times", %{bypass: bypass, config: config} do
      # First two calls return 500, third returns 200
      call_count = :counters.new(1, [])

      Bypass.expect(bypass, "POST", "/flaky", fn conn ->
        :counters.add(call_count, 1, 1)
        count = :counters.get(call_count, 1)

        if count < 3 do
          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.send_resp(500, Jason.encode!(%{"message" => "Server error"}))
        else
          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.send_resp(200, Jason.encode!(%{"ok" => true}))
        end
      end)

      assert {:ok, %{"ok" => true}} =
               Client.post("http://localhost:#{bypass.port}/flaky", %{}, config: config)

      assert :counters.get(call_count, 1) == 3
    end

    test "does not retry on 400", %{bypass: bypass, config: config} do
      call_count = :counters.new(1, [])

      Bypass.expect(bypass, "POST", "/bad", fn conn ->
        :counters.add(call_count, 1, 1)

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(400, Jason.encode!(%{"message" => "Bad request"}))
      end)

      assert {:error, %AdyenClient.Error{type: :api_error}} =
               Client.post("http://localhost:#{bypass.port}/bad", %{}, config: config)

      assert :counters.get(call_count, 1) == 1
    end

    test "exhausts retries and returns final error", %{bypass: bypass} do
      config = AdyenClient.Config.load!(%{api_key: "k", max_retries: 2, retry_delay: 5})

      Bypass.expect(bypass, "POST", "/always500", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(500, Jason.encode!(%{"message" => "Always fails"}))
      end)

      assert {:error, %AdyenClient.Error{type: :server_error}} =
               Client.post("http://localhost:#{bypass.port}/always500", %{}, config: config)
    end
  end

  describe "authentication headers" do
    test "uses x-api-key header", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "GET", "/auth", fn conn ->
        api_key = conn |> Plug.Conn.get_req_header("x-api-key") |> List.first()
        assert api_key == "test_key"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{}))
      end)

      Client.get("http://localhost:#{bypass.port}/auth", config: config)
    end

    test "sends user-agent header", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "GET", "/ua", fn conn ->
        ua = conn |> Plug.Conn.get_req_header("user-agent") |> List.first()
        assert ua =~ "adyen_client"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{}))
      end)

      Client.get("http://localhost:#{bypass.port}/ua", config: config)
    end
  end

  describe "query params" do
    test "appends query params to GET request", %{bypass: bypass, config: config} do
      Bypass.expect_once(bypass, "GET", "/search", fn conn ->
        assert conn.query_string =~ "pageSize=10"
        assert conn.query_string =~ "status=active"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"items" => []}))
      end)

      Client.get("http://localhost:#{bypass.port}/search",
        config: config,
        query: %{"pageSize" => "10", "status" => "active"}
      )
    end
  end

  describe "custom idempotency key" do
    test "uses provided idempotency key", %{bypass: bypass, config: config} do
      custom_key = "my-custom-key-12345"

      Bypass.expect_once(bypass, "POST", "/idem", fn conn ->
        idem = conn |> Plug.Conn.get_req_header("idempotency-key") |> List.first()
        assert idem == custom_key

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{}))
      end)

      Client.post("http://localhost:#{bypass.port}/idem", %{},
        config: config,
        idempotency_key: custom_key
      )
    end
  end
end
