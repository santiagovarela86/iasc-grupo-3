# Extend from the official Elixir image
FROM elixir:latest

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
# By using --force, we don’t need to type “Y” to confirm the installation
RUN mix local.hex --force

# Needed to install rebar3
RUN mix local.rebar --force

# Install dependencies
RUN mix deps.get

# Compile the project
RUN mix do compile

#Troubleshooting tools
RUN apt-get update -y && apt-get install net-tools -y && apt-get install dnsutils -y && apt-get install telnet -y

# Port for empd
EXPOSE 4369

# Exposed ports for clustering
EXPOSE 9100-9155

CMD ["/bin/bash", "/app/entrypoint.sh"]
