defmodule ChatUnoAUnoEntity do
  def get_usuarios(chat) do
    chat_id = Enum.sort(chat)
    actualizar(chat_id)
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.get_usuarios/1)
  end
  def get_mensajes(chat) do
    chat_id = Enum.sort(chat)
    actualizar(chat)
    Entity.primera_respuesta({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.get_mensajes/1)
  end

  def registrar_mensaje(chat, mensaje, origen) do
    chat_id = Enum.sort(chat)
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.registrar_mensaje(&1, mensaje, origen))
  end

  def eliminar_mensaje(chat, mensaje_id) do
    chat_id = Enum.sort(chat)
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.eliminar_mensaje(&1, mensaje_id))
  end

  def modificar_mensaje(chat, origen, mensaje_nuevo, mensaje_id) do
    chat_id = Enum.sort(chat)
    Entity.aplicar_cambio({:chat_uno_a_uno_agent, chat_id}, &ChatUnoAUnoAgent.modificar_mensaje(&1, origen, mensaje_nuevo, mensaje_id))
  end

  def actualizar(grupo_swarm) do
    Entity.actualizar(grupo_swarm)
    #tiene que ser async
    #usa Entity.actualizar para comparar checksums en cada campo del grupo del swarm y aplica criterio propio para resolver conflictos si alguno difiere
    #si difieren listas de mensajes, las combina
    #si existen mensajes con la misma id, prioritiza texto :borrado, de otra forma, toma el mas nuevo (habria que agregar fecha de modificacion a los mensajes, aparte de fecha de publicacion)
  end
end
