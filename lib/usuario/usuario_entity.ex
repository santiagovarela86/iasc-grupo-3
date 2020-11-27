defmodule UsuarioEntity do


  def get_nombre(chat) do
    primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_nombre/1)
    #actualizar?
  end

  def get_chats_uno_a_uno(chat) do
    primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_chats_uno_a_uno/1)
    #actualizar?
  end

  def get_chats_seguros(chat) do
    primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_chats_seguros/1)
    #actualizar?
  end

  def get_chats_de_grupo(chat) do
    primera_respuesta({:usuario_agent, chat}, &UsuarioAgent.get_chats_de_grupo/1)
    #actualizar?
  end

  def agregar_chat_uno_a_uno(agente, chat_id) do

  end

  def agregar_chat_seguros(agente, chat_id) do

  end

  def agregar_chat_de_grupo(agente, chat_id) do

  end

  defp primera_respuesta(grupo_swarm, funcion) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(chat) -> funcion.(chat) end, ordered: false)
    |> Stream.filter(fn({a, _}) -> a == :ok end)
    |> Enum.take(1)
  end
end
