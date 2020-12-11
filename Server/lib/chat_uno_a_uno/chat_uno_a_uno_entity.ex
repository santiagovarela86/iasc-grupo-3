defmodule ChatUnoAUnoEntity do
  def get_usuarios(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.get_usuarios/1)
  end
  def get_mensajes(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.get_mensajes/1)
  end

  def registrar_mensaje(chat, mensaje, origen) do
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.registrar_mensaje(&1, mensaje, origen, to_string(DateTime.utc_now)))
  end

  def eliminar_mensaje(chat, mensaje_id) do
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.eliminar_mensaje(&1, mensaje_id))
  end

  def modificar_mensaje(chat, origen, mensaje_nuevo, mensaje_id) do
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.modificar_mensaje(&1, origen, mensaje_nuevo, mensaje_id))
  end

  def actualizar_async(chat) do
    Task.start(fn-> actualizar({:chat_uno_a_uno_agent, chat}) end)
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

  defp actualizar(grupo_swarm) do
    agentes = Swarm.members(grupo_swarm)

    if !Entity.campo_actualizado(grupo_swarm, &ChatUnoAUnoAgent.get_mensajes/1) do
      agentes_mensajes =  Enum.map(agentes, fn(agente) -> {agente, ChatUnoAUnoAgent.get_mensajes(agente)} end)
      mensajes_mergeados = Enum.reduce(agentes_mensajes, Map.new, fn({_agente, mensajes},acc) -> Map.merge(mensajes, acc, &resolver_conflicto_mensajes/3) end)
      agentes_diffs = Enum.map(agentes_mensajes, fn({agente, mensajes}) -> {agente, Enum.into(Map.to_list(mensajes_mergeados) -- Map.to_list(mensajes), %{})} end)
      Enum.map(agentes_diffs, fn({agente, diffs}) -> Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn(mensajes) ->  Map.merge(mensajes, diffs) end) end)end)
    end
  end
end
