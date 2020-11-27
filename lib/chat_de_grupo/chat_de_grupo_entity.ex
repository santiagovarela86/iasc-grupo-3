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
    actualizar(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_usuarios/1)
  end
  def get_mensajes(chat) do
    actualizar(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_mensajes/1)
  end

  def get_admins(chat) do
    actualizar(chat)
    Entity.primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_admins/1)
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

  def actualizar(grupo_swarm) do
    Entity.actualizar(grupo_swarm)
    #tiene que ser async
    #usa Entity.actualizar para comparar checksums en cada campo del grupo del swarm y aplica criterio propio para resolver conflictos si alguno difiere
    #si difieren listas de chats, las combina
    #si difieren admins o usuarios, toma el primero
    #si existen mensajes con la misma id, prioritiza texto :borrado, de otra forma, toma el mas nuevo (habria que agregar fecha de modificacion a los mensajes, aparte de fecha de publicacion)
  end

end
