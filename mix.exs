defmodule Month.MixProject do
  use Mix.Project

  @version "1.0.1"

  def project do
    [
      app: :month,
      version: @version,
      elixir: "~> 1.3",
      name: "Month",
      description: "Library focused on working with months, rathen than full dates or dates with time.",
      deps: [
        {:ex_doc, "~> 0.18", only: :dev, runtime: false}
      ],
      package: [
        maintainers: ["Svilen Gospodinov <svilen@heresy.io>"],
        licenses: ["MIT"],
        links: %{Github: "https://github.com/heresydev/month"}
      ],
      docs: [
        main: "Month",
        canonical: "http://hexdocs.pm/month",
        source_url: "https://github.com/heresydev/month",
        source_ref: @version
      ]
    ]
  end
end
