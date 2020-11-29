defmodule ChatSeguroEntity do

  def get_usuarios(chat) do
    actualizar(chat)
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_usuarios/1)
  end
  def get_mensajes(chat) do
    actualizar(chat)
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_mensajes/1)
  end

  def get_tiempo_limite(chat) do
    actualizar(chat)
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_tiempo_limite/1)
  end

  def registrar_mensaje(chat, mensaje, origen) do
    Entity.aplicar_cambio({:chat_seguro_agent, chat}, &ChatSeguroAgent.registrar_mensaje(&1, mensaje, origen))
  end

  def eliminar_mensaje(chat, mensaje_id) do
    Entity.aplicar_cambio({:chat_seguro_agent, chat}, &ChatSeguroAgent.eliminar_mensaje(&1, mensaje_id))
  end

  def modificar_mensaje(chat, origen, mensaje_nuevo, mensaje_id) do
    Entity.aplicar_cambio({:chat_seguro_agent, chat}, &ChatSeguroAgent.modificar_mensaje(&1, origen, mensaje_nuevo, mensaje_id))
  end

  def actualizar(grupo_swarm) do
    Entity.actualizar(grupo_swarm)
    #tiene que ser async
    #usa Entity.actualizar para comparar checksums en cada campo del grupo del swarm y aplica criterio propio para resolver conflictos si alguno difiere
    #si difieren listas de chats, las combina
    #si difiere tiempo limite para borrado, toma el menor
    #si existen mensajes con la misma id, prioritiza texto :borrado, de otra forma, toma el mas nuevo (habria que agregar fecha de modificacion a los mensajes, aparte de fecha de publicacion)
  end
end
