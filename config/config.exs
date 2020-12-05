import Config

config :logger, :level, :error

config :pigeon, ChatSeguroScheduler,
  jobs: [
    {"* * * * *", {IO, :puts, ["HOLA"]}}
  ]
