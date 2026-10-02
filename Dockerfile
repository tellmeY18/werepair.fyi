# syntax=docker/dockerfile:1
FROM hexpm/elixir:1.18.4-erlang-27.3.4-debian-bookworm-20250428-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends build-essential git ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV MIX_ENV=prod
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs config/
RUN mix deps.get --only prod && mix deps.compile
COPY lib lib
COPY priv priv
COPY config/runtime.exs config/runtime.exs
RUN mix compile --warnings-as-errors && mix phx.digest && mix release

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 app && useradd --uid 10001 --gid app --home-dir /app app
WORKDIR /app
COPY --from=build --chown=10001:10001 /app/_build/prod/rel/werepair ./
ENV PHX_SERVER=true PORT=4000 ERL_CRASH_DUMP=/tmp/erl_crash.dump LANG=C.UTF-8
USER 10001:10001
EXPOSE 4000
CMD ["bin/werepair", "start"]
