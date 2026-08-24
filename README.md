# MeowPay

Send integer treats from one cat to another. Rails + Postgres.

## Docker

```bash
docker compose up --build
```

Then open http://localhost:3000

```bash
docker compose down
```

## Local

Ruby 4.0.x, Bundler, Postgres.

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails s
```

```bash
bundle exec rspec
```

## Routes

- `GET /` — pick a cat
- `GET /cats/:id` — balance, send, history
- `POST /transfers` — create a transfer
