# AdyenClient — Complete Usage Guide

This guide covers every API area, configuration option, error handling pattern,
webhook integration, and operational concern for `AdyenClient`.

---

## Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Error Handling](#error-handling)
4. [Online Payments — Checkout](#online-payments--checkout)
5. [Modifications (Capture, Refund, Cancel)](#modifications)
6. [Payment Links](#payment-links)
7. [Recurring / Token Management](#recurring--token-management)
8. [Orders & Donations](#orders--donations)
9. [BinLookup](#binlookup)
10. [Disputes (Merchant-side)](#disputes-merchant-side)
11. [Classic Payments API](#classic-payments-api)
12. [In-Person Payments — Terminal](#in-person-payments--terminal)
13. [In-Person Payments — Cloud Device](#in-person-payments--cloud-device)
14. [SoftPOS & Payments App](#softpos--payments-app)
15. [Management API](#management-api)
16. [Balance Control](#balance-control)
17. [Foreign Exchange](#foreign-exchange)
18. [Platforms — Legal Entity (KYC)](#platforms--legal-entity-kyc)
19. [Platforms — Balance Platform](#platforms--balance-platform)
20. [Platforms — Transfers](#platforms--transfers)
21. [Platforms — Capital](#platforms--capital)
22. [Platforms — Raise Disputes](#platforms--raise-disputes)
23. [Open Banking](#open-banking)
24. [Classic Platforms](#classic-platforms)
25. [Webhooks](#webhooks)
26. [Telemetry](#telemetry)
27. [Reliability Features](#reliability-features)
28. [Development & Tooling](#development--tooling)
29. [API Coverage Reference](#api-coverage-reference)

---

## Installation

```elixir
# mix.exs
def deps do
  [
    {:adyen_client, "~> 1.0"},
    {:plug, "~> 1.15"}   # only if using AdyenClient.Webhooks.Plug
  ]
end
```

```bash
mix deps.get
```

---

## Configuration

### Application config

```elixir
# config/config.exs
config :adyen_client,
  api_key:                        System.get_env("ADYEN_API_KEY"),
  environment:                    :test,           # :test | :live
  merchant_account:               "YourMerchantECOM",
  timeout:                        30_000,          # HTTP receive timeout (ms)
  connect_timeout:                10_000,          # TCP connect timeout (ms)
  max_retries:                    3,               # retries on 5xx / 429
  retry_delay:                    500,             # initial backoff ms (doubles)
  webhook_hmac_key:               System.get_env("ADYEN_HMAC_KEY"),
  checkout_api_version:           "72",
  management_api_version:         "3",
  balance_platform_api_version:   "2",
  transfer_api_version:           "4",
  legal_entity_api_version:       "4",
  capital_api_version:            "1"

# config/prod.exs
config :adyen_client,
  environment: :live
```

### Runtime / per-call override

```elixir
secondary_config = AdyenClient.Config.load!(%{
  api_key: System.get_env("ADYEN_SECONDARY_KEY"),
  environment: :live,
  merchant_account: "SecondaryMerchant"
})

AdyenClient.Checkout.Sessions.create(%{...}, config: secondary_config)
```

### All config keys

| Key | Default | Description |
|---|---|---|
| `api_key` | — | **Required.** Adyen API key (`X-API-Key` header) |
| `environment` | `:test` | `:test` or `:live` |
| `merchant_account` | `nil` | Default merchant account code |
| `timeout` | `30_000` | HTTP receive timeout (ms) |
| `connect_timeout` | `10_000` | TCP connect timeout (ms) |
| `max_retries` | `3` | Max retry attempts on 5xx / 429 |
| `retry_delay` | `500` | Initial retry backoff (ms); doubles each attempt |
| `webhook_hmac_key` | `nil` | HMAC key for webhook validation |
| `checkout_api_version` | `"72"` | Checkout API version |
| `management_api_version` | `"3"` | Management API version |
| `balance_platform_api_version` | `"2"` | Balance Platform API version |
| `transfer_api_version` | `"4"` | Transfers API version |
| `legal_entity_api_version` | `"4"` | Legal Entity API version |
| `capital_api_version` | `"1"` | Capital API version |
| `bin_lookup_api_version` | `"54"` | BinLookup API version |
| `disputes_api_version` | `"30"` | Disputes API version |
| `payout_api_version` | `"68"` | Payout API version |
| `recurring_api_version` | `"68"` | Recurring API version |
| `classic_payment_api_version` | `"68"` | Classic Payments API version |
| `classic_account_api_version` | `"6"` | Classic Account API version |
| `classic_fund_api_version` | `"6"` | Classic Fund API version |
| `cloud_device_api_version` | `"1"` | Cloud Device API version |
| `foreign_exchange_api_version` | `"1"` | FX API version |
| `open_banking_api_version` | `"1"` | Open Banking API version |

---

## Error Handling

Every function returns `{:ok, response_body}` or `{:error, %AdyenClient.Error{}}`.
No exceptions are raised.

### Pattern match on error type

```elixir
case AdyenClient.Checkout.Payments.create(params) do
  {:ok, %{"resultCode" => "Authorised"} = resp} ->
    {:ok, resp["pspReference"]}

  {:ok, %{"resultCode" => "RedirectShopper"} = resp} ->
    {:redirect, resp["action"]["url"]}

  {:ok, %{"resultCode" => "IdentifyShopper"} = resp} ->
    {:continue_3ds2, resp}

  {:error, %AdyenClient.Error{type: :auth_error}} ->
    Logger.error("[Adyen] Invalid API key — check config :api_key")
    {:error, :configuration}

  {:error, %AdyenClient.Error{type: :validation_error, error_code: code, message: msg}} ->
    Logger.warning("[Adyen] Validation #{code}: #{msg}")
    {:error, :invalid_params}

  {:error, %AdyenClient.Error{type: :rate_limited, retryable: true}} ->
    schedule_retry()

  {:error, %AdyenClient.Error{type: :server_error, retryable: true} = err} ->
    Logger.warning("[Adyen] 5xx: #{err.message}")
    schedule_retry()

  {:error, %AdyenClient.Error{type: :not_found}} ->
    {:error, :not_found}

  {:error, %AdyenClient.Error{type: :network_error}} ->
    {:error, :network_unavailable}
end
```

### Error struct fields

| Field | Type | Description |
|---|---|---|
| `type` | atom | See table below |
| `status` | integer \| nil | HTTP status code; nil for transport errors |
| `message` | string | Human-readable message |
| `error_code` | string \| nil | Adyen-specific error code |
| `psp_reference` | string \| nil | PSP reference if returned in error response |
| `raw` | map \| nil | Full raw response body |
| `retryable` | boolean | Whether retrying is appropriate |

### Error type reference

| `type` | HTTP status | `retryable` | When |
|---|---|---|---|
| `:auth_error` | 401, 403 | `false` | Bad API key or insufficient permissions |
| `:not_found` | 404 | `false` | Resource does not exist |
| `:validation_error` | 422 | `false` | Invalid request parameters |
| `:api_error` | 400–499 | `false` | Other client errors |
| `:rate_limited` | 429 | `true` | Too many requests |
| `:server_error` | 500–599 | `true` | Adyen server error |
| `:network_error` | — | `true` | TCP/TLS failure |
| `:timeout` | — | `true` | Request exceeded timeout |
| `:config_error` | — | `false` | Invalid configuration |
| `:webhook_validation_error` | — | `false` | HMAC mismatch or missing signature |

---

## Online Payments — Checkout

### Sessions (Drop-in / Components — recommended)

The sessions flow is the simplest integration. Adyen handles payment method selection,
authentication, and redirects on your behalf.

```elixir
{:ok, session} =
  AdyenClient.Checkout.Sessions.create(%{
    amount:          %{currency: "EUR", value: 1000},  # 10.00 EUR
    merchantAccount: "YourMerchantECOM",
    reference:       "order-1234",
    returnUrl:       "https://yourapp.com/checkout/result",
    countryCode:     "NL",
    shopperLocale:   "nl-NL",
    shopperEmail:    "customer@example.com",
    shopperReference: "shopper-456",
    # Optional — store the payment method for future use
    storePaymentMethod: true,
    recurringProcessingModel: "CardOnFile",
    lineItems: [
      %{
        id:            "prod-001",
        description:   "Blue T-Shirt",
        amountIncludingTax: 1000,
        quantity:      1
      }
    ]
  })

# session["id"] and session["sessionData"] go to your frontend
# Use Adyen Drop-in or Components to complete the payment
```

Get the result after the return redirect:

```elixir
{:ok, result} =
  AdyenClient.Checkout.Sessions.get(
    session_id,
    params["sessionResult"]   # query param from returnUrl
  )

case result["status"] do
  "completed" -> Orders.mark_paid(result["merchantReference"])
  "cancelled" -> Orders.mark_cancelled(result["merchantReference"])
  other       -> Logger.info("Session status: #{other}")
end
```

### Advanced payment (API-only, no frontend SDK)

```elixir
# List available payment methods
{:ok, %{"paymentMethods" => methods}} =
  AdyenClient.Checkout.Payments.list_payment_methods(%{
    merchantAccount: "YourMerchantECOM",
    amount:          %{currency: "EUR", value: 1000},
    countryCode:     "NL",
    channel:         "Web"
  })

# Authorise a card payment
{:ok, result} =
  AdyenClient.Checkout.Payments.create(%{
    amount:          %{currency: "EUR", value: 1000},
    merchantAccount: "YourMerchantECOM",
    reference:       "order-1234",
    returnUrl:       "https://yourapp.com/result",
    channel:         "Web",
    paymentMethod: %{
      type:                    "scheme",
      encryptedCardNumber:     "adyenjs_0_1_25$...",
      encryptedExpiryMonth:    "adyenjs_0_1_25$...",
      encryptedExpiryYear:     "adyenjs_0_1_25$...",
      encryptedSecurityCode:   "adyenjs_0_1_25$..."
    },
    browserInfo: %{
      userAgent:     "Mozilla/5.0 ...",
      acceptHeader:  "*/*",
      language:      "nl-NL",
      colorDepth:    24,
      screenHeight:  723,
      screenWidth:   1536,
      timeZoneOffset: -120,
      javaEnabled:   false
    },
    additionalData: %{
      "allow3DS2" => "true"
    }
  })

# Handle result codes
case result["resultCode"] do
  "Authorised"       -> handle_success(result["pspReference"])
  "RedirectShopper"  -> redirect_to(result["action"]["url"])
  "IdentifyShopper"  -> run_3ds2_fingerprint(result)
  "ChallengeShopper" -> run_3ds2_challenge(result)
  "Refused"          -> handle_refused(result["refusalReasonCode"])
  "Error"            -> handle_error(result)
end
```

Submit 3DS details after redirect:

```elixir
{:ok, result} =
  AdyenClient.Checkout.Payments.submit_details(%{
    paymentData: session["paymentData"],
    details:     %{"redirectResult" => params["redirectResult"]}
  })
```

Get card BIN details:

```elixir
{:ok, card_info} =
  AdyenClient.Checkout.Payments.get_card_details(%{
    merchantAccount: "YourMerchantECOM",
    cardNumber:      "411111"
  })

# card_info["brands"] — list of card brands for this BIN
```

---

## Modifications

```elixir
# Capture (for manual capture merchants)
{:ok, capture} =
  AdyenClient.Checkout.Modifications.capture("ORIGINAL-PSP-REF", %{
    merchantAccount: "YourMerchantECOM",
    amount:          %{currency: "EUR", value: 1000}
  })
# capture["status"] == "received"

# Partial refund
{:ok, _} =
  AdyenClient.Checkout.Modifications.refund("CAPTURED-PSP-REF", %{
    merchantAccount: "YourMerchantECOM",
    amount:          %{currency: "EUR", value: 500},
    reference:       "refund-order-1234"
  })

# Cancel an authorisation (before capture)
{:ok, _} =
  AdyenClient.Checkout.Modifications.cancel("AUTH-PSP-REF", %{
    merchantAccount: "YourMerchantECOM"
  })

# Cancel or refund — works regardless of state
{:ok, _} =
  AdyenClient.Checkout.Modifications.reverse("PSP-REF", %{
    merchantAccount: "YourMerchantECOM"
  })

# Cancel when you only have your own reference (no PSP ref yet)
{:ok, _} =
  AdyenClient.Checkout.Modifications.cancel_by_reference(%{
    merchantAccount: "YourMerchantECOM",
    reference:       "order-1234"
  })

# Adjust the authorised amount (tip, delayed charge, incremental auth)
{:ok, _} =
  AdyenClient.Checkout.Modifications.update_amount("PSP-REF", %{
    merchantAccount: "YourMerchantECOM",
    amount:          %{currency: "EUR", value: 1150},
    industryUsage:   "DelayedCharge"
  })
```

---

## Payment Links

```elixir
# Create
{:ok, link} =
  AdyenClient.Checkout.PaymentLinks.create(%{
    amount:          %{currency: "GBP", value: 2500},
    merchantAccount: "YourMerchantECOM",
    reference:       "invoice-999",
    returnUrl:       "https://yourapp.com/result",
    description:     "Invoice #999 — ACME Corp",
    expiresAt:       "2025-06-30T23:59:59Z",
    shopperEmail:    "billing@acme.com",
    reusable:        false
  })

IO.puts("Payment link: #{link["url"]}")

# Retrieve
{:ok, link} = AdyenClient.Checkout.PaymentLinks.get(link["id"])

# Expire it manually
{:ok, _} =
  AdyenClient.Checkout.PaymentLinks.update(link["id"], %{status: "expired"})
```

---

## Recurring / Token Management

```elixir
# Save card during a payment
{:ok, _result} =
  AdyenClient.Checkout.Payments.create(%{
    # ... required payment params ...
    shopperReference:         "shopper-456",
    storePaymentMethod:       true,
    recurringProcessingModel: "CardOnFile"   # or "Subscription", "UnscheduledCardOnFile"
  })

# List saved tokens
{:ok, %{"storedPaymentMethods" => tokens}} =
  AdyenClient.Checkout.Recurring.list_tokens(%{
    merchantAccount:  "YourMerchantECOM",
    shopperReference: "shopper-456"
  })

# Charge a saved token
{:ok, result} =
  AdyenClient.Checkout.Payments.create(%{
    amount:          %{currency: "EUR", value: 1000},
    merchantAccount: "YourMerchantECOM",
    reference:       "subscription-jan-2025",
    shopperReference: "shopper-456",
    paymentMethod: %{
      type:                       "scheme",
      storedPaymentMethodId:      tokens |> List.first() |> Map.get("id")
    },
    shopperInteraction:         "ContAuth",
    recurringProcessingModel:   "Subscription"
  })

# Delete a saved token
{:ok, _} = AdyenClient.Checkout.Recurring.delete_token("STORED-PM-ID")
```

---

## Orders & Donations

```elixir
# Check gift card balance
{:ok, balance} =
  AdyenClient.Checkout.Orders.get_balance(%{
    merchantAccount: "YourMerchantECOM",
    paymentMethod: %{
      type:   "giftcard",
      brand:  "svs",
      number: "6006491000000000000",
      cvc:    "737"
    }
  })

IO.puts("Balance: #{balance["balance"]["value"]} #{balance["balance"]["currency"]}")

# Create a partial payment order
{:ok, order} =
  AdyenClient.Checkout.Orders.create(%{
    amount:          %{currency: "EUR", value: 2000},
    merchantAccount: "YourMerchantECOM",
    reference:       "order-001"
  })

# Donation
{:ok, campaigns} = AdyenClient.Checkout.Donations.list_campaigns(%{
  merchantAccount: "YourMerchantECOM"
})

{:ok, _} =
  AdyenClient.Checkout.Donations.create(%{
    amount:          %{currency: "EUR", value: 100},
    merchantAccount: "YourMerchantECOM",
    donationAccount: campaigns |> List.first() |> Map.get("donationAccount"),
    reference:       "donation-order-001",
    paymentMethod:   %{type: "scheme", storedPaymentMethodId: "TOKEN_ID"},
    returnUrl:       "https://yourapp.com/result"
  })
```

---

## BinLookup

```elixir
# Check 3DS availability for a BIN
{:ok, availability} =
  AdyenClient.BinLookup.get_3ds_availability(%{
    merchantAccount: "YourMerchantECOM",
    cardNumber:      "411111",
    amount:          %{value: 1000, currency: "EUR"}
  })

# Get interchange fee estimate
{:ok, estimate} =
  AdyenClient.BinLookup.get_cost_estimate(%{
    merchantAccount: "YourMerchantECOM",
    amount:          %{value: 1000, currency: "EUR"},
    cardNumber:      "411111",
    assumptions:     %{assumeLevel3Data: true, assume3DS: true}
  })

IO.inspect(estimate["costEstimateAmount"])
```

---

## Disputes (Merchant-side)

```elixir
# Get defensible reason codes
{:ok, %{"defenseReasons" => reasons}} =
  AdyenClient.Disputes.get_applicable_defense_reasons(%{
    disputePspReference: "CHARGEBACK-PSP-REF",
    merchantAccountCode: "YourMerchantECOM"
  })

# Upload supporting evidence
{:ok, _} =
  AdyenClient.Disputes.supply_defense_document(%{
    disputePspReference: "CHARGEBACK-PSP-REF",
    merchantAccountCode: "YourMerchantECOM",
    defenseDocuments: [
      %{
        defenseDocumentType: "DefenseMaterial",
        content: Base.encode64(File.read!("evidence.pdf")),
        contentType: "application/pdf"
      }
    ]
  })

# Formally defend
{:ok, _} =
  AdyenClient.Disputes.defend(%{
    disputePspReference: "CHARGEBACK-PSP-REF",
    merchantAccountCode: "YourMerchantECOM",
    defenseReasonCode:   "SupplyDefenseMaterial"
  })

# Accept (waive defense)
{:ok, _} =
  AdyenClient.Disputes.accept(%{
    disputePspReference: "CHARGEBACK-PSP-REF",
    merchantAccountCode: "YourMerchantECOM"
  })
```

---

## Classic Payments API

For legacy integrations using the PAL API (v68). New integrations should use Checkout.

```elixir
# Authorise
{:ok, result} =
  AdyenClient.ClassicPayments.authorise(%{
    amount:          %{currency: "EUR", value: 1000},
    merchantAccount: "YourMerchantECOM",
    reference:       "order-1234",
    paymentMethod: %{
      type: "scheme",
      number: "4111111111111111",
      expiryMonth: "03",
      expiryYear: "2030",
      holderName: "John Smith",
      cvc: "737"
    }
  })

# 3DS2 flow
{:ok, auth_result} = AdyenClient.ClassicPayments.authorise3ds2(%{...})

# Capture
{:ok, _} =
  AdyenClient.ClassicPayments.capture(%{
    merchantAccount:    "YourMerchantECOM",
    originalReference:  result["pspReference"],
    modificationAmount: %{currency: "EUR", value: 1000}
  })

# Refund
{:ok, _} =
  AdyenClient.ClassicPayments.refund(%{
    merchantAccount:    "YourMerchantECOM",
    originalReference:  "PSP-REF",
    modificationAmount: %{currency: "EUR", value: 500}
  })
```

---

## In-Person Payments — Terminal

All 18 NEXO message types via the Terminal API sync endpoint.

```elixir
# Payment request
{:ok, result} =
  AdyenClient.Terminal.payment(%{
    "SaleToPOIRequest" => %{
      "MessageHeader" => %{
        "ProtocolVersion" => "3.0",
        "MessageClass"    => "Service",
        "MessageCategory" => "Payment",
        "MessageType"     => "Request",
        "SaleID"          => "POS-LANE-01",
        "ServiceID"       => "#{System.unique_integer([:positive])}",
        "POIID"           => "P400Plus-123456789"
      },
      "PaymentRequest" => %{
        "SaleData" => %{
          "SaleTransactionID" => %{
            "TransactionID" => "order-#{:os.system_time(:millisecond)}",
            "TimeStamp"     => DateTime.utc_now() |> DateTime.to_iso8601()
          }
        },
        "PaymentTransaction" => %{
          "AmountsReq" => %{
            "Currency"        => "EUR",
            "RequestedAmount" => 10.00
          }
        }
      }
    }
  })

# End-of-day reconciliation
{:ok, _} =
  AdyenClient.Terminal.reconciliation(%{
    "SaleToPOIRequest" => %{
      "MessageHeader" => %{
        "ProtocolVersion" => "3.0",
        "MessageClass"    => "Service",
        "MessageCategory" => "Reconciliation",
        "MessageType"     => "Request",
        "SaleID"          => "POS-LANE-01",
        "ServiceID"       => "reconcile-001",
        "POIID"           => "P400Plus-123456789"
      },
      "ReconciliationRequest" => %{
        "ReconciliationType" => "SaleReconciliation"
      }
    }
  })
```

---

## In-Person Payments — Cloud Device

```elixir
# Synchronous payment (blocks until terminal responds)
{:ok, result} =
  AdyenClient.CloudDevice.sync("YOUR_MERCHANT_ID", "P400Plus-123456789", %{
    "SaleToPOIRequest" => %{ ... }   # same NEXO structure as Terminal API
  })

# Check terminal connection status
{:ok, status} =
  AdyenClient.CloudDevice.get_status("YOUR_MERCHANT_ID", "P400Plus-123456789")

IO.puts("Status: #{status["status"]}")  # "Online" | "Offline"

# List all connected terminals
{:ok, devices} =
  AdyenClient.CloudDevice.list_connected("YOUR_MERCHANT_ID")
```

---

## SoftPOS & Payments App

```elixir
# SoftPOS — Tap to Pay on mobile
{:ok, session} =
  AdyenClient.SoftPOS.create_session(%{
    merchantAccount: "YourMerchantECOM",
    store:           "YOUR_STORE_REFERENCE"
    # certificate-based auth params per Adyen docs
  })

# Payments App — board a new Android terminal
{:ok, token} =
  AdyenClient.PaymentsApp.create_boarding_token_merchant(
    "YOUR_MERCHANT_ID",
    %{nexoVersion: "3.3.0"}
  )

# List installed Payments App instances
{:ok, apps} =
  AdyenClient.PaymentsApp.list_merchant("YOUR_MERCHANT_ID")
```

---

## Management API

### Company, Merchant & Store hierarchy

```elixir
# List all companies
{:ok, %{"data" => companies}} = AdyenClient.Management.Companies.list()

# Get all merchants under a company
{:ok, %{"data" => merchants}} =
  AdyenClient.Management.Companies.list_merchants("COMPANY_ID")

# Create a merchant account
{:ok, merchant} =
  AdyenClient.Management.Merchants.create(%{
    companyId:       "COMPANY_ID",
    legalEntityId:   "LE_ID",
    description:     "My ECOM Store"
  })

# Create a store
{:ok, store} =
  AdyenClient.Management.Stores.create("YOUR_MERCHANT_ID", %{
    reference:        "STORE_NL_001",
    shopperStatement: "My Amsterdam Store",
    tradingName:      "My Amsterdam Store",
    address: %{
      line1:      "Simon Carmiggeltstraat 6",
      city:       "Amsterdam",
      postalCode: "1011 DJ",
      country:    "NL"
    }
  })
```

### Webhook management

```elixir
# Create a standard webhook
{:ok, webhook} =
  AdyenClient.Management.Webhooks.create_merchant("YOUR_MERCHANT_ID", %{
    type:     "standard",
    url:      "https://yourapp.com/webhooks/adyen",
    username: "adyen_wh",
    password: "s3cr3t!",
    active:   true,
    additionalSettings: %{
      includeEventCodes: ["AUTHORISATION", "CAPTURE", "REFUND", "CHARGEBACK"]
    }
  })

# Generate the HMAC key and store it securely
{:ok, %{"hmacKey" => hmac_key}} =
  AdyenClient.Management.Webhooks.generate_merchant_hmac(
    "YOUR_MERCHANT_ID",
    webhook["id"]
  )

# Test the webhook
{:ok, _} =
  AdyenClient.Management.Webhooks.test_merchant(
    "YOUR_MERCHANT_ID",
    webhook["id"],
    %{types: ["AUTHORISATION"]}
  )
```

### Payout settings

```elixir
# Add a payout destination (bank transfer instrument)
{:ok, setting} =
  AdyenClient.Management.PayoutSettings.add("YOUR_MERCHANT_ID", %{
    enabled:              true,
    enabledFromDate:      "2024-01-01",
    transferInstrumentId: "TI_BANK_ACCOUNT_ID"
  })

# List all payout settings
{:ok, settings} = AdyenClient.Management.PayoutSettings.list("YOUR_MERCHANT_ID")

# Delete a setting
:ok =
  case AdyenClient.Management.PayoutSettings.delete("YOUR_MERCHANT_ID", setting["id"]) do
    {:ok, _} -> :ok
    {:error, err} -> {:error, err}
  end
```

### Payment methods

```elixir
# Get all enabled payment methods
{:ok, %{"data" => methods}} =
  AdyenClient.Management.PaymentMethods.list("YOUR_MERCHANT_ID")

# Request a new payment method (e.g. Klarna)
{:ok, request} =
  AdyenClient.Management.PaymentMethods.request("YOUR_MERCHANT_ID", %{
    type:     "klarna",
    currency: "EUR",
    country:  "NL"
  })
```

### Terminal settings

```elixir
# Company-level settings
{:ok, settings} =
  AdyenClient.Management.TerminalSettings.get_company_settings("COMPANY_ID")

# Merchant-level logo update
{:ok, _} =
  AdyenClient.Management.TerminalSettings.update_merchant_logo(
    "YOUR_MERCHANT_ID",
    %{data: Base.encode64(File.read!("logo.png"))}
  )

# Store-level settings (by merchant + store ref)
{:ok, _} =
  AdyenClient.Management.TerminalSettings.update_store_settings(
    "YOUR_MERCHANT_ID",
    "STORE_REF",
    %{receiptOptions: %{skipReceiptOptions: "askOnDevice"}}
  )

# Terminal-level logo (by store ID only path)
{:ok, _} =
  AdyenClient.Management.TerminalSettings.update_store_logo_by_id(
    "STORE_ID",
    %{data: Base.encode64(File.read!("store_logo.png"))}
  )

# Per-terminal settings
{:ok, _} =
  AdyenClient.Management.TerminalSettings.update_terminal_settings(
    "P400Plus-123456789",
    %{passcode: %{required: true}}
  )
```

---

## Balance Control

```elixir
# View balances for all merchants under a company
{:ok, overview} = AdyenClient.BalanceControl.company_balances("COMPANY_CODE")

# Transfer balance between merchant accounts
{:ok, _} =
  AdyenClient.BalanceControl.transfer(%{
    source:      %{merchantAccount: "MerchantA"},
    destination: %{merchantAccount: "MerchantB"},
    amount:      %{currency: "EUR", value: 10_000}
  })
```

---

## Foreign Exchange

```elixir
{:ok, result} =
  AdyenClient.ForeignExchange.calculate(%{
    baseAmount:      %{currency: "USD", value: 10_000},
    exchangeCurrency: "EUR"
  })

IO.inspect(result["exchangedAmount"])   # %{"currency" => "EUR", "value" => ...}
IO.inspect(result["exchangeRate"])
```

---

## Platforms — Legal Entity (KYC)

```elixir
# Create an individual legal entity
{:ok, le} =
  AdyenClient.LegalEntity.create(%{
    type: "individual",
    individual: %{
      name: %{firstName: "Jane", lastName: "Doe"},
      email: "jane@example.com",
      birthData: %{dateOfBirth: "1990-01-15"},
      nationalIDNumber: "123456789",
      residentialAddress: %{
        street:     "Simon Carmiggeltstraat 6-50",
        city:       "Amsterdam",
        postalCode: "1011 DJ",
        country:    "NL"
      }
    }
  })

# Upload an identity document
{:ok, _} =
  AdyenClient.LegalEntity.upload_document(%{
    attachment: %{
      content:     Base.encode64(File.read!("passport.jpg")),
      contentType: "image/jpeg"
    },
    document: %{
      type:           "PASSPORT",
      legalEntityId:  le["id"],
      issuerCountry:  "NL",
      expiryDate:     "2030-01-01"
    }
  })

# Check verification status
{:ok, errors} = AdyenClient.LegalEntity.check_verification_errors(le["id"])
IO.inspect(errors["invalidFields"])

# Accept Terms of Service
{:ok, tos_doc} =
  AdyenClient.LegalEntity.get_tos(le["id"], %{termsOfServiceDocumentFormat: "JSON"})

{:ok, _} =
  AdyenClient.LegalEntity.accept_tos(le["id"], tos_doc["id"], %{
    acceptedBy: "Jane Doe",
    ip:         "1.2.3.4"
  })

# Get hosted onboarding link
{:ok, %{"url" => onboarding_url}} =
  AdyenClient.LegalEntity.get_onboarding_link(le["id"], %{
    returnUrl: "https://yourapp.com/onboarding/done"
  })
```

---

## Platforms — Balance Platform

```elixir
# Full onboarding flow: legal entity → account holder → balance account → card

{:ok, le}      = AdyenClient.LegalEntity.create(%{ ... })
{:ok, holder}  = AdyenClient.BalancePlatform.create_account_holder(%{legalEntityId: le["id"]})
{:ok, account} = AdyenClient.BalancePlatform.create_balance_account(%{accountHolderId: holder["id"]})

# Issue a physical card
{:ok, card} =
  AdyenClient.BalancePlatform.create_payment_instrument(%{
    balanceAccountId: account["id"],
    type:             "card",
    issuingCountryCode: "NL",
    card: %{
      formFactor: "physical",
      brand:      "mc",
      deliveryContact: %{
        name:    %{firstName: "Jane", lastName: "Doe"},
        address: %{
          street:     "Simon Carmiggeltstraat 6",
          city:       "Amsterdam",
          postalCode: "1011 DJ",
          country:    "NL"
        }
      }
    }
  })

# Set a daily spend limit
{:ok, _} =
  AdyenClient.BalancePlatform.create_transaction_rule(%{
    entityKey: %{
      entityType:      "paymentInstrument",
      entityReference: card["id"]
    },
    reference: "daily-eur-500",
    status:    "active",
    type:      "velocity",
    interval:  %{type: "daily"},
    maxAmount: %{currency: "EUR", value: 50_000}
  })

# Configure an automated top-up sweep
{:ok, _} =
  AdyenClient.BalancePlatform.create_sweep(account["id"], %{
    counterparty: %{merchantAccount: "YourMerchantECOM"},
    triggerAmount: %{currency: "EUR", value: 5_000},
    targetAmount:  %{currency: "EUR", value: 50_000},
    type:         "pull",
    schedule:     %{type: "daily", cronExpression: "0 08 * * *"}
  })

# Change a card PIN
{:ok, %{"publicKey" => rsa_key}} = AdyenClient.BalancePlatform.get_public_key()
# Encrypt the new PIN with rsa_key using the Adyen PIN encryption protocol
{:ok, _} =
  AdyenClient.BalancePlatform.change_pin(%{
    encryptedPin: "...",
    token:        card["id"]
  })

# Group instruments for shared rule application
{:ok, group} =
  AdyenClient.BalancePlatform.PaymentInstrumentGroups.create(%{
    balancePlatform: "YOUR_BALANCE_PLATFORM_ID",
    description:     "Corporate cards"
  })

# List transaction rules scoped to a balance account
{:ok, rules} =
  AdyenClient.BalancePlatform.TransactionRules.list_for_balance_account(account["id"])

# Balance webhook settings
{:ok, _} =
  AdyenClient.BalancePlatform.WebhookSettings.create(account["id"], %{
    url:    "https://yourapp.com/webhooks/balance",
    active: true
  })

# Register an SCA device
{:ok, device} =
  AdyenClient.BalancePlatform.SCADevices.begin_registration(%{
    paymentInstrumentId: card["id"],
    deviceFingerprint:   "..."
  })

{:ok, _} =
  AdyenClient.BalancePlatform.SCADevices.finish_registration(device["id"], %{
    registrationCode: "CODE-FROM-CARDHOLDER"
  })
```

---

## Platforms — Transfers

```elixir
# Internal transfer between balance accounts
{:ok, transfer} =
  AdyenClient.Transfers.create(%{
    amount:           %{currency: "EUR", value: 10_000},
    category:         "internal",
    balanceAccountId: "SOURCE_BA_ID",
    counterparty:     %{balanceAccountId: "DEST_BA_ID"},
    reference:        "settlement-001"
  })

# Bank transfer (payout)
{:ok, _} =
  AdyenClient.Transfers.create(%{
    amount:           %{currency: "EUR", value: 100_000},
    category:         "bank",
    balanceAccountId: "SOURCE_BA_ID",
    counterparty: %{
      bankAccount: %{
        iban:          "NL02ABNA0123456789",
        accountHolder: %{fullName: "Jane Doe", address: %{country: "NL"}}
      }
    },
    reference: "payout-2024-01"
  })

# Query transaction ledger with date range
{:ok, %{"data" => transactions}} =
  AdyenClient.Transfers.list_transactions(%{
    balanceAccountId: "BA_ID",
    createdSince:     "2024-01-01T00:00:00Z",
    createdUntil:     "2024-01-31T23:59:59Z",
    limit:            100,
    cursor:           nil
  })

# Return a transfer
{:ok, _} =
  AdyenClient.Transfers.return_transfer("TRANSFER_ID", %{
    amount:    %{currency: "EUR", value: 10_000},
    reference: "return-settlement-001"
  })
```

---

## Platforms — Capital

```elixir
# List available dynamic financing offers
{:ok, %{"dynamicOffers" => offers}} = AdyenClient.Capital.list_dynamic_offers()
offer = List.first(offers)

# Preview terms for a specific funding amount
{:ok, preview} =
  AdyenClient.Capital.calculate_dynamic_offer(offer["id"], %{
    grantAmount: %{currency: "EUR", value: 50_000_00}
  })

IO.inspect(preview["fee"], label: "Total fee")
IO.inspect(preview["repaymentPercentage"], label: "Daily repayment %")

# Convert preview to a committed offer
{:ok, static_offer} =
  AdyenClient.Capital.create_grant_offer(offer["id"], %{
    grantAmount: %{currency: "EUR", value: 50_000_00}
  })

# Accept and request the grant
{:ok, grant} =
  AdyenClient.Capital.request_grant(%{grantOfferId: static_offer["id"]})

IO.puts("Grant #{grant["id"]} status: #{grant["status"]}")

# Track disbursements and repayments
{:ok, disbursements} = AdyenClient.Capital.list_disbursements(grant["id"])
```

---

## Platforms — Raise Disputes

For **cardholders** disputing a card transaction (Balance Platform issuing side).

```elixir
# Raise a dispute
{:ok, dispute} =
  AdyenClient.RaiseDisputes.raise_dispute(%{
    paymentId: "PAY-ID-123",
    reason:    "itemNotReceived",
    description: "Ordered on 2024-01-10, never arrived."
  })

# Attach supporting evidence
{:ok, _} =
  AdyenClient.RaiseDisputes.add_attachment(dispute["id"], %{
    content:     Base.encode64(File.read!("screenshot.png")),
    contentType: "image/png",
    description: "Order confirmation screenshot"
  })

# Track open disputes
{:ok, %{"data" => disputes}} = AdyenClient.RaiseDisputes.list(%{status: "Open"})
```

---

## Open Banking

```elixir
# Initiate account verification
{:ok, %{"url" => verification_url}} =
  AdyenClient.OpenBanking.create_verification_routes(%{
    legalEntityId: "LE_ID",
    returnUrl:     "https://yourapp.com/openbanking/done"
  })

# Redirect user to verification_url, then retrieve result after callback
{:ok, report} = AdyenClient.OpenBanking.get_verification_report("VERIFICATION_CODE")
IO.inspect(report["status"])    # "valid" | "invalid"
```

---

## Classic Platforms

### Account API

```elixir
# Create an account holder (sub-merchant)
{:ok, holder} =
  AdyenClient.ClassicPlatforms.Account.create_account_holder(%{
    accountHolderCode: "SUBMERCHANT_001",
    accountHolderDetails: %{
      email:   "shop@example.com",
      webAddress: "https://example.com",
      individualDetails: %{
        name: %{firstName: "Jane", lastName: "Doe"}
      },
      address: %{country: "NL", city: "Amsterdam"}
    },
    legalEntity: "Individual",
    primaryCurrency: "EUR"
  })

# Upload KYC document
{:ok, _} =
  AdyenClient.ClassicPlatforms.Account.upload_document(%{
    accountHolderCode: "SUBMERCHANT_001",
    documentDetail: %{
      accountHolderCode: "SUBMERCHANT_001",
      documentType:      "PASSPORT",
      description:       "Passport copy"
    },
    documentContent: Base.encode64(File.read!("passport.jpg"))
  })
```

### Fund API

```elixir
# Check balances
{:ok, balances} =
  AdyenClient.ClassicPlatforms.Fund.account_holder_balance(%{
    accountHolderCode: "SUBMERCHANT_001"
  })

# Pay out to the sub-merchant
{:ok, _} =
  AdyenClient.ClassicPlatforms.Fund.payout_account_holder(%{
    accountHolderCode: "SUBMERCHANT_001",
    amount:            %{currency: "EUR", value: 50_000},
    description:       "Monthly payout"
  })

# Transfer between platform accounts
{:ok, _} =
  AdyenClient.ClassicPlatforms.Fund.transfer_funds(%{
    sourceAccountCode:      "PLATFORM_MAIN",
    destinationAccountCode: "SUBMERCHANT_001",
    transferCode:           "TRF-001",
    amount:                 %{currency: "EUR", value: 10_000}
  })
```

---

## Webhooks

### Implement the handler

```elixir
defmodule MyApp.AdyenHandler do
  @behaviour AdyenClient.Webhooks.Handler

  @impl true
  def handle_event("AUTHORISATION", %{"success" => "true"} = item) do
    Orders.mark_paid(item["merchantReference"], item["pspReference"])
    :ok
  end

  def handle_event("AUTHORISATION", %{"success" => "false"} = item) do
    Orders.mark_failed(item["merchantReference"], item["reason"])
    :ok
  end

  def handle_event("CAPTURE", item) do
    Orders.mark_captured(item["merchantReference"])
    :ok
  end

  def handle_event("REFUND", item) do
    Refunds.process(item["merchantReference"], item["pspReference"])
    :ok
  end

  def handle_event("CHARGEBACK", item) do
    Disputes.open(item)
    :ok
  end

  def handle_event("CHARGEBACK_REVERSED", item) do
    Disputes.close_won(item["merchantReference"])
    :ok
  end

  def handle_event("NOTIFICATION_OF_FRAUD", item) do
    Fraud.alert(item)
    :ok
  end

  def handle_event("REPORT_AVAILABLE", %{"additionalData" => %{"fileName" => file}} = _item) do
    Reports.enqueue_download(file)
    :ok
  end

  def handle_event(event_code, _item) do
    require Logger
    Logger.debug("[AdyenClient] Unhandled event: #{event_code}")
    :ok
  end
end
```

### Phoenix Plug integration

```elixir
# lib/my_app_web/endpoint.ex — add BEFORE Plug.Parsers
plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["*/*"],
  body_reader: {AdyenClient.Webhooks.Plug, :read_body, []},
  json_decoder: Jason

# lib/my_app_web/router.ex
scope "/" do
  forward "/webhooks/adyen", AdyenClient.Webhooks.Plug,
    handler:       MyApp.AdyenHandler,
    hmac_key:      System.get_env("ADYEN_HMAC_KEY"),
    validate_hmac: true      # set to false in :dev only
end
```

### Manual HMAC validation

```elixir
defmodule MyAppWeb.WebhookController do
  use MyAppWeb, :controller

  plug :verify_content_type

  def adyen(conn, _params) do
    {:ok, raw_body, conn} = Plug.Conn.read_body(conn)
    hmac_key = Application.fetch_env!(:adyen_client, :webhook_hmac_key)

    case AdyenClient.Webhooks.process(raw_body, hmac_key, MyApp.AdyenHandler) do
      :ok ->
        json(conn, %{notificationResponse: "[accepted]"})

      {:error, %AdyenClient.Error{type: :webhook_validation_error}} ->
        conn |> put_status(401) |> json(%{error: "invalid signature"})
    end
  end

  defp verify_content_type(conn, _opts) do
    if get_req_header(conn, "content-type") == ["application/json"] do
      conn
    else
      conn |> put_status(415) |> json(%{error: "unsupported media type"}) |> halt()
    end
  end
end
```

### Validate HMAC for Balance Platform webhooks

```elixir
# Balance Platform webhooks sign the full raw body
defmodule MyAppWeb.BalancePlatformWebhookController do
  use MyAppWeb, :controller

  def handle(conn, _params) do
    {:ok, raw_body, conn} = Plug.Conn.read_body(conn)
    received_hmac = get_req_header(conn, "hmacsignature") |> List.first()
    hmac_key = System.get_env("ADYEN_BALANCE_PLATFORM_HMAC_KEY")

    with :ok <- AdyenClient.Webhooks.HMAC.validate_balance_platform(raw_body, received_hmac, hmac_key),
         {:ok, payload} <- Jason.decode(raw_body) do
      dispatch_balance_platform_event(payload["type"], payload["data"])
      json(conn, %{})
    else
      {:error, err} ->
        conn |> put_status(401) |> json(%{error: err.message})
    end
  end

  defp dispatch_balance_platform_event("balancePlatform.transfer.created", data) do
    Transfers.handle_created(data)
  end

  defp dispatch_balance_platform_event(type, _data) do
    require Logger
    Logger.debug("[AdyenClient] Unhandled BP event: #{type}")
  end
end
```

---

## Telemetry

```elixir
# lib/my_app/application.ex
def start(_type, _args) do
  :telemetry.attach_many(
    "adyen-client-instrumentation",
    [
      [:adyen_client, :request, :start],
      [:adyen_client, :request, :stop]
    ],
    &__MODULE__.handle_telemetry/4,
    nil
  )

  Supervisor.start_link(children(), opts())
end

def handle_telemetry([:adyen_client, :request, :start], _meas, meta, _cfg) do
  Logger.debug("[Adyen →] #{meta.method} #{meta.url}")
end

def handle_telemetry([:adyen_client, :request, :stop], %{duration: dur}, meta, _cfg) do
  ms = System.convert_time_unit(dur, :native, :millisecond)

  if meta.status == :error do
    Logger.warning("[Adyen ✗] #{meta.method} #{meta.url} #{ms}ms status=#{meta.http_status}")
  else
    Logger.debug("[Adyen ✓] #{meta.method} #{meta.url} #{ms}ms")
  end

  # Report to your metrics backend
  :telemetry.execute(
    [:my_app, :adyen, :http_request],
    %{duration: ms},
    %{method: meta.method, status: meta.http_status, ok: meta.status == :ok}
  )
end
```

### Event reference

| Event | Measurements | Metadata |
|---|---|---|
| `[:adyen_client, :request, :start]` | `system_time` | `method`, `url`, `body` (PCI-field redacted) |
| `[:adyen_client, :request, :stop]` | `duration` (native units) | `method`, `url`, `status` (`:ok`\|`:error`), `http_status` |

---

## Reliability Features

### Automatic retry with exponential backoff

Retries automatically on HTTP 429 and 5xx responses.
The initial delay doubles each attempt:

```
attempt 0: immediate (first try)
attempt 1: 500ms delay
attempt 2: 1000ms delay
attempt 3: 2000ms delay
```

Configure via:

```elixir
config :adyen_client,
  max_retries: 3,
  retry_delay: 500
```

Non-retryable errors (4xx except 429) are **never** retried.

### Circuit breaker

`AdyenClient.CircuitBreaker` (GenServer) prevents retry storms:

| State | Behaviour | Transition |
|---|---|---|
| `:closed` | All requests pass through normally | → `:open` after 5 consecutive failures |
| `:open` | All requests immediately return `{:error, :circuit_open}` | → `:half_open` after 30s |
| `:half_open` | One probe request allowed | → `:closed` on success, `:open` on failure |

### Token-bucket rate limiter

`AdyenClient.RateLimiter` (GenServer) enforces API rate limits:

- 100 requests/second sustained rate
- Burst capacity of 200 requests
- Callers block (never dropped) until a token is available

### Idempotency keys

Every `POST` request automatically includes a randomly generated
`Idempotency-Key` header. Override when replaying a specific request:

```elixir
AdyenClient.Checkout.Modifications.capture(psp_ref, params,
  idempotency_key: "capture-#{order_id}-attempt-2"
)
```

---

## Development & Tooling

### Setup

```bash
git clone https://github.com/your-org/adyen_client
cd adyen_client
mix setup      # mix deps.get && mix deps.compile
```

### Running tests

```bash
mix test                    # all tests
mix test.all                # tests + coverage
mix coveralls.html          # HTML coverage report
```

### Linting & type checking

```bash
mix format                  # auto-format
mix format --check-formatted  # CI format check
mix credo --strict          # static analysis
mix dialyzer.build          # build PLT (~5 min, one-time)
mix dialyzer                # type checking
mix lint                    # format + credo + dialyzer (all at once)
```

### CI pipeline

```bash
mix lint.ci                 # format check + credo JSON + dialyzer quiet
mix test.ci                 # coveralls.html
```

### Environment variables

```bash
ADYEN_API_KEY=test_...
ADYEN_HMAC_KEY=44782DEF...
ADYEN_MERCHANT_ACCOUNT=TestMerchantECOM
```

---

## API Coverage Reference

### Modules at a glance

| Module | API | Endpoints |
|---|---|---|
| `AdyenClient.Checkout.Sessions` | Checkout v72 | 2 |
| `AdyenClient.Checkout.Payments` | Checkout v72 | 4 |
| `AdyenClient.Checkout.Modifications` | Checkout v72 | 6 |
| `AdyenClient.Checkout.PaymentLinks` | Checkout v72 | 3 |
| `AdyenClient.Checkout.Recurring` | Checkout v72 | 4 |
| `AdyenClient.Checkout.Orders` | Checkout v72 | 3 |
| `AdyenClient.Checkout.Donations` | Checkout v72 | 2 |
| `AdyenClient.Checkout.Utility` | Checkout v72 | 4 |
| `AdyenClient.BinLookup` | BinLookup v54 | 2 |
| `AdyenClient.Disputes` | Disputes v30 | 5 |
| `AdyenClient.Recurring` | Recurring v68 | 6 |
| `AdyenClient.Payout` | Payout v68 | 6 |
| `AdyenClient.Terminal` | Terminal v1 | 18 |
| `AdyenClient.CloudDevice` | Cloud Device v1 | 4 |
| `AdyenClient.SoftPOS` | SoftPOS v3 | 1 |
| `AdyenClient.PaymentsApp` | Payments App v1 | 5 |
| `AdyenClient.Management.Companies` | Management v3 | 3 |
| `AdyenClient.Management.Merchants` | Management v3 | 4 |
| `AdyenClient.Management.Stores` | Management v3 | 8 |
| `AdyenClient.Management.Users` | Management v3 | 8 |
| `AdyenClient.Management.ApiCredentials` | Management v3 | 15 |
| `AdyenClient.Management.AllowedOrigins` | Management v3 | 6 |
| `AdyenClient.Management.PayoutSettings` | Management v3 | 5 |
| `AdyenClient.Management.Webhooks` | Management v3 | 14 |
| `AdyenClient.Management.PaymentMethods` | Management v3 | 6 |
| `AdyenClient.Management.Terminals` | Management v3 | 4 |
| `AdyenClient.Management.TerminalOrders` | Management v3 | 20 |
| `AdyenClient.Management.TerminalSettings` | Management v3 | 20 |
| `AdyenClient.Management.AndroidFiles` | Management v3 | 6 |
| `AdyenClient.Management.SplitConfigurations` | Management v3 | 9 |
| `AdyenClient.Management.PosMobile` | possdk v68 | 1 |
| `AdyenClient.Management.TerminalManagement` | postfmapi v1 | 5 |
| `AdyenClient.BalanceControl` | Balance Control v2 | 3 |
| `AdyenClient.ForeignExchange` | FX v1 | 1 |
| `AdyenClient.LegalEntity` | LEM v4 | 27 |
| `AdyenClient.BalancePlatform` | BCL v2 | 45 |
| `AdyenClient.BalancePlatform.AccountHolders` | BCL v2 | 1 |
| `AdyenClient.BalancePlatform.TransactionRules` | BCL v2 | 5 |
| `AdyenClient.BalancePlatform.WebhookSettings` | BCL v2 | 5 |
| `AdyenClient.BalancePlatform.PaymentInstrumentGroups` | BCL v2 | 2 |
| `AdyenClient.BalancePlatform.SCADevices` | BCL v2 | 3 |
| `AdyenClient.BalancePlatform.SCAAssociations` | BCL v2 | 3 |
| `AdyenClient.BalancePlatform.TransferLimits` | BCL v2 | 6 |
| `AdyenClient.SessionAuth` | Session Auth v1 | 1 |
| `AdyenClient.Transfers` | Transfers v4 | 9 |
| `AdyenClient.RaiseDisputes` | Transfers v4 | 8 |
| `AdyenClient.Capital` | Capital v1 | 11 |
| `AdyenClient.OpenBanking` | Open Banking v1 | 2 |
| `AdyenClient.ClassicPayments` | Payment v68 | 13 |
| `AdyenClient.ClassicPlatforms.Account` | Account v6 | 18 |
| `AdyenClient.ClassicPlatforms.Fund` | Fund v6 | 8 |
| `AdyenClient.ClassicPlatforms.HOP` | HOP v6 | 2 |
| `AdyenClient.ClassicPlatforms.NotificationConfiguration` | Notification v6 | 6 |
| `AdyenClient.Webhooks` | — | 3 |
| `AdyenClient.Webhooks.HMAC` | — | 3 |
| `AdyenClient.Webhooks.Handler` | — | 1 callback |
| `AdyenClient.Webhooks.Plug` | — | Plug |

**Total: 66 modules, 475+ public functions**
