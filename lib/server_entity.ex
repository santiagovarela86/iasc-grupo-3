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

  def agregar_chat_seguros(chat) do
    Entity.aplicar_cambio(:server_agent, &ServerAgent.agregar_chat_seguros(&1, chat))
  end

  def agregar_chat_de_grupo(chat) do
    Entity.aplicar_cambio(:server_agent, &ServerAgent.agregar_chat_de_grupo(&1, chat))
  end
  def actualizar_async() do
    actualizar()
  end

  def actualizar() do

    if !Entity.campo_actualizado(:server_agent, &ServerAgent.get_usuarios/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_usuarios(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :usuarios, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if ! Entity.campo_actualizado(:server_agent, &ServerAgent.get_chats_de_grupo/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_chats_de_grupo(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_de_grupo, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if ! Entity.campo_actualizado(:server_agent, &ServerAgent.get_chats_seguros/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_chats_seguros(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_seguros, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if !Entity.campo_actualizado(:server_agent, &UsuarioEntity.get_chats_uno_a_uno/1) do
      agentes = Swarm.members(:server_agent)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(ServerAgent.get_chats_uno_a_uno(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_uno_a_uno, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

  end
end
