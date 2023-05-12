defmodule Ueberauth.Strategy.Shift4Shop.OAuth do
  @moduledoc """
  An implementation of OAuth2 for Shift4Shop.

  To add your `:client_id` and `:client_secret` include these values in your
  configuration:

      config :ueberauth, Ueberauth.Strategy.Shift4Shop.OAuth,
        client_id: System.get_env("Shift4Shop_CLIENT_ID"),
        client_secret: System.get_env("Shift4Shop_CLIENT_SECRET")

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
    config = Application.get_env(:ueberauth, __MODULE__, [])

    opts =
      @defaults
      |> Keyword.merge(opts)
      |> Keyword.merge(config)
      |> resolve_values()

    json_library = Ueberauth.json_library()

    OAuth2.Client.new(opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    json_library = Ueberauth.json_library()

    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token!(params \\ [], opts \\ []) do
    client =
      client(opts)
      |> OAuth2.Client.get_token(params)

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

  # Strategy Callbacks

  def authorize_url(client, params) do
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
