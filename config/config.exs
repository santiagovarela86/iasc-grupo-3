import Config

config :logger, level: :error

config :pigeon, ChatSeguroScheduler,
  jobs: [
    {{:extended, "*/30 * * * *"}, {IO, :puts, ["Cada 30 segundos corre la limpieza de mensajes."]}}
  ]
