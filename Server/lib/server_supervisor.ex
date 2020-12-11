defmodule ServerSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      UsuarioSupervisor,
      UsuarioServer,
      ChatUnoAUnoSupervisor,
      ChatUnoAUnoServer,
      ChatDeGrupoSupervisor,
      ChatDeGrupoServer,
      ChatSeguroSupervisor,
      ChatSeguroServer,
      ChatSeguroScheduler,
      AutoConnect
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

end
