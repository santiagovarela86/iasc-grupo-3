defmodule Chat do
  use GenServer

  def start_link(mensajes, usuarios, name) do
    GenServer.start_link(__MODULE__, {mensajes, usuarios}, name: ChatRegistry.build_name(name))
  end

  def init({mensajes, usuarios}) do
    state = %{
      mensajes: mensajes,
      usuarios: usuarios
    }

    {:ok, state}
  end

  def child_spec({mensajes, users, chat_name}) do
    %{
      id: chat_name,
      start: {__MODULE__, :start_link, [mensajes, users, chat_name]},
      type: :worker,
      restart: :transient
    }
  end

  def enviar_mensaje(sender, reciever, mensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:enviar_mensaje, sender, mensaje})
  end

  def get_messages(username1, username2) do
    pid = get_chat_pid(username1, username2)
    GenServer.call(pid, {:get_messages})
  end

  #def editar_mensaje(idChatDestino, mensajeNuevo, idMensaje ,idOrigen) do
  def editar_mensaje(sender, reciever, mensajeNuevo , idMensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:editar_mensaje, sender, reciever, mensajeNuevo, idMensaje})
  end

  #def eliminar_mensaje(idChatDestino, idMensaje ,idOrigen) do
  def eliminar_mensaje(sender, reciever, mensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:eliminar_mensaje, sender, mensaje})
  end


  def getHash(mensaje) do
    :crypto.hash(:md5, mensaje <> to_string(DateTime.utc_now)) |> Base.encode16()
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    # (existing_value :: value ->    updated_value :: value))
    idMensaje = getHash(mensaje)
    newState = Map.update!(state, :mensajes, fn mensajes -> mensajes ++ [{idMensaje, sender, mensaje}] end)
    {:reply, idMensaje, newState}
  end


  def handle_call({:editar_mensaje, sender, _, mensajeNuevo ,idMensaje}, _from, state) do
    IO.inspect(state)
    idMensajeNuevo = getHash(mensajeNuevo)
    newState = Map.update!(state, :mensajes, fn (mensajes) ->  List.keyreplace(mensajes, idMensaje, 0, {idMensajeNuevo, sender, mensajeNuevo})  end)
    IO.inspect(newState)
    {:reply, newState, newState}
  end

  # def handle_call({:eliminar_mensaje, sender, mensaje}, _from, state) do
  # Deberiamos borrar por id creo
  def handle_call({:eliminar_mensaje, _, _}, _from, state) do
    newState = Map.update!(state, :mensajes, fn mensajes -> List.delete_at(mensajes, 0) end )
    {:reply, newState, newState}
  end

  def handle_call({:get_messages}, _from, state) do
    {:reply, state.mensajes, state}
  end

  defp get_chat_pid(username1, username2) do
    ChatServer.get_chat(username1, username2)
  end
end
