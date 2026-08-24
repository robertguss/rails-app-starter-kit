# syntax=docker/dockerfile:1

ARG RUBY_VERSION=4.0.6
ARG NODE_VERSION=24.19.0
FROM docker.io/library/ruby:${RUBY_VERSION}-slim-bookworm AS base

WORKDIR /rails

ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_ENV=production

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libpq5 libvips42 postgresql-client && \
    rm -rf /var/lib/apt/lists/*

FROM docker.io/library/node:${NODE_VERSION}-bookworm-slim AS node

FROM base AS build

ARG PNPM_VERSION=11.23.0

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY --from=node /usr/local/ /usr/local/
RUN corepack enable pnpm && corepack prepare pnpm@${PNPM_VERSION} --activate

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf /root/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile && \
    rm -rf node_modules tmp/cache

FROM base

ENV LD_PRELOAD=libjemalloc.so.2

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["bin/rails", "server", "--binding", "0.0.0.0"]
