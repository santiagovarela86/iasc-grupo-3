defmodule ChatAgent do
  use Agent

  def get_usuarios(agente) do
    Agent.get(agente, &Map.get(&1, :usuarios))
  end

  def get_mensajes(agente) do
    Agent.get(agente, &Map.get(&1, :mensajes))
  end

  def registrar_mensaje(agente, mensaje, origen) do
    fecha = to_string(DateTime.utc_now)
    mensaje_id = :crypto.hash(:md5, mensaje <> fecha) |> Base.encode16()
    response = Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn(mensajes) -> Map.put(mensajes, mensaje_id, {mensaje_id, origen, mensaje, fecha}) end) end)
    #IO.puts("HHHHHHHHHHHHHH")
    #IO.inspect(response)
    {response, mensaje_id}
  end

  def eliminar_mensaje(agente, mensaje_id) do
    Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn mensajes -> List.keydelete(mensajes, mensaje_id, 0) end ) end )
  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do
    Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn (mensajes) ->  List.keyreplace(mensajes, mensaje_id, 0, {mensaje_id, origen, mensaje_nuevo})  end) end )
  end

end
