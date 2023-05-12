defmodule Ueberauth.Strategy.Shift4Shop do
  @moduledoc """
  Shift4Shop Strategy for Überauth.
  """

  use Ueberauth.Strategy,
      uid_field: :userId,
      default_scope: "identify",
      send_redirect_uri: false,
      oauth2_module: Ueberauth.Strategy.Shift4Shop.OAuth

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for Shift4Shop authentication.
  """
  def handle_request!(conn) do
    opts =
      options_from_conn(conn)
      |> with_scopes(conn)
      |> with_state_param(conn)
      |> with_redirect_uri(conn)

    module = option(conn, :oauth2_module)
    redirect!(conn, apply(module, :authorize_url!, [opts]))
  end

  @doc false
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [redirect_uri: callback_url(conn)]

    module = option(conn, :oauth2_module)
    token = apply(module, :get_token!, [[code: code], opts])

    if token.access_token == nil do
      err = token.other_params[:error]
      desc = token.other_params[:error_description]
      set_errors!(conn, [error(err, desc)])
    else
      conn
      |> store_token(token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:shift4shop_token, nil)
    |> put_private(:shift4shop_user, nil)
  end

  # Store the token for later use.
  @doc false
  defp store_token(conn, token) do
    put_private(conn, :shift4shop_token, token)
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.shift4shop_user

    %Info{
      nickname: user["userId"]
    }
  end

  @doc """
  Includes the credentials from the Shift4Shop response.
  """
  def credentials(conn) do
    token = conn.private.shift4shop_token
    scopes = split_scopes(token)

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      token: token.access_token,
      refresh_token: token.refresh_token,
      scopes: scopes,
      other: %{
        expires: token.other_params["refresh_token_expires_in"]
      }
    }
  end

  @doc """
  Stores the raw information (the token and user)
  obtained from the Shift4Shop callback.
  """
  def extra(conn) do
    %{
      shift4shop_token: :token,
      shift4shop_user: :user
    }
    |> Enum.filter(fn {original_key, _} ->
      Map.has_key?(conn.private, original_key)
    end)
    |> Enum.map(fn {original_key, mapped_key} ->
      {mapped_key, Map.fetch!(conn.private, original_key)}
    end)
    |> Map.new()
    |> (&%Extra{raw_info: &1}).()
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.shift4shop_user[uid_field]
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  defp with_scopes(opts, conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)

    opts |> Keyword.put(:scope, scopes)
  end

  defp with_redirect_uri(opts, conn) do
    if option(conn, :send_redirect_uri) do
      opts |> Keyword.put(:redirect_uri, callback_url(conn))
    else
      opts
    end
  end

  defp options_from_conn(conn) do
    base_options = []
    request_options = conn.private[:ueberauth_request_options].options

    case {request_options[:client_id], request_options[:client_secret]} do
      {nil, _} -> base_options
      {_, nil} -> base_options
      {id, secret} -> [client_id: id, client_secret: secret] ++ base_options
    end
  end

  defp split_scopes(token) do
    (token.other_params["scope"] || "")
    |> String.split(" ")
  end
end
