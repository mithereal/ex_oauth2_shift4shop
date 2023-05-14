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
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client
    |> request_headers(token)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token!(params \\ [], opts \\ []) do
    client(opts)
    |> OAuth2.Client.get_token!(params)
  end

  defp request_headers(client, token) do
    client
    |> put_header("Accept", "application/json")
    |> put_header("Content-Type", "application/json")
    |> put_header("SecureURL", token.secure_uri)
    |> put_header("PrivateKey", client.private_key)
    |> put_header("Token", Jason.encode(token))
  end

  defp code_headers(client, code) do
    case client.postback_uri do
      nil -> client
      data -> put_param(client, :postback_uri, data)
    end
    |> put_header("Accept", "application/json")
    |> put_header("Content-Type", "application/x-www-form-urlencoded")
    |> put_param(:code, code)
    |> put_param(:grant_type, "authorization_code")
    |> put_param(:client_id, client.client_id)
    |> put_param(:client_secret, client.client_secret)
    |> put_param(:redirect_uri, client.redirect_uri)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    {code, params} = Keyword.pop(params, :code, client.params["code"])

    unless code do
      raise OAuth2.Error, reason: "Missing required key `code` for `#{inspect(__MODULE__)}`"
    end

    code_headers(client, code)
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
