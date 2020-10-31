defmodule Mensajero do
  use Task

  def start_link(state) do
    Task.start_link(__MODULE__, :enviar_mensaje, [state])
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def enviar_mensaje({identificador, mensaje}) do
      SupervisorHistorialManager.start_child({:registrar_mensaje, identificador, mensaje})
  end
end
