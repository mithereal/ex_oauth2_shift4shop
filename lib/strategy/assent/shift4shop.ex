defmodule Shift4Shop.Strategy.Assent do
  @moduledoc """
  Shift4Shop Strategy for Assent.
  """
  @behaviour Assent.Strategy

  alias Shift4Shop.Strategy.OAuth2

  @spec authorize_url(Keyword.t()) :: {:ok, %{url: binary()}} | {:error, term()}
  def authorize_url(config) do
    OAuth2.authorize_url!(config)
  end

  @spec callback(Keyword.t(), map()) :: {:ok, %{user: map(), token: map()}} | {:error, term()}
  def callback(config, params) do
    OAuth2.get_token!(config, params)
  end
end
