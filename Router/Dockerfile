# Extend from the official Elixir image
FROM elixir:latest

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
RUN mix local.hex --force

# Install dependencies
RUN mix deps.get

# Compile the project
RUN mix do compile

# Port for empd
EXPOSE 4369

# Exposed ports for clustering
EXPOSE 9100-9155

CMD ["/bin/bash", "/app/entrypoint.sh"]
