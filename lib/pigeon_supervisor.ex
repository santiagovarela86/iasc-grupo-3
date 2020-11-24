defmodule ApplicationSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      UsuarioRegistry,
      ChatRegistry,
      UsuarioSupervisor,
      UsuarioServer,
      ChatServer,
      GrupoServer,
      ChatSupervisor,
      GrupoSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
