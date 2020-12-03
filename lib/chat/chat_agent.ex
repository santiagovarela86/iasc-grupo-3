defmodule ChatAgent do
  use Agent

  def get_usuarios(agente) do
    Agent.get(agente, &Map.get(&1, :usuarios))
  end

  def get_mensajes(agente) do
    Agent.get(agente, &Map.get(&1, :mensajes))
  end

  def registrar_mensaje(agente, mensaje, origen) do
    :crypto.hash(:md5, mensaje <> to_string(DateTime.utc_now)) |> Base.encode16()
    |> (&fn(mensajes) -> Map.put(mensajes, &1, {origen, mensaje, DateTime.utc_now, DateTime.utc_now}) end).()
    |> (&fn(state) -> Map.update!(state, :mensajes, &1) end).()
    |> (&Agent.update(agente, &1)).()
  end

  def eliminar_mensaje(agente, mensaje_id) do
    fn({origen, _mensaje_viejo, tiempo_original, _tiempo_modificado_viejo}) -> {origen, :borrado, tiempo_original, DateTime.utc_now} end
    |> (&fn(mensajes) -> Map.update!(mensajes, mensaje_id, &1) end).()
    |> (&fn(state) -> Map.update!(state, :mensajes, &1) end).()
    |> (&Agent.update(agente, &1)).()
  end

  def modificar_mensaje(agente, _origen, mensaje_nuevo, mensaje_id) do
    fn({origen, _mensaje_viejo, tiempo_original, _tiempo_modificado_viejo}) -> {origen, mensaje_nuevo, tiempo_original, DateTime.utc_now} end
    |> (&fn(mensajes) -> Map.update!(mensajes, mensaje_id, &1) end).()
    |> (&fn(state) -> Map.update!(state, :mensajes, &1) end).()
    |> (&Agent.update(agente, &1)).()
  end

end
