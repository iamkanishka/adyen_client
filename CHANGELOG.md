# Changelog

All notable changes to AdyenClient are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.0.0] — 2026-05-14

### Added

#### Core infrastructure

- `AdyenClient.Config` — NimbleOptions-free config with defaults, validation, and URL routing
  for all 22 Adyen host patterns across test and live environments
- `AdyenClient.Client` — HTTP client with Req: JSON encode/decode, `X-API-Key` auth,
  auto-generated `Idempotency-Key` on POST, exponential-backoff retry, telemetry
- `AdyenClient.Error` — structured error type implementing `Exception`; fields: `type`,
  `status`, `message`, `error_code`, `psp_reference`, `raw`, `retryable`
- `AdyenClient.Telemetry` — `[:adyen_client, :request, :start/stop]` telemetry events
  with PCI-field redaction (`cardNumber`, `cvv`, `cvc`, `holderName`, etc.)
- `AdyenClient.CircuitBreaker` — GenServer circuit breaker (closed → open → half-open)
- `AdyenClient.RateLimiter` — token-bucket GenServer rate limiter (100 req/s, burst 200)
- `AdyenClient.Application` (internal OTP supervisor) — starts CircuitBreaker + RateLimiter

#### Online Payments

- `AdyenClient.Checkout.Sessions` — create session, get session result (Checkout v72)
- `AdyenClient.Checkout.Payments` — list payment methods, create payment, submit details,
  get card details (Checkout v72)
- `AdyenClient.Checkout.Modifications` — capture, cancel, cancel by reference, refund,
  reverse, update amount (Checkout v72)
- `AdyenClient.Checkout.PaymentLinks` — create, get, update (Checkout v72)
- `AdyenClient.Checkout.Recurring` — forward, list tokens, create token, delete token
  (Checkout v72)
- `AdyenClient.Checkout.Orders` — gift card balance, create order, cancel order (Checkout v72)
- `AdyenClient.Checkout.Donations` — list campaigns, create donation (Checkout v72)
- `AdyenClient.Checkout.Utility` — origin keys, Apple Pay session, PayPal order update,
  validate shopper ID (Checkout v72)
- `AdyenClient.BinLookup` — 3DS availability, cost estimate (BinLookup v54)
- `AdyenClient.Disputes` — accept, defend, delete defense document, get applicable defense
  reasons, supply defense document (Disputes v30)
- `AdyenClient.Recurring` — create permit, disable, disable permit, list details,
  notify shopper, schedule account updater (Recurring v68)
- `AdyenClient.Payout` — store+submit, store, submit, confirm, decline, instant payout
  (Payout v68, deprecated)

#### In-Person Payments

- `AdyenClient.Terminal` — all 18 NEXO message types: Login, Logout, EnableService, Admin,
  Payment, CardAcquisition, StoredValue, Reversal, Reconciliation, GetTotals,
  BalanceInquiry, TransactionStatus, Abort, Diagnosis, Display, Input, Print,
  CardReaderAPDU (Terminal API v1)
- `AdyenClient.CloudDevice` — sync, async, connection status, list connected devices
  (Cloud Device v1)
- `AdyenClient.SoftPOS` — create communication session (SoftPOS v3)
- `AdyenClient.PaymentsApp` — boarding tokens (merchant + store), list apps, revoke
  (Payments App v1)
- `AdyenClient.Management.PosMobile` — create session (possdk v68, deprecated)
- `AdyenClient.Management.TerminalManagement` — assign, find terminal, get stores,
  get terminal details, list terminals (postfmapi v1, deprecated)

#### Management API (v3)

- `AdyenClient.Management.Companies` — list companies, get company, list merchants
- `AdyenClient.Management.Merchants` — list, get, create, activate
- `AdyenClient.Management.Stores` — list (merchant), list (global), create, get, update
  (all path variants including store-ID-only)
- `AdyenClient.Management.Users` — company + merchant level: list, create, get, update
- `AdyenClient.Management.ApiCredentials` — my credential, company + merchant level: list,
  create, get, update; generate API key; generate client key
- `AdyenClient.Management.AllowedOrigins` — my credential origin; company + merchant
  credential: list, create, get, delete
- `AdyenClient.Management.PayoutSettings` — add, list, get, update, delete
- `AdyenClient.Management.Webhooks` — company + merchant level: create, list, get, update,
  delete, generate HMAC key, test
- `AdyenClient.Management.PaymentMethods` — request, list, get, update, Apple Pay domains
- `AdyenClient.Management.Terminals` — list, reassign, terminal actions
- `AdyenClient.Management.TerminalOrders` — company + merchant: models, products, billing
  entities, shipping locations, orders CRUD
- `AdyenClient.Management.TerminalSettings` — 20 functions covering company, merchant,
  store (merchant+store_ref path), store (store_id-only path), and terminal level;
  both settings and logo for each level
- `AdyenClient.Management.AndroidFiles` — list apps, list certificates, get app,
  upload app, upload certificate, reprocess app
- `AdyenClient.Management.SplitConfigurations` — profile CRUD, rule CRUD, split logic update
- `AdyenClient.BalanceControl` — company + merchant balance overviews, balance transfer
  (Balance Control v2)

#### Platforms & Financial Products

- `AdyenClient.LegalEntity` — legal entity CRUD, transfer instruments, business lines,
  documents, Terms of Service (get/accept/status), PCI questionnaires, tax e-delivery
  consent, hosted onboarding (LEM v4) — 27 endpoints
- `AdyenClient.BalancePlatform` — balance platform, account holders, balance accounts,
  sweeps, payment instruments (incl. reveal/PAN), network tokens, authorized card users,
  transaction rules, bank account validation, grant accounts/offers, card orders,
  card PIN (change/reveal/RSA key), transfer routes, mandates, SCA devices
  (registeredDevices), transfer limits (balance account) (BCL v2) — 45 endpoints
- `AdyenClient.BalancePlatform.AccountHolders` — tax form summary
- `AdyenClient.BalancePlatform.TransactionRules` — scoped listing: platform, account holder,
  balance account, payment instrument, instrument group
- `AdyenClient.BalancePlatform.WebhookSettings` — balance webhook settings CRUD
- `AdyenClient.BalancePlatform.PaymentInstrumentGroups` — create, get
- `AdyenClient.BalancePlatform.SCADevices` — begin/finish registration, create association
  (scaDevices endpoint set)
- `AdyenClient.BalancePlatform.SCAAssociations` — list for entity, delete, approve pending
- `AdyenClient.BalancePlatform.TransferLimits` — approve pending (balance account), full
  CRUD at balance platform level
- `AdyenClient.SessionAuth` — create session token (Session Auth v1)
- `AdyenClient.Transfers` — create, approve, cancel, return, list, get transfers;
  list + get transactions; capital endpoints (Transfers v4)
- `AdyenClient.RaiseDisputes` — list, raise, get, update disputes; attachment CRUD
  (Transfers v4 namespace)
- `AdyenClient.Capital` — dynamic offers (list/calculate/create static), grant offers,
  grants (request/list/get/disbursements/update repayment), grant accounts (Capital v1)
- `AdyenClient.ForeignExchange` — calculate rate (FX v1)
- `AdyenClient.OpenBanking` — create verification routes, get verification report (v1)

#### Classic APIs

- `AdyenClient.ClassicPayments` — authorise, authorise3d, authorise3ds2, get auth result,
  get 3DS2 result, capture, cancel, refund, cancelOrRefund, technicalCancel,
  adjustAuthorisation, donate, voidPendingRefund (Payment v68)
- `AdyenClient.ClassicPlatforms.Account` — account holder CRUD + state, account CRUD,
  documents, KYC check, delete operations (Account v6)
- `AdyenClient.ClassicPlatforms.Fund` — balances, transactions, payout, transfer, refund
  transfer, beneficiary, refund not paid out, debit (Fund v6)
- `AdyenClient.ClassicPlatforms.HOP` — onboarding URL, PCI questionnaire URL (HOP v6)
- `AdyenClient.ClassicPlatforms.NotificationConfiguration` — subscribe, get, list, test,
  update, delete (Notification v6)

#### Webhooks

- `AdyenClient.Webhooks.HMAC` — HMAC-SHA256 validation for standard and Balance Platform
  webhooks; constant-time `secure_compare/2` to prevent timing attacks
- `AdyenClient.Webhooks.Handler` — `@behaviour` with `handle_event/2` callback; safe
  `dispatch/2` that isolates handler exceptions per notification item
- `AdyenClient.Webhooks` — `process/3` pipeline (parse JSON → validate all HMAC → dispatch);
  `parse/1`; `validate_all/2`
- `AdyenClient.Webhooks.Plug` — Phoenix/Plug drop-in: raw body passthrough, HMAC
  validation, dispatch, `[accepted]` response; `read_body/2` for `Plug.Parsers`

#### Documentation & tooling

- Full `@spec` and `@type` coverage — Dialyzer-clean
- Explicit `@spec` on all TerminalSettings functions (no metaprogramming)
- Dialyzer config in `mix.exs` with PLT path, flags, and ignore file
- `.dialyzer_ignore.exs` for runtime-dep false positives
- ExDoc group configuration for all 66 modules
- `mix lint` alias: `format --check-formatted` + `credo --strict` + `dialyzer`
- `mix lint.ci` alias for CI pipelines
- Guide pages: configuration, webhooks, error handling, telemetry

[1.0.0]: https://github.com/your-org/adyen_client/releases/tag/v1.0.0
