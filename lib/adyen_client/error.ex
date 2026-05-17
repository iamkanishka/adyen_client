defmodule AdyenClient.Error do
  @moduledoc """
  Structured error types returned by all AdyenClient API calls.

  All API functions return `{:ok, response}` or `{:error, AdyenClient.Error.t()}`.
  """

  @type error_type ::
          :api_error
          | :auth_error
          | :validation_error
          | :not_found
          | :rate_limited
          | :server_error
          | :network_error
          | :timeout
          | :config_error
          | :webhook_validation_error

  @type t :: %__MODULE__{
          type: error_type(),
          status: non_neg_integer() | nil,
          message: String.t(),
          error_code: String.t() | nil,
          psp_reference: String.t() | nil,
          raw: map() | nil,
          retryable: boolean()
        }

  defexception [
    :type,
    :status,
    :message,
    :error_code,
    :psp_reference,
    :raw,
    :retryable
  ]

  @impl true
  def message(%__MODULE__{message: msg, error_code: code}) do
    if code, do: "[#{code}] #{msg}", else: msg
  end

  @doc "Build an error from an Adyen API error response body."
  @spec from_response(map(), non_neg_integer()) :: t()
  def from_response(body, status) do
    %__MODULE__{
      type: classify(status),
      status: status,
      message: body["message"] || body["detail"] || "Unknown error",
      error_code: body["errorCode"] || body["errorType"],
      psp_reference: body["pspReference"],
      raw: body,
      retryable: retryable?(status)
    }
  end

  @doc "Build a network/timeout error."
  @spec network(String.t(), boolean()) :: t()
  def network(message, retryable \\ true) do
    %__MODULE__{
      type: :network_error,
      status: nil,
      message: message,
      error_code: nil,
      psp_reference: nil,
      raw: nil,
      retryable: retryable
    }
  end

  @doc "Build a config error."
  @spec config(String.t()) :: t()
  def config(message) do
    %__MODULE__{
      type: :config_error,
      status: nil,
      message: message,
      error_code: nil,
      psp_reference: nil,
      raw: nil,
      retryable: false
    }
  end

  @doc "Build a webhook validation error."
  @spec webhook_validation(String.t()) :: t()
  def webhook_validation(message) do
    %__MODULE__{
      type: :webhook_validation_error,
      status: nil,
      message: message,
      error_code: nil,
      psp_reference: nil,
      raw: nil,
      retryable: false
    }
  end

  defp classify(401), do: :auth_error
  defp classify(403), do: :auth_error
  defp classify(404), do: :not_found
  defp classify(422), do: :validation_error
  defp classify(429), do: :rate_limited
  defp classify(s) when s in 400..499, do: :api_error
  defp classify(s) when s in 500..599, do: :server_error
  defp classify(_), do: :api_error

  defp retryable?(429), do: true
  defp retryable?(s) when s in 500..599, do: true
  defp retryable?(_), do: false
end
