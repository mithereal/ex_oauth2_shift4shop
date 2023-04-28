
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ueberauth_shift4shop/)
[![Hex.pm](https://img.shields.io/hexpm/dt/ueberauth_shift4shop.svg)](https://hex.pm/packages/ueberauth_shift4shop)
[![License](https://img.shields.io/hexpm/l/ueberauth_shift4shop.svg)](https://github.com/mithereal/ueberauth_shift4shop/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/mithereal/ueberauth_shift4shop.svg)](https://github.com/mithereal/ueberauth_shift4shop/commits/master)

# Überauth Shift4Shop

> Shift4Shop OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [Shift4Shop Developers](https://devportal.3dcart.com/).

1. Add `:ueberauth_shift4shop` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_shift4shop, "~> 1.0.0"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_shift4shop]]
    end
    ```

1. Add Shift4Shop to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        ameritrade: {Ueberauth.Strategy.Shift4Shop, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Shift4Shop.OAuth,
      client_id: System.get_env("SWIFT4SHOP_KEY")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

    And make sure to set the correct redirect URI(s) in your Shift4Shop application to wire up the callback.

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initialize the request through:

    /auth/td


You must use something other than Shift4Shop in the callback routes, I use /auth/td see below:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    ameritrade: {Ueberauth.Strategy.Shift4Shop,  [request_path: "/auth/swift4shop", callback_path: "/auth/swift4shop/callback"]}
  ]
```


## License

Please see [LICENSE](https://github.com/mithereal/ueberauth_shift4shop/blob/master/LICENSE) for licensing details.
