FROM ruby:4.0.5-bookworm

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /rails

ENV BUNDLE_PATH=/usr/local/bundle \
    RAILS_ENV=development

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint bin/rails bin/rake

EXPOSE 3000

ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
