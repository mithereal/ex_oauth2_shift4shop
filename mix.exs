defmodule Shift4Shop.Oauth2.Mixfile do
  use Mix.Project

  @version "1.2.2"
  @url "https://github.com/mithereal/ex_oauth2_shift4shop"

  def project do
    [
      app: :oauth2_shift4shop,
      version: @version,
      elixir: "~> 1.3",
      name: "Shift4Shop Oauth2 Strategies",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @url,
      homepage_url: @url,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      xref: [
        exclude: [:certifi, :httpc, Mint.HTTP, JOSE.JWT, JOSE.JWK, JOSE.JWS, :ssl_verify_hostname]
      ]
    ]
  end

  def application do
    [applications: [:logger, :ueberauth, :oauth2, :crypto, :public_key]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ueberauth, "~> 0.7.0"},
      {:jason, "~> 1.0"},
      {:credo, "~> 1.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:test_server, "~> 0.1.0", only: :test},
      {:bandit, ">= 0.0.0", only: :test},
      {:assent, "~> 0.2.3", optional: true},
      {:jose, "~> 1.8", optional: true},
      {:mint, "~> 1.0", optional: true},
      {:castore, "~> 1.0", optional: true},
      {:certifi, ">= 0.0.0", optional: true},
      {:ssl_verify_fun, ">= 0.0.0", optional: true}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "A Uberauth/Assent strategy for Shift4Shop authentication."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Jason Clark"],
      licenses: ["MIT"],
      links: %{GitHub: @url}
    ]
  end
end
