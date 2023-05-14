defmodule Shift4Shop.Strategy.OAuth2 do
  @moduledoc """
  An implementation of OAuth2 for Shift4Shop.

  To add your `:client_id` and `:client_secret` include these values in your
  configuration:

  config :oauth2_shift4shop, :credentials,
       client_id: System.get_env("SHIFT4SHOP_CLIENT_ID"),
       client_secret: System.get_env("SHIFT4SHOP_CLIENT_SECRET")

  """

  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://apirest.3dcart.com",
    authorize_url: "https://apirest.3dcart.com/oauth/authorize",
    token_url: "https://apirest.3dcart.com/oauth/token",
    redirect_uri: "https://devportal.3dcart.com/oauth.asp"
  ]

  def client(opts \\ []) do
    config = Application.get_env(:oauth2_shift4shop, :credentials, [])

    opts =
      @defaults
      |> Keyword.merge(opts)
      |> Keyword.merge(config)
      |> resolve_values()

    json_library = Shift4Shop.Oauth2.json_library()

    OAuth2.Client.new(opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client
    |> request_headers(token)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token!(params \\ [], opts \\ []) do
    token =
      client(opts)
      |> get_token(params)

    {_, token} =
      case token do
        {:error, %{body: %{"error" => description}, status_code: error}} ->
          {:error,
           %{
             access_token: nil,
             other_params: [
               error: error,
               error_description: description
             ]
           }}

        {:ok, %{token: token}} ->
          {:ok, token}

        {:ok, %{body: %{token: token}}} ->
          {:ok, token}
      end

    token
  end

  defp request_headers(client, token) do
    client
    |> put_header("Accept", "application/json")
    |> put_header("Content-Type", "application/json")
    |> put_header("SecureURL", token.secure_uri)
    |> put_header("PrivateKey", client.private_key)
    |> put_header("Token", Jason.encode(token))
  end

  # Strategy Callbacks

  defp authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    {code, params} = Keyword.pop(params, :code, client.params["code"])

    unless code do
      raise OAuth2.Error, reason: "Missing required key `code` for `#{inspect(__MODULE__)}`"
    end

    client =
      case client.postback_uri do
        nil -> client
        data -> put_param(client, :postback_uri, data)
      end

    client
    |> put_header("Accept", "application/json")
    |> put_header("Content-Type", "application/x-www-form-urlencoded")
    |> put_param(:code, code)
    |> put_param(:grant_type, "authorization_code")
    |> put_param(:client_id, client.client_id)
    |> put_param(:client_secret, client.client_secret)
    |> put_param(:redirect_uri, client.redirect_uri)
    |> merge_params(params)
    |> put_headers(headers)
  end

  @doc """
  revoke the oauth application.
  """
  def revoke!(token \\ [], opts \\ []) do
    client =
      client(opts)
      |> OAuth2.Client.delete(token)

    {_, token} =
      case client do
        {:error, %{body: %{"error" => description}, status_code: error}} ->
          {:error,
           %{
             access_token: nil,
             other_params: [
               error: error,
               error_description: description
             ]
           }}

        {:ok, %{token: token}} ->
          {:ok, token}

        {:ok, %{body: %{token: token}}} ->
          {:ok, token}
      end

    token
  end

  def revoke(client, params, headers) do
    {store_url, params} = Keyword.pop(params, :store_url, client.params["store_url"])

    unless store_url do
      raise OAuth2.Error, reason: "Missing required key `store_url` for `#{inspect(__MODULE__)}`"
    end

    client
    |> put_header("Accept", "application/json")
    |> put_header("Content-Type", "application/x-www-form-urlencoded")
    |> put_param(:store_url, store_url)
    |> put_param(:client_id, client.client_id)
    |> put_param(:client_secret, client.client_secret)
    |> merge_params(params)
    |> put_headers(headers)
  end

  defp resolve_values(list) do
    for {key, value} <- list do
      {key, resolve_value(value)}
    end
  end

  defp resolve_value({m, f, a}) when is_atom(m) and is_atom(f), do: apply(m, f, a)
  defp resolve_value(v), do: v
end
