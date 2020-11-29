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
    actualizar(grupo_swarm)
  end

  def actualizar(grupo_swarm) do

    chats_seguros_actualizados = Entity.campo_actualizado(grupo_swarm, &UsuarioAgent.get_chats_seguros/1)
    chats_de_grupo_actualizados = Entity.campo_actualizado(grupo_swarm, &UsuarioAgent.get_chats_de_grupo/1)
    chats_uno_a_uno_actualizados = Entity.campo_actualizado(grupo_swarm, &UsuarioEntity.get_chats_uno_a_uno/1)


    if (!chats_seguros_actualizados || !chats_de_grupo_actualizados || !chats_uno_a_uno_actualizados) do
      Swarm.members(grupo_swarm)
      # |> combinar chats de cada tipo
    end

  end

end
