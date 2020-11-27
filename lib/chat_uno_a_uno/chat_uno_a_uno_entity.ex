defmodule ChatUnoAUnoEntity do
  def get_usuarios(chat) do
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.get_usuarios/1)
    actualizar(chat)
  end
  def get_mensajes(chat) do
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.get_mensajes/1)
    actualizar(chat)
  end

  def registrar_mensaje(chat, mensaje, origen) do
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.registrar_mensaje(&1, mensaje, origen))
  end

  def eliminar_mensaje(chat, mensaje_id) do
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.eliminar_mensaje(&1, mensaje_id))
  end

  def modificar_mensaje(chat, origen, mensaje_nuevo, mensaje_id) do
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.modificar_mensaje(&1, origen, mensaje_nuevo, mensaje_id))
  end

  def actualizar(grupo_swarm) do
    Entity.actualizar(grupo_swarm)
    #tiene que ser async
    #usa Entity.actualizar para comparar checksums en cada campo del grupo del swarm y aplica criterio propio para resolver conflictos si alguno difiere
    #si difieren listas de mensajes, las combina
    #si existen mensajes con la misma id, prioritiza texto :borrado, de otra forma, toma el mas nuevo (habria que agregar fecha de modificacion a los mensajes, aparte de fecha de publicacion)
  end
end
