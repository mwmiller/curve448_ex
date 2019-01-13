defmodule Curve448.Mixfile do
  use Mix.Project

  def project do
    [
      app: :curve448,
      version: "1.0.3",
      elixir: "~> 1.7",
      name: "Curve448",
      source_url: "https://github.com/mwmiller/curve448_ex",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.18", only: :dev},
      {:credo, "~> 1.0", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Curve448 Diffie-Hellman functions
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Matt Miller", "Bram Verburg"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mwmiller/curve448_ex"}
    ]
  end
end
