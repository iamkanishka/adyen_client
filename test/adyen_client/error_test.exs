defmodule AdyenClient.ErrorTest do
  use ExUnit.Case, async: true

  alias AdyenClient.Error

  describe "from_response/2" do
    test "classifies 401 as auth_error" do
      err = Error.from_response(%{"message" => "Unauthorized"}, 401)
      assert err.type == :auth_error
      assert err.status == 401
      assert err.retryable == false
    end

    test "classifies 403 as auth_error" do
      err = Error.from_response(%{"message" => "Forbidden"}, 403)
      assert err.type == :auth_error
    end

    test "classifies 404 as not_found" do
      err = Error.from_response(%{"message" => "Not found"}, 404)
      assert err.type == :not_found
      assert err.retryable == false
    end

    test "classifies 422 as validation_error" do
      err = Error.from_response(%{"message" => "Invalid"}, 422)
      assert err.type == :validation_error
    end

    test "classifies 429 as rate_limited with retryable true" do
      err = Error.from_response(%{"message" => "Rate limit"}, 429)
      assert err.type == :rate_limited
      assert err.retryable == true
    end

    test "classifies 500 as server_error with retryable true" do
      err = Error.from_response(%{"message" => "Server error"}, 500)
      assert err.type == :server_error
      assert err.retryable == true
    end

    test "classifies 503 as server_error retryable" do
      err = Error.from_response(%{"message" => "Service unavailable"}, 503)
      assert err.type == :server_error
      assert err.retryable == true
    end

    test "classifies 400 as api_error" do
      err = Error.from_response(%{"message" => "Bad request"}, 400)
      assert err.type == :api_error
      assert err.retryable == false
    end

    test "extracts errorCode field" do
      err = Error.from_response(%{"message" => "Expired card", "errorCode" => "101"}, 422)
      assert err.error_code == "101"
    end

    test "extracts pspReference when present" do
      err = Error.from_response(%{"message" => "Failed", "pspReference" => "PSP123"}, 400)
      assert err.psp_reference == "PSP123"
    end

    test "stores raw body" do
      body = %{"message" => "error", "extra" => "data"}
      err = Error.from_response(body, 400)
      assert err.raw == body
    end

    test "falls back to 'Unknown error' when no message" do
      err = Error.from_response(%{}, 500)
      assert err.message == "Unknown error"
    end
  end

  describe "network/2" do
    test "builds network error" do
      err = Error.network("Connection refused")
      assert err.type == :network_error
      assert err.message == "Connection refused"
      assert err.retryable == true
      assert err.status == nil
    end

    test "supports non-retryable network error" do
      err = Error.network("DNS failure", false)
      assert err.retryable == false
    end
  end

  describe "config/1" do
    test "builds config error" do
      err = Error.config("Missing api_key")
      assert err.type == :config_error
      assert err.retryable == false
    end
  end

  describe "webhook_validation/1" do
    test "builds webhook validation error" do
      err = Error.webhook_validation("HMAC mismatch")
      assert err.type == :webhook_validation_error
      assert err.retryable == false
      assert err.message == "HMAC mismatch"
    end
  end

  describe "Exception.message/1" do
    test "includes error code in message when present" do
      err = %Error{message: "Expired card", error_code: "101", type: :api_error}
      assert Exception.message(err) == "[101] Expired card"
    end

    test "omits code prefix when error_code is nil" do
      err = %Error{message: "Server error", error_code: nil, type: :server_error}
      assert Exception.message(err) == "Server error"
    end
  end

  describe "raise/rescue" do
    test "Error is a valid exception that can be raised and rescued" do
      err = Error.config("test error")

      assert_raise AdyenClient.Error, fn ->
        raise err
      end
    end
  end
end
