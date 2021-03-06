defmodule ServerEntity do

  def get_usuarios() do
    actualizar_async()
    Entity.primera_respuesta(:server_agent, &ServerAgent.get_usuarios/1)
  end

  def get_chats_uno_a_uno() do
    actualizar_async()
    Entity.primera_respuesta(:server_agent, &ServerAgent.get_chats_uno_a_uno/1)
  end

  def get_chats_seguros() do
    actualizar_async()
    Entity.primera_respuesta(:server_agent, &ServerAgent.get_chats_seguros/1)
  end

  def get_chats_de_grupo() do
    actualizar_async()
    Entity.primera_respuesta(:server_agent, &ServerAgent.get_chats_de_grupo/1)
  end

  def agregar_usuario(nombre) do
    Entity.aplicar_cambio(:server_agent, &ServerAgent.agregar_usuario(&1, nombre))
  end
  def agregar_chat_uno_a_uno(chat) do
    Entity.aplicar_cambio(:server_agent, &ServerAgent.agregar_chat_uno_a_uno(&1, chat))
  end

  def agregar_chat_seguro(chat) do
    Entity.aplicar_cambio(:server_agent, &ServerAgent.agregar_chat_seguros(&1, chat))
  end

  def agregar_chat_de_grupo(chat) do
    Entity.aplicar_cambio(:server_agent, &ServerAgent.agregar_chat_de_grupo(&1, chat))
  end
  def copiar_faltantes() do

    actualizar()

    {_, usuarios} = ServerEntity.get_usuarios()
    MapSet.to_list(usuarios)
    |> Enum.each(fn usuario ->
        if !Enum.any?(Swarm.members({:usuario_agent, usuario}),fn(pid) -> is_local(pid) end) do
          UsuarioSupervisor.start_child(usuario)
      end
    end)

    {_, chats} = ServerEntity.get_chats_uno_a_uno()
    MapSet.to_list(chats)
    |> Enum.each(fn chat ->
        if !Enum.any?(Swarm.members({:chat_uno_a_uno_agent, chat}),fn(pid) -> is_local(pid) end) do
          ChatUnoAUnoSupervisor.start_child(chat)
      end
    end)

    {_, chats} = ServerEntity.get_chats_seguros()
    MapSet.to_list(chats)
    |> Enum.each(fn chat ->
        if !Enum.any?(Swarm.members({:chat_seguro_agent, chat}),fn(pid) -> is_local(pid) end) do
          ChatSeguroSupervisor.start_child(chat, 0)
      end
    end)

    {_, chats} = ServerEntity.get_chats_de_grupo()
    MapSet.to_list(chats)
    |> Enum.each(fn chat ->
        if !Enum.any?(Swarm.members({:chat_de_grupo_agent, chat}),fn(pid) -> is_local(pid) end) do
          ChatDeGrupoSupervisor.start_child(chat, "")
      end
    end)

  end

  def copiar(agente_copia, grupo_de_agentes) do
    case Entity.primera_respuesta(grupo_de_agentes, fn(a) -> a end) do
      {_, agente_target} ->
        if (agente_copia != agente_target) do
          Agent.update(agente_copia, fn(_state) ->  Agent.get(agente_target, fn(state2) -> state2 end) end)
        end
      _ -> {}
      end
end

  def actualizar_async() do
    Task.start(fn-> actualizar() end)
  end

  defp actualizar() do

    if !Entity.campo_actualizado(:server_agent, &ServerAgent.get_usuarios/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_usuarios(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :usuarios, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if !Entity.campo_actualizado(:server_agent, &ServerAgent.get_chats_de_grupo/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_chats_de_grupo(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_de_grupo, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if !Entity.campo_actualizado(:server_agent, &ServerAgent.get_chats_seguros/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_chats_seguros(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_seguros, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if !Entity.campo_actualizado(:server_agent, &ServerAgent.get_chats_uno_a_uno/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_chats_uno_a_uno(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_uno_a_uno, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

  end

  defp is_local(pid) do
    Enum.take(:erlang.pid_to_list(pid), 2) == '<0'
  end

end
