defmodule ApplicationSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      ServerSupervisor,
      PigeonInitializer
    ]
    Supervisor.init(children, strategy: :one_for_all, max_restarts: 100, max_seconds: 1)
  end

end
