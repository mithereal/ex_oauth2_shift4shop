import Config

config :ueberauth, Ueberauth,
  providers: [
    oauth2_shift4shop: {Shift4Shop.Strategy.Ueberauth, [request_path: "/auth/shift4shop", callback_path: "/auth/shift4shop/callback"]},
  ]

config :ueberauth, Shift4Shop.Strategy.Ueberauth,
       client_id: System.get_env("SHIFT4SHOP_CLIENT_ID"),
       client_secret: System.get_env("SHIFT4SHOP_CLIENT_SECRET"),
       redirect_uri: "https://devportal.3dcart.com/oauth.asp"
