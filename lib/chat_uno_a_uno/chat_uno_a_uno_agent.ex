defmodule ChatUnoAUnoAgent do
  use Agent

  def start_link(usuario1, usuario2) do
    Agent.start_link(fn -> %{
      usuarios: MapSet.new([usuario1, usuario2]),
      mensajes: Map.new
    } end)
  end
  def get_usuarios(agente) do
    ChatAgent.get_usuarios(agente)
  end

  def get_mensajes(agente) do
    ChatAgent.get_mensajes(agente)
  end

  @spec registrar_mensaje(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def registrar_mensaje(agente, mensaje, origen) do
    ChatAgent.registrar_mensaje(agente, mensaje, origen)
  end

  def eliminar_mensaje(agente, mensaje_id) do
    ChatAgent.eliminar_mensaje(agente, mensaje_id)
  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do
    ChatAgent.modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id)
  end

end
