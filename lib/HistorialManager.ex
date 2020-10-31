defmodule HistorialManager do
  use Task

  def start_link({action, state}) do
    Task.start_link(__MODULE__, action, [state])
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def registrar_mensaje(identificador, message) do
    # children = Supervisor.which_children(HistorialSupervisor)
    # children.map (agente -> agente.registrar_mensaje(identificador, message))
  end

  def get_historial(identificador) do
    # children = Supervisor.which_children(HistorialSupervisor)
    # children.map (agente -> agente.get_historial(identificador)
  end
end
