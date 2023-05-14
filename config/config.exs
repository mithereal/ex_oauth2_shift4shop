import Config

config :ueberauth, Ueberauth,
  providers: [
    oauth2_shift4shop: {Shift4Shop.Strategy.Ueberauth, [request_path: "/auth/shift4shop", callback_path: "/auth/shift4shop/callback"]},
  ]
