# base image elixir to start with
FROM bitwalker/alpine-elixir:1.7.4

# install hex package manager
RUN mix local.hex --force

# create app folder
RUN mkdir /app
WORKDIR /app
COPY . /app

# setting the environment (prod = PRODUCTION!)
ENV MIX_ENV=prod

# install dependencies (production only)
RUN mix local.rebar --force
RUN mix deps.get --only prod
RUN mix compile

# create release
RUN mix release --name=poller

ENV REPLACE_OS_VARS=true
ENTRYPOINT ["_build/prod/rel/poller/bin/poller"]

# run elixir app
CMD ["help"]
