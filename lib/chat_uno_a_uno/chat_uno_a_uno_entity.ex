defmodule ChatUnoAUnoEntity do
  def get_usuarios(chat) do
    chat_id = Enum.sort(chat)
    actualizar_async(chat_id)
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.get_usuarios/1)
  end
  def get_mensajes(chat) do
    chat_id = Enum.sort(chat)
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.get_mensajes/1)
  end

  def registrar_mensaje(chat, mensaje, origen) do
    chat_id = Enum.sort(chat)
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.registrar_mensaje(&1, mensaje, origen))
  end

  def eliminar_mensaje(chat, mensaje_id) do
    chat_id = Enum.sort(chat)
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.eliminar_mensaje(&1, mensaje_id))
  end

  def modificar_mensaje(chat, origen, mensaje_nuevo, mensaje_id) do
    chat_id = Enum.sort(chat)
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.modificar_mensaje(&1, origen, mensaje_nuevo, mensaje_id))
  end

  def actualizar_async(grupo_swarm) do
    actualizar(grupo_swarm)
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
      agentes
      |> Enum.each(fn(agente) -> ChatUnoAUnoAgent.get_mensajes(agente) end)
      |> Enum.reduce([], fn(elem,acc) -> Map.merge(elem, acc, &resolver_conflicto_mensajes/3) end)
      |> (&Enum.each(agentes, fn(agente) -> Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn(_mensajes) -> &1 end) end)end)).()
    end
  end
end
