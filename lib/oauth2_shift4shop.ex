defmodule Shift4Shop.Oauth2 do
  @moduledoc false

  def json_library() do
    Application.get_env(:oauth2_shift4shop, :json_library, Jason)
  end
end
