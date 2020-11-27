defmodule ChatDeGrupoEntity do



  def get_nombre(chat) do
    primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_nombre/1)
  end
  def agregar_usuario(agente, usuario) do

  end

  def eliminar_usuario(agente, usuario) do

  end

  def agregar_admin(agente, usuario) do

  end

  def eliminar_admin(agente, usuario) do

  end

  def get_usuarios(chat) do
    primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_usuarios/1)
    #actualizar todos?
  end
  def get_mensajes(chat) do
    primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_mensajes/1)
    #actualizar todos?
  end

  def get_admins(chat) do
    primera_respuesta({:chat_de_grupo_agent, chat}, &ChatDeGrupoAgent.get_admins/1)
    #actualizar todos?
  end

  def registrar_mensaje(agente, mensaje, origen) do

  end

  def eliminar_mensaje(agente, mensaje_id) do

  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do

  end

  defp primera_respuesta(grupo_swarm, funcion) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(chat) -> funcion.(chat) end, ordered: false)
    |> Stream.filter(fn({a, _}) -> a == :ok end)
    |> Enum.take(1)
  end



end
