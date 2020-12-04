defmodule UsuarioEntity do

  def get_nombre(usuario) do
    actualizar_async(usuario)
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_nombre/1)
  end

  def get_chats_uno_a_uno(usuario) do
    actualizar_async(usuario)
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_chats_uno_a_uno/1)
  end

  def get_chats_seguros(usuario) do
    actualizar_async(usuario)
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_chats_seguros/1)
  end

  def get_chats_de_grupo(usuario) do
    actualizar_async(usuario)
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_chats_de_grupo/1)
  end

  def agregar_chat_uno_a_uno(usuario, chat) do
    Entity.aplicar_cambio({:usuario_agent, usuario}, &UsuarioAgent.agregar_chat_uno_a_uno(&1, chat))
  end

  def agregar_chat_seguros(usuario, chat) do
    Entity.aplicar_cambio({:usuario_agent, usuario}, &UsuarioAgent.agregar_chat_seguros(&1, chat))
  end

  def agregar_chat_de_grupo(usuario, chat) do
    Entity.aplicar_cambio({:usuario_agent, usuario}, &UsuarioAgent.agregar_chat_de_grupo(&1, chat))
  end
  def actualizar_async(grupo_swarm) do
    Task.async(fn-> actualizar(grupo_swarm) end)
  end

  defp actualizar(grupo_swarm) do

    if !Entity.campo_actualizado(grupo_swarm, &UsuarioAgent.get_chats_de_grupo/1) do
      agentes = Swarm.members(grupo_swarm)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(UsuarioAgent.get_chats_de_grupo(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_de_grupo, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if !Entity.campo_actualizado(grupo_swarm, &UsuarioAgent.get_chats_seguros/1) do
      agentes = Swarm.members(grupo_swarm)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(UsuarioAgent.get_chats_seguros(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_seguros, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

    if !Entity.campo_actualizado(grupo_swarm, &UsuarioEntity.get_chats_uno_a_uno/1) do
      agentes = Swarm.members(grupo_swarm)
      unir_chats_otros = fn(otro_agente,acc) ->  MapSet.union(UsuarioAgent.get_chats_uno_a_uno(otro_agente), acc) end
      reducir_otros = fn(chats, agente) -> Enum.reduce(agentes -- [agente], chats, unir_chats_otros) end
      update_chats = fn(state, agente) -> Map.update!(state, :chats_uno_a_uno, &reducir_otros.(&1, agente)) end
      Enum.each(agentes, fn(agente) -> Agent.update(agente, &update_chats.(&1, agente)) end)
    end

  end
end
