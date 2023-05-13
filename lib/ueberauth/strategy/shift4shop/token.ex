defmodule Ueberauth.Strategy.Shift4Shop.Token do
  defstruct public_key: nil,
            time_stamp: nil,
            token_key: nil,
            action: nil,
            secure_url: nil,
            post_back_url: nil

  def decode(json) do
    json_library = Ueberauth.json_library()

    data = json_library.decode!(json)

    %__MODULE__{
      public_key: data["PublicKey"],
      time_stamp: data["TimeStamp"],
      token_key: data["TokenKey"],
      action: data["Action"],
      secure_url: data["SecureURL"],
      post_back_url: data["PostBackURL"]
    }
  end
end
