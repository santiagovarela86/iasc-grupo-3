defmodule UsuarioEntity do

  def get_nombre(usuario) do
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_nombre/1)
    actualizar(usuario)
  end

  def get_chats_uno_a_uno(usuario) do
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_chats_uno_a_uno/1)
    actualizar(usuario)
  end

  def get_chats_seguros(usuario) do
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_chats_seguros/1)
    actualizar(usuario)
  end

  def get_chats_de_grupo(usuario) do
    Entity.primera_respuesta({:usuario_agent, usuario}, &UsuarioAgent.get_chats_de_grupo/1)
    actualizar(usuario)
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

  def actualizar(grupo_swarm) do
    Entity.actualizar(grupo_swarm)
    #tiene que ser async
    #usa Entity.actualizar para comparar checksums en cada campo del grupo del swarm y aplica criterio propio para resolver conflictos si alguno difiere
    #si difieren listas de chats, las combina

    #si difieren admins o usuarios, toma el primero
    #si difiere tiempo limite para borrado, toma el menor
    #si existen mensajes con la misma id, prioritiza texto :borrado, de otra forma, toma el mas nuevo (habria que agregar fecha de modificacion a los mensajes, aparte de fecha de publicacion)
  end

end
