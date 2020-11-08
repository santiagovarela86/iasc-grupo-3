defmodule Pigeon do
  use Application

  def start(_type, _args) do
    children = [
      MessengerServer,
      ChatRepository
    ]

    opts = [strategy: :one_for_one, name: Pigeon.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
