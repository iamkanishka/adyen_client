defmodule AdyenClient.RaiseDisputes do
  @moduledoc """
  Adyen Raise Disputes API (v4).

  Used by Balance Platform cardholders to raise disputes against card transactions.
  This is the **cardholder-side** dispute API (distinct from `AdyenClient.Disputes`
  which is the **merchant-side** chargeback defense API).

  Base URL shares the Transfers API host: `balanceplatform-api-{env}.adyen.com/btl/v4`
  """

  alias AdyenClient.{Client, Config}

  # ── Dispute Attachments ────────────────────────────────────────────────────

  @doc "Get all attachments linked to a raised dispute."
  @spec list_attachments(String.t(), keyword()) :: Client.response()
  def list_attachments(dispute_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.transfers_url(config) <> "/disputes/#{dispute_id}/attachments"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Add an attachment to a raised dispute."
  @spec add_attachment(String.t(), map(), keyword()) :: Client.response()
  def add_attachment(dispute_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.transfers_url(config) <> "/disputes/#{dispute_id}/attachments"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get a specific attachment from a raised dispute."
  @spec get_attachment(String.t(), String.t(), keyword()) :: Client.response()
  def get_attachment(dispute_id, attachment_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.transfers_url(config) <> "/disputes/#{dispute_id}/attachments/#{attachment_id}"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Delete an attachment from a raised dispute."
  @spec delete_attachment(String.t(), String.t(), keyword()) :: Client.response()
  def delete_attachment(dispute_id, attachment_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.transfers_url(config) <> "/disputes/#{dispute_id}/attachments/#{attachment_id}"
    Client.delete(url, Keyword.put(opts, :config, config))
  end

  # ── Raised Disputes ────────────────────────────────────────────────────────

  @doc "Get a list of raised disputes."
  @spec list(map(), keyword()) :: Client.response()
  def list(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.transfers_url(config) <> "/disputes",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Raise a new dispute."
  @spec raise_dispute(map(), keyword()) :: Client.response()
  def raise_dispute(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.transfers_url(config) <> "/disputes",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a raised dispute by ID."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(dispute_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.transfers_url(config) <> "/disputes/#{dispute_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a raised dispute."
  @spec update(String.t(), map(), keyword()) :: Client.response()
  def update(dispute_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.transfers_url(config) <> "/disputes/#{dispute_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
