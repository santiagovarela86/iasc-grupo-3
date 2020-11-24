defmodule ChatAgent do
  use Agent

  def get_usuarios(agente) do
    Agent.get(agente, &Map.get(&1, :usuarios))
  end

  def get_mensajes(agente) do
    Agent.get(agente, &Map.get(&1, :mensajes))
  end

  def registrar_mensaje(agente, mensaje, origen) do
    mensaje_id = :crypto.hash(:md5, mensaje <> to_string(DateTime.utc_now)) |> Base.encode16()
    Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn mensajes -> Map.put(mensajes, mensaje_id, {origen, mensaje}) end ) end)
  end

  def eliminar_mensaje(agente, mensaje_id) do
    Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn mensajes -> List.keydelete(mensajes, mensaje_id, 0) end ) end )
  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do
    Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn (mensajes) ->  List.keyreplace(mensajes, mensaje_id, 0, {mensaje_id, origen, mensaje_nuevo})  end) end )
  end

end
