defmodule Pigeon do
  use Application

  def start(_type, _args) do
    children = [
      # empty at the moment
    ]

    opts = [strategy: :one_for_one, name: Pigeon.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
