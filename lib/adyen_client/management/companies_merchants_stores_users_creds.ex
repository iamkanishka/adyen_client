defmodule AdyenClient.Management do
  @moduledoc "Namespace for all Management API sub-modules."
end

defmodule AdyenClient.Management.Companies do
  @moduledoc "Management API — Company account operations."

  alias AdyenClient.{Client, Config}

  @doc "Get a list of company accounts."
  @spec list(map(), keyword()) :: Client.response()
  def list(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Get a single company account."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get all merchant accounts under a company."
  @spec list_merchants(String.t(), map(), keyword()) :: Client.response()
  def list_merchants(company_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/merchants"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.Merchants do
  @moduledoc "Management API — Merchant account operations."

  alias AdyenClient.{Client, Config}

  @doc "Get a list of merchant accounts."
  @spec list(map(), keyword()) :: Client.response()
  def list(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Get a single merchant account."
  @spec get(String.t(), keyword()) :: Client.response()
  def get(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create a merchant account."
  @spec create(map(), keyword()) :: Client.response()
  def create(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Request to activate a merchant account."
  @spec activate(String.t(), keyword()) :: Client.response()
  def activate(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/activate",
      %{},
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.Stores do
  @moduledoc "Management API — Store operations."

  alias AdyenClient.{Client, Config}

  @doc "List stores under a merchant."
  @spec list(String.t(), map(), keyword()) :: Client.response()
  def list(merchant_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/stores"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "List all stores (global, across merchants)."
  @spec list_all(map(), keyword()) :: Client.response()
  def list_all(query \\ %{}, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/stores",
      Keyword.merge(opts, config: config, query: query)
    )
  end

  @doc "Create a store under a merchant."
  @spec create(String.t(), map(), keyword()) :: Client.response()
  def create(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/stores"
    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get a store by merchant and store ID."
  @spec get(String.t(), String.t(), keyword()) :: Client.response()
  def get(merchant_id, store_id, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/stores/#{store_id}"
    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Update a store."
  @spec update(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update(merchant_id, store_id, params, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/stores/#{store_id}"
    Client.patch(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Get a store by store ID only."
  @spec get_by_id(String.t(), keyword()) :: Client.response()
  def get_by_id(store_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/stores/#{store_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a store by store ID only."
  @spec update_by_id(String.t(), map(), keyword()) :: Client.response()
  def update_by_id(store_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/stores/#{store_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.Users do
  @moduledoc "Management API — User management (company and merchant level)."

  alias AdyenClient.{Client, Config}

  # Company-level users
  @doc "List users at company level."
  @spec list_company_users(String.t(), map(), keyword()) :: Client.response()
  def list_company_users(company_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/companies/#{company_id}/users"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Create a user at company level."
  @spec create_company_user(String.t(), map(), keyword()) :: Client.response()
  def create_company_user(company_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/companies/#{company_id}/users",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get company-level user details."
  @spec get_company_user(String.t(), String.t(), keyword()) :: Client.response()
  def get_company_user(company_id, user_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/users/#{user_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a company-level user."
  @spec update_company_user(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_company_user(company_id, user_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/companies/#{company_id}/users/#{user_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  # Merchant-level users
  @doc "List users at merchant level."
  @spec list_merchant_users(String.t(), map(), keyword()) :: Client.response()
  def list_merchant_users(merchant_id, query \\ %{}, opts \\ []) do
    config = resolve_config(opts)
    url = Config.management_url(config) <> "/merchants/#{merchant_id}/users"
    Client.get(url, Keyword.merge(opts, config: config, query: query))
  end

  @doc "Create a user at merchant level."
  @spec create_merchant_user(String.t(), map(), keyword()) :: Client.response()
  def create_merchant_user(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/users",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get merchant-level user details."
  @spec get_merchant_user(String.t(), String.t(), keyword()) :: Client.response()
  def get_merchant_user(merchant_id, user_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/users/#{user_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a merchant-level user."
  @spec update_merchant_user(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_merchant_user(merchant_id, user_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/merchants/#{merchant_id}/users/#{user_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end

defmodule AdyenClient.Management.ApiCredentials do
  @moduledoc "Management API — API credential management."

  alias AdyenClient.{Client, Config}

  @doc "Get my own API credential details."
  @spec get_me(keyword()) :: Client.response()
  def get_me(opts \\ []) do
    config = resolve_config(opts)
    Client.get(Config.management_url(config) <> "/me", Keyword.put(opts, :config, config))
  end

  @doc "Get allowed origins for my credential."
  @spec get_my_origins(keyword()) :: Client.response()
  def get_my_origins(opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/me/allowedOrigins",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Add an allowed origin to my credential."
  @spec add_my_origin(map(), keyword()) :: Client.response()
  def add_my_origin(params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/me/allowedOrigins",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Remove an allowed origin from my credential."
  @spec delete_my_origin(String.t(), keyword()) :: Client.response()
  def delete_my_origin(origin_id, opts \\ []) do
    config = resolve_config(opts)

    Client.delete(
      Config.management_url(config) <> "/me/allowedOrigins/#{origin_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Generate a client key for my credential."
  @spec generate_my_client_key(keyword()) :: Client.response()
  def generate_my_client_key(opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/me/generateClientKey",
      %{},
      Keyword.put(opts, :config, config)
    )
  end

  # Company-level credentials
  @doc "List API credentials at company level."
  @spec list_company(String.t(), keyword()) :: Client.response()
  def list_company(company_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/apiCredentials",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create an API credential at company level."
  @spec create_company(String.t(), map(), keyword()) :: Client.response()
  def create_company(company_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/companies/#{company_id}/apiCredentials",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a company-level API credential."
  @spec get_company(String.t(), String.t(), keyword()) :: Client.response()
  def get_company(company_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/companies/#{company_id}/apiCredentials/#{credential_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a company-level API credential."
  @spec update_company(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_company(company_id, credential_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <> "/companies/#{company_id}/apiCredentials/#{credential_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Generate a new API key for a company-level credential."
  @spec generate_company_api_key(String.t(), String.t(), keyword()) :: Client.response()
  def generate_company_api_key(company_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/apiCredentials/#{credential_id}/generateApiKey"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  @doc "Generate a new client key for a company-level credential."
  @spec generate_company_client_key(String.t(), String.t(), keyword()) :: Client.response()
  def generate_company_client_key(company_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/apiCredentials/#{credential_id}/generateClientKey"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  # Company-level allowed origins
  @doc "List allowed origins for a company-level credential."
  @spec list_company_origins(String.t(), String.t(), keyword()) :: Client.response()
  def list_company_origins(company_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/apiCredentials/#{credential_id}/allowedOrigins"

    Client.get(url, Keyword.put(opts, :config, config))
  end

  @doc "Add an allowed origin to a company-level credential."
  @spec create_company_origin(String.t(), String.t(), map(), keyword()) :: Client.response()
  def create_company_origin(company_id, credential_id, params, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/apiCredentials/#{credential_id}/allowedOrigins"

    Client.post(url, params, Keyword.put(opts, :config, config))
  end

  @doc "Delete an allowed origin from a company-level credential."
  @spec delete_company_origin(String.t(), String.t(), String.t(), keyword()) :: Client.response()
  def delete_company_origin(company_id, credential_id, origin_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/companies/#{company_id}/apiCredentials/#{credential_id}/allowedOrigins/#{origin_id}"

    Client.delete(url, Keyword.put(opts, :config, config))
  end

  # Merchant-level credentials
  @doc "List API credentials at merchant level."
  @spec list_merchant(String.t(), keyword()) :: Client.response()
  def list_merchant(merchant_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <> "/merchants/#{merchant_id}/apiCredentials",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Create an API credential at merchant level."
  @spec create_merchant(String.t(), map(), keyword()) :: Client.response()
  def create_merchant(merchant_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.post(
      Config.management_url(config) <> "/merchants/#{merchant_id}/apiCredentials",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Get a merchant-level API credential."
  @spec get_merchant(String.t(), String.t(), keyword()) :: Client.response()
  def get_merchant(merchant_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    Client.get(
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}",
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Update a merchant-level API credential."
  @spec update_merchant(String.t(), String.t(), map(), keyword()) :: Client.response()
  def update_merchant(merchant_id, credential_id, params, opts \\ []) do
    config = resolve_config(opts)

    Client.patch(
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}",
      params,
      Keyword.put(opts, :config, config)
    )
  end

  @doc "Generate a new API key for a merchant-level credential."
  @spec generate_merchant_api_key(String.t(), String.t(), keyword()) :: Client.response()
  def generate_merchant_api_key(merchant_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}/generateApiKey"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  @doc "Generate a new client key for a merchant-level credential."
  @spec generate_merchant_client_key(String.t(), String.t(), keyword()) :: Client.response()
  def generate_merchant_client_key(merchant_id, credential_id, opts \\ []) do
    config = resolve_config(opts)

    url =
      Config.management_url(config) <>
        "/merchants/#{merchant_id}/apiCredentials/#{credential_id}/generateClientKey"

    Client.post(url, %{}, Keyword.put(opts, :config, config))
  end

  defp resolve_config(opts), do: Keyword.get(opts, :config, Config.load!())
end
