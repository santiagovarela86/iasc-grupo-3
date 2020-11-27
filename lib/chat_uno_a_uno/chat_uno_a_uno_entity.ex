defmodule ChatUnoAUnoEntity do
  def get_usuarios(chat) do
    primera_respuesta({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.get_usuarios/1)
    #actualizar todos?
  end
  def get_mensajes(chat) do
    primera_respuesta({:chat_uno_a_uno_agent, chat}, &ChatUnoAUnoAgent.get_mensajes/1)
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
