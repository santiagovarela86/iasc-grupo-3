defmodule ChatDeGrupoEntity do

  def get_nombre(chat) do
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_nombre/1)
  end
  def agregar_usuario(chat, usuario) do
    Entity.aplicar_cambio({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.agregar_usuario(&1, usuario))
  end

  def eliminar_usuario(chat, usuario) do
    Entity.aplicar_cambio({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.eliminar_usuario(&1, usuario))
  end

  def agregar_admin(chat, usuario) do
    Entity.aplicar_cambio({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.agregar_admin(&1, usuario))
  end

  def eliminar_admin(chat, usuario) do
    Entity.aplicar_cambio({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.eliminar_admin(&1, usuario))
  end

  def get_usuarios(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_usuarios/1)
  end
  def get_mensajes(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_mensajes/1)
  end

  def get_admins(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_admins/1)
  end

  def get_modificacion_usuarios(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_modificacion_usuarios/1)
  end

  def get_modificacion_admins(chat) do
    actualizar_async(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_modificacion_admins/1)
  end

  def registrar_mensaje(chat, mensaje, origen) do
    Entity.aplicar_cambio({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.registrar_mensaje(&1, mensaje, origen))
  end

  def eliminar_mensaje(chat, mensaje_id) do
    Entity.aplicar_cambio({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.eliminar_mensaje(&1, mensaje_id))
  end

  def modificar_mensaje(chat, origen, mensaje_nuevo, mensaje_id) do
    Entity.aplicar_cambio({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.modificar_mensaje(&1, origen, mensaje_nuevo, mensaje_id))
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

    if !Entity.campo_actualizado(grupo_swarm, &ChatDeGrupoAgent.get_mensajes/1) do
      agentes
      |> Enum.map(fn(agente) -> ChatDeGrupoAgent.get_mensajes(agente) end)
      |> Enum.reduce([], fn(elem,acc) -> Map.merge(elem, acc, &resolver_conflicto_mensajes/3) end)
      #TODO: mal, no puedo reemplazar  la lista de mensajes, tengo que hacer un diff y agregar
      |> (&Enum.map(agentes, fn(agente) -> Agent.update(agente, fn(state) -> Map.update!(state, :mensajes, fn(_mensajes) -> &1 end) end)end)).()
    end

    if !Entity.campo_actualizado(grupo_swarm, &ChatDeGrupoAgent.get_usuarios/1) do
      agente_consenso = Entity.consenso(grupo_swarm, &ChatDeGrupoEntity.get_usuarios/1)
      Entity.exportar_campo(agente_consenso, grupo_swarm, :usuarios)
    end

    if !Entity.campo_actualizado(grupo_swarm, &ChatDeGrupoAgent.get_admins/1) do
      agente_consenso = Entity.consenso(grupo_swarm, &ChatDeGrupoEntity.get_admins/1)
      Entity.exportar_campo(agente_consenso, grupo_swarm, :admins)
    end

  end

end
