defmodule ChatAgent do
  use Agent

  def get_usuarios(agente) do
    Agent.get(agente, &Map.get(&1, :usuarios))
  end

  def get_mensajes(agente) do
    Agent.get(agente, &Map.get(&1, :mensajes))
  end

  def registrar_mensaje(agente, mensaje, origen) do
    Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn mensajes -> mensajes ++ [{origen, mensaje}] end) end )
    #TODO: agregar en todos los agentes del mismo chat
  end

  def eliminar_mensaje(agente, _) do
    Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn (mensajes) ->  List.delete_at(mensajes, 0)  end) end )
    #TODO: borra el ultimo mensaje, tiene que borrar mensaje_id
    #TODO: borrar en todos los agentes del mismo chat
  end

  def modificar_mensaje(agente, mensaje_nuevo, mensaje_id) do
    #Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn (mensajes) ->  List.keyreplace(mensajes, idOrigen, 0, {idOrigen, mensaje_nuevo})  end) end )
    #TODO: reemplaza el primero de los mensajes de idOrigen, tendria que remplazar el mensaje_id
    #TODO: modificar el mensaje en todos los agents del mismo chat
  end

  # Get (ID) Hash of a message.
  def getHash(mensaje) do
    :crypto.hash(:md5, mensaje <> to_string(DateTime.utc_now)) |> Base.encode16()
  end

end
