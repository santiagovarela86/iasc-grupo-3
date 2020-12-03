defmodule ChatSeguroEntity do

  def get_usuarios(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_usuarios/1)
  end
  def get_mensajes(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_mensajes/1)
  end

  def get_tiempo_limite(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_tiempo_limite/1)
  end

  def get_modificacion_tiempo_limite(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_modificacion_tiempo_limite/1)
  end

  def cambiar_tiempo_limite(chat, tiempo_nuevo) do
    Entity.aplicar_cambio({:chat_seguro_agent, chat}, &ChatSeguroAgent.cambiar_tiempo_limite(&1, tiempo_nuevo))
  end

  def registrar_mensaje(chat, mensaje, origen) do
    Entity.aplicar_cambio({:chat_seguro_agent, chat}, &ChatSeguroAgent.registrar_mensaje(&1, mensaje, origen))
  end

  def eliminar_mensaje(chat, mensaje_id) do
    Entity.aplicar_cambio({:chat_seguro_agent, chat}, &ChatSeguroAgent.eliminar_mensaje(&1, mensaje_id))
  end

  def modificar_mensaje(chat, origen, mensaje_nuevo, mensaje_id) do
    Entity.aplicar_cambio({:chat_seguro_agent, chat}, &ChatSeguroAgent.modificar_mensaje(&1, origen, mensaje_nuevo, mensaje_id))
  end

  defp resolver_conflicto_mensajes(_key, {origen1, mensaje1, publicado1, modificado1}, {origen2, mensaje2, publicado2, modificado2}) do

    if (origen1 != origen2) do IO.puts("HAY ALGO RARO ACA, MATCHEARON DOS ID DE MENSAJES DE DISTINTOS USUARIOS") end
    if (publicado1 != publicado2) do IO.puts("HAY ALGO MUY RARO ACA, MATCHEARON DOS ID DE MENSAJES DE PUBLICADOS EN MOMENTOS DISTINTOS") end

    mensaje = cond do
      (mensaje1 == :borrado || mensaje2 == :borrado) -> :borrado
      modificado1 > modificado2 -> mensaje1
      modificado1 <= modificado2 -> mensaje2
    end
    modificado = max(modificado1,modificado2)

    {origen1, mensaje, publicado1, modificado}
  end

  def actualizar_async(grupo_swarm) do
    actualizar(grupo_swarm)
  end

  defp actualizar(grupo_swarm) do
    agentes = Swarm.members(grupo_swarm)

    if !Entity.campo_actualizado(grupo_swarm, &ChatSeguroAgent.get_mensajes/1) do
      agentes_mensajes =  Enum.map(agentes, fn(agente) -> {agente, ChatSeguroAgent.get_mensajes(agente)} end)
      mensajes_mergeados = Enum.reduce(agentes_mensajes, [], fn({_agente, mensajes},acc) -> Map.merge(mensajes, acc, &resolver_conflicto_mensajes/3) end)
      agentes_diffs = Enum.map(agentes_mensajes, fn({agente, mensajes}) -> {agente, Enum.into(Map.to_list(mensajes_mergeados) -- Map.to_list(mensajes), %{})} end)
      Enum.map(agentes_diffs, fn({agente, diffs}) -> Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn(mensajes) ->  Map.merge(mensajes, diffs) end) end)end)
    end

    if !Entity.campo_actualizado(grupo_swarm, &ChatSeguroAgent.get_tiempo_limite/1) do
      Swarm.members(grupo_swarm)
      |> Task.async_stream(fn(agente) -> {agente, ChatSeguroAgent.get_tiempo_limite(agente)} end, ordered: false)
      |> Stream.filter(fn({ok?, _}) -> ok? == :ok end)
      |> Enum.min_by(fn({_ok, {_agente, tiempo_limite}}) -> tiempo_limite end)
      |> case do {agente, _checksum} -> agente end
      |> Entity.exportar_campo(grupo_swarm, :tiempo_limite)
    end

  end
end
