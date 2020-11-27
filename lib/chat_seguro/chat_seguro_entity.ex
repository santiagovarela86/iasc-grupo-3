defmodule ChatSeguroEntity do

  def get_usuarios(chat) do
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_usuarios/1)
    #actualizar todos?
  end
  def get_mensajes(chat) do
    Entity.primera_respuesta({:chat_seguro_agent, chat}, &ChatSeguroAgent.get_mensajes/1)
    #actualizar todos?
  end

  def registrar_mensaje(agente, mensaje, origen) do

  end

  def eliminar_mensaje(agente, mensaje_id) do

  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do

  end

end
