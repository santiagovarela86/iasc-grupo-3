defmodule GrupoSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(nombre_grupo) do
    spec = {ChatDeGrupo, nombre_grupo}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
