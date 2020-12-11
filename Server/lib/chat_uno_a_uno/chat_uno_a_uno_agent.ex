defmodule ChatUnoAUnoAgent do
  use Agent

  def start_link(usuario1, usuario2) do
    Agent.start_link(fn -> %{
      usuarios: MapSet.new([usuario1, usuario2]),
      mensajes: Map.new
    } end,
    name: build_name(usuario1, usuario2)
    )
  end

  def get_usuarios(agente) do
    ChatAgent.get_usuarios(agente)
  end

  def get_mensajes(agente) do
    ChatAgent.get_mensajes(agente)
  end

  def registrar_mensaje(agente, mensaje, origen, fecha) do
    ChatAgent.registrar_mensaje(agente, mensaje, origen, fecha)
  end

  def eliminar_mensaje(agente, mensaje_id) do
    ChatAgent.eliminar_mensaje(agente, mensaje_id)
  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do
    ChatAgent.modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id)
  end

  def build_name(usuario1, usuario2) do
    name = :crypto.hash(:md5, usuario1 <> usuario2 <> to_string(DateTime.utc_now)) |> Base.encode16()
    {:via, :swarm, name}
  end

end
