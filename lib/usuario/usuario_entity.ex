defmodule UsuarioEntity do

  def get_nombre(chat) do
    Entity.primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_nombre/1)
    #actualizar?
  end

  def get_chats_uno_a_uno(chat) do
    Entity.primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_chats_uno_a_uno/1)
    #actualizar?
  end

  def get_chats_seguros(chat) do
    Entity.primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_chats_seguros/1)
    #actualizar?
  end

  def get_chats_de_grupo(chat) do
    Entity.primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_chats_de_grupo/1)
    #actualizar?
  end

  def agregar_chat_uno_a_uno(agente, chat_id) do

  end

  def agregar_chat_seguros(agente, chat_id) do

  end

  def agregar_chat_de_grupo(agente, chat_id) do

  end


end
