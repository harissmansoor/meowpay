# MeowPay

## What I built

A small Rails app where one cat sends integer treats to another. You pick a cat, see their balance, send treats, and see recent transfers. The debit/credit happens in `TransferService` inside one Postgres transaction with row locks. UI is ERB. RSpec covers the service, including a concurrent double-spend case.

Ruby 4.0.5, Rails 8.1.3.1, PostgreSQL 14+, Bundler 4.x. Ruby 3.2+ should also work with Rails 8.1.

## How to run (clean clone)

```bash
git clone https://github.com/harissmansoor/meowpay.git
cd meowpay
```

Or: `git clone git@github.com:harissmansoor/meowpay.git`

### Through Docker

Docker Desktop required. No local Ruby/Postgres.

```bash
docker compose up --build
```

http://localhost:3000

```bash
docker compose down
```

### Through Local Ruby

You need Ruby 4.0.x (`ruby -v`), Bundler, and Postgres running.


```bash
bundle config set --local path 'vendor/bundle'
bundle install
```


```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails s
```

http://localhost:3000

`bundle exec rails db:prepare` works instead of create + migrate.

```bash
bundle exec rspec
```

Use `bundle exec` so you get the project gems. If `bundle install` failed partway, fix that before running rails. If `db:create` fails, start Postgres and retry (`meowpay_development` / `meowpay_test` in `config/database.yml`).

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
