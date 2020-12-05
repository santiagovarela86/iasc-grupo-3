import Config

config :logger, :level, :error

config :quantum, :your_app, cron: [
  # Every minute
  "* * * * *": fn -> IO.puts("Hello QUANTUM!") end
]
