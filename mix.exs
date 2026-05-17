defmodule AdyenClient.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/iamkanishka/adyen_client"
  @description """
  Production-grade Elixir client for the Adyen Payments Platform.
  Covers all 200+ API endpoints, every webhook event type, and includes
  automatic retry, circuit breaker, rate limiting, and Plug webhook integration.
  """

  def project do
    [
      app: :adyen_client,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Hex package
      description: @description,
      package: package(),

      # ExDoc
      name: "AdyenClient",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),

      # Test coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "test.all": :test
      ],

      # Dialyzer
      dialyzer: [
        plt_core_path: "priv/plts/core",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix, :ex_unit],
        flags: [
          :error_handling,
          :missing_return,
          :extra_return,
          :underspecs,
          :unknown
        ],
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {AdyenClient.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # HTTP client
      {:req, "~> 0.4"},

      # JSON
      {:jason, "~> 1.4"},

      # Telemetry
      {:telemetry, "~> 1.2"},
      {:telemetry_metrics, "~> 0.6", optional: true},

      # Config validation
      {:nimble_options, "~> 1.0"},

      # Webhook Plug integration (optional — only needed if using AdyenClient.Webhooks.Plug)
      {:plug, "~> 1.15", optional: true},

      # Dev tooling
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # Test tooling
      {:excoveralls, "~> 0.18", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.1", only: :test},
      {:stream_data, "~> 0.6", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "deps.compile"],
      lint: ["format --check-formatted", "credo --strict", "dialyzer"],
      "lint.ci": ["format --check-formatted", "credo --strict --format json", "dialyzer --quiet"],
      "test.all": ["test --cover"],
      "test.ci": ["coveralls.html"],
      "dialyzer.build": ["dialyzer --plt"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Adyen API Explorer" => "https://docs.adyen.com/api-explorer/",
        "Adyen Developer Docs" => "https://docs.adyen.com/"
      },
      maintainers: ["Your Name"],
      files: ~w(
        lib
        .formatter.exs
        .dialyzer_ignore.exs
        mix.exs
        README.md
        LICENSE
        CHANGELOG.md
      )
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "USAGE_GUIDE.md",
        "guides/configuration.md",
        "guides/webhooks.md",
        "guides/error_handling.md",
        "guides/telemetry.md"
      ],
      groups_for_extras: [
        Guides: ~r/guides\//
      ],
      groups_for_modules: [
        Core: [
          AdyenClient,
          AdyenClient.Application,
          AdyenClient.Client,
          AdyenClient.Config,
          AdyenClient.Error,
          AdyenClient.Telemetry
        ],
        Infrastructure: [
          AdyenClient.CircuitBreaker,
          AdyenClient.RateLimiter,
          AdyenClient.Application
        ],
        "Online Payments — Checkout": [
          AdyenClient.Checkout.Sessions,
          AdyenClient.Checkout.Payments,
          AdyenClient.Checkout.Modifications,
          AdyenClient.Checkout.PaymentLinks,
          AdyenClient.Checkout.Recurring,
          AdyenClient.Checkout.Orders,
          AdyenClient.Checkout.Donations,
          AdyenClient.Checkout.Utility
        ],
        "Online Payments — Supporting": [
          AdyenClient.BinLookup,
          AdyenClient.Disputes,
          AdyenClient.Recurring,
          AdyenClient.Payout
        ],
        "In-Person Payments": [
          AdyenClient.Terminal,
          AdyenClient.CloudDevice,
          AdyenClient.SoftPOS,
          AdyenClient.PaymentsApp,
          AdyenClient.Management.PosMobile,
          AdyenClient.Management.TerminalManagement
        ],
        Management: [
          AdyenClient.Management.Companies,
          AdyenClient.Management.Merchants,
          AdyenClient.Management.Stores,
          AdyenClient.Management.Users,
          AdyenClient.Management.ApiCredentials,
          AdyenClient.Management.AllowedOrigins,
          AdyenClient.Management.Webhooks,
          AdyenClient.Management.PaymentMethods,
          AdyenClient.Management.PayoutSettings,
          AdyenClient.Management.Terminals,
          AdyenClient.Management.TerminalOrders,
          AdyenClient.Management.TerminalSettings,
          AdyenClient.Management.AndroidFiles,
          AdyenClient.Management.SplitConfigurations,
          AdyenClient.BalanceControl
        ],
        "Platforms — KYC & Onboarding": [
          AdyenClient.LegalEntity
        ],
        "Platforms — Balance Platform": [
          AdyenClient.BalancePlatform,
          AdyenClient.BalancePlatform.AccountHolders,
          AdyenClient.BalancePlatform.TransactionRules,
          AdyenClient.BalancePlatform.WebhookSettings,
          AdyenClient.BalancePlatform.PaymentInstrumentGroups,
          AdyenClient.BalancePlatform.SCADevices,
          AdyenClient.BalancePlatform.SCAAssociations,
          AdyenClient.BalancePlatform.TransferLimits,
          AdyenClient.SessionAuth
        ],
        "Platforms — Transfers & Capital": [
          AdyenClient.Transfers,
          AdyenClient.Capital,
          AdyenClient.RaiseDisputes,
          AdyenClient.ForeignExchange,
          AdyenClient.OpenBanking
        ],
        "Classic APIs": [
          AdyenClient.ClassicPayments,
          AdyenClient.ClassicPlatforms.Account,
          AdyenClient.ClassicPlatforms.Fund,
          AdyenClient.ClassicPlatforms.HOP,
          AdyenClient.ClassicPlatforms.NotificationConfiguration
        ],
        Webhooks: [
          AdyenClient.Webhooks,
          AdyenClient.Webhooks.Handler,
          AdyenClient.Webhooks.HMAC,
          AdyenClient.Webhooks.Plug
        ]
      ]
    ]
  end
end
