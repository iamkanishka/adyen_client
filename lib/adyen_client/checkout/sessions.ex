defmodule AdyenClient.Checkout.Sessions do
  @moduledoc """
  Adyen Checkout Sessions API.

  Manages payment sessions for the Drop-in and Components integration.
  """

  alias AdyenClient.{Client, Config}

  @doc """
  Create a payment session.

  ## Required fields
  - `amount` — `%{currency: "USD", value: 1000}` (value in minor units)
  - `merchantAccount`
  - `returnUrl`
  - `reference` — your unique order reference

  ## Example

      AdyenClient.Checkout.Sessions.create(%{
        amount: %{currency: "USD", value: 1000},
        merchantAccount: "YourMerchantECOM",
        returnUrl: "https://yoursite.com/result",
        reference: "order-123"
      })
  """
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/sessions"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Get the result of a payment session.

  ## Parameters
  - `session_id` — the session ID returned by `create/2`
  - `session_result` — the `sessionResult` query param from the return URL (optional)
  """
  @spec get(String.t(), String.t() | nil, keyword()) :: Client.response()
  def get(session_id, session_result \\ nil, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/sessions/#{session_id}"
    query = if session_result, do: %{"sessionResult" => session_result}, else: %{}
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
