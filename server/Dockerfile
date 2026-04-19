FROM elixir:1.17-alpine AS build

RUN apk add --no-cache build-base git

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN MIX_ENV=prod mix deps.get --only prod

COPY config config
RUN MIX_ENV=prod mix deps.compile

COPY lib lib
COPY priv priv
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release

FROM alpine:3.19 AS runtime

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app
COPY --from=build /app/_build/prod/rel/pipeline_monitor ./

ENV PHX_SERVER=true

EXPOSE 4000

CMD ["sh", "-c", "/app/bin/pipeline_monitor eval 'PipelineMonitor.Release.migrate()' && /app/bin/pipeline_monitor start"]
