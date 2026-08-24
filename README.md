# MeowPay

## What I built

A small Rails app where one cat sends integer treats to another. You pick a cat, see their balance, send treats, and see recent transfers. The debit/credit happens in `TransferService` inside one Postgres transaction with row locks. UI is ERB. RSpec covers the service, including a concurrent double-spend case.

Stack: Ruby 4.0.x, Rails 8.1, PostgreSQL, Puma, Propshaft, RSpec.

## How to run (clean clone)

**With Ruby** (needs Ruby, Bundler, Postgres):

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails s
```

http://localhost:3000

(`bin/rails db:prepare` is fine instead of create + migrate.)

```bash
bundle exec rspec
```

**With Docker** (needs Docker Desktop only):

```bash
docker compose up --build
```

http://localhost:3000 — stop with `docker compose down`.

Don’t run local `rails s` and Compose on port 3000 at the same time.

## Decisions and trade-offs

- Integer `treats_balance` — treats are whole units; floats are a bad fit for money-like values
- `recipient_id` — clear money-movement naming
- Logic in a `TransferService` PORO (Plain Old Ruby Object — a plain Ruby class, not an Active Record model), not in the controller or callbacks
- Lock both cats `ORDER BY id` in one transaction — avoids deadlocks and lost updates under concurrency
- No transfer row / status on failure — only successful moves are stored
- Balance non-negative via model validation, not a DB CHECK — kept the rule next to the domain for this slice
- POST → redirect + flash; tiny JS only dismisses / auto-hides the flash — no AJAX/JSON send path
- One history list (sent ∪ received) — matches how you read a wallet
- Compose runs in development — production SSL/credentials would fight `localhost`
- Skipped auth, top-up/withdraw, KYC, idempotency keys, rate limits, fraud, notifications, pagination, multi-currency, Hotwire/SPA, Redis/Sidekiq, Kamal / production deploy hardening — so time went into one correct A→B transfer
- Working with AI — agent suggestions I kept: Rails/Postgres/RSpec/ERB, `TransferService` + locks, Compose, flash dismiss JS, compact cards. Ones I changed or rejected: DB CHECK, AJAX send, feature specs left in the repo, custom favicon, vertically centered picker
