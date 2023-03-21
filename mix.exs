defmodule Franklin.MixProject do
  use Mix.Project

  def project do
    [
      app: :franklin,
      version: "0.1.0",
      elixir: "~> 1.14.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # ExDoc Related Configuration
      name: "Franklin",
      source_url: "https://github.com/zorn/franklin",
      homepage_url: "https://github.com/zorn/franklin",
      docs: docs(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Franklin.Application, []},
      extra_applications: [:logger, :runtime_tools, :eventstore, :crypto, :yaml_front_matter]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Core Phoenix Deps
      {:ecto_sql, "~> 3.6"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:finch, "~> 0.14"},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:phoenix, "~> 1.7.1"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},

      # To help build the HTML documentation.
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},

      # Commanded is the CQRS library we are building on.
      {:commanded, "~> 1.3"},
      {:commanded_eventstore_adapter, "~> 1.2"},
      {:cors_plug, "~> 3.0"},
      {:commanded_ecto_projections, "~> 1.2"},

      # To help us build with TDD.
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},

      # For frontend styling.
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},

      # For component management.
      {:phoenix_storybook, "~> 0.5.0"},

      # To help generate some fake test data.
      {:faker, "~> 0.17", only: :test},

      # To help keep repetitive maps shorter in tests.
      {:shorter_maps, "~> 2.0"},

      # Static analysis
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},

      # To render markdown content
      {:earmark, "~> 1.4"},

      # To help process historical content for seeds and imports.
      {:yaml_front_matter, "~> 1.0.0"},

      # To help generate valid URL slugs.
      {:slugify, "~> 1.3"},

      # To help with generating RSS feeds.
      {:xml_builder, "~> 2.1"},

      # For S3 uploads.
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.15"},
      {:sweet_xml, "~> 0.6"},

      # GitHub-like components to help style the admin.
      # {:primer_live, "~> 0.2.2"}
      {:primer_live, git: "https://github.com/zorn/primer_live", branch: "zorn-phoenix-html-update"}
    ]
  end

  defp docs do
    [
      main: "Franklin",
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "decisions/about.md",
      "decisions/datetime_column_types.md",
      "decisions/s3_will_not_enforce_file_constraints.md",
      "guides/testing_values.md"
    ]
  end

  defp groups_for_extras do
    [
      Guides: ~r/guides\/[^\/]+\.md/,
      Decisions: ~r/decisions\/[^\/]+\.md/
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "event_store.setup", "ecto.setup", "assets.setup", "assets.build"],
      "event_store.setup": ["event_store.create", "event_store.init"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      reset_databases: ["event_store.reset", "ecto.reset"],
      "event_store.reset": ["event_store.drop", "event_store.setup"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      lint: ["credo --strict", "dialyzer"]
    ]
  end
end
