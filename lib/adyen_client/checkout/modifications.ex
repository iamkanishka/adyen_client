defmodule AdyenClient.Checkout.Modifications do
  @moduledoc """
  Adyen Checkout Modifications API.

  Capture, cancel, refund, reverse, and update authorised payments.
  All modification endpoints require the `paymentPspReference` from the
  original authorisation response.
  """

  alias AdyenClient.{Client, Config}

  @doc """
  Capture an authorised payment.

  ## Parameters
  - `psp_reference` — the PSP reference of the authorisation
  - `params` — at minimum `%{merchantAccount: "...", amount: %{currency: "USD", value: 1000}}`
  """
  @spec capture(String.t(), map(), keyword()) :: Client.response()
  def capture(psp_reference, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/payments/#{psp_reference}/captures"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Cancel an authorised payment (by PSP reference path).

  ## Parameters
  - `psp_reference` — the PSP reference of the authorisation
  - `params` — `%{merchantAccount: "..."}` plus optional `reference`
  """
  @spec cancel(String.t(), map(), keyword()) :: Client.response()
  def cancel(psp_reference, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/payments/#{psp_reference}/cancels"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Cancel an authorised payment using your own merchant reference (global endpoint).
  Use when you don't have the PSP reference yet.

  ## Parameters
  - `params` — must include `merchantAccount` and `reference` (your original order reference)
  """
  @spec cancel_by_reference(map(), keyword()) :: Client.response()
  def cancel_by_reference(params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/cancels"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Refund a captured payment.

  ## Parameters
  - `psp_reference` — PSP reference of the captured payment
  - `params` — `%{merchantAccount: "...", amount: %{currency: "USD", value: 500}}`
  """
  @spec refund(String.t(), map(), keyword()) :: Client.response()
  def refund(psp_reference, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/payments/#{psp_reference}/refunds"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Reverse a payment — refund if captured, cancel if not yet captured.

  ## Parameters
  - `psp_reference` — PSP reference of the payment
  - `params` — `%{merchantAccount: "..."}`
  """
  @spec reverse(String.t(), map(), keyword()) :: Client.response()
  def reverse(psp_reference, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/payments/#{psp_reference}/reversals"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc """
  Update the authorised amount of a payment.

  Useful for tip adjustments or incremental authorisations.

  ## Parameters
  - `psp_reference` — PSP reference of the authorisation
  - `params` — `%{merchantAccount: "...", amount: %{currency: "USD", value: 1100}, industryUsage: "DelayedCharge"}`
  """
  @spec update_amount(String.t(), map(), keyword()) :: Client.response()
  def update_amount(psp_reference, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.checkout_url(config) <> "/payments/#{psp_reference}/amountUpdates"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
