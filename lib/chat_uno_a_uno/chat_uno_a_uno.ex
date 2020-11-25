defmodule ChatUnoAUno do
  use GenServer

  def start_link(chat_name) do
    GenServer.start_link(__MODULE__, chat_name, name: {:via, Registry, {ChatUnoAUnoRegistry, chat_name}})
  end

  def init(chat_name) do
    state = %{chat_name: chat_name}
    {:ok, state}
  end

  def child_spec(chat_name) do
    %{
      id: chat_name,
      start: {__MODULE__, :start_link, [chat_name]},
      type: :worker,
      restart: :transient
    }
  end

  def enviar_mensaje(sender, reciever, mensaje) do
    pid = get_chat_pid(sender, reciever)
    response = GenServer.call(pid, {:enviar_mensaje, sender, mensaje})
    #IO.puts("AAAAAAAAAAAAA")
    #IO.inspect(response)
  end

  def get_messages(username1, username2) do
    pid = get_chat_pid(username1, username2)
    GenServer.call(pid, {:get_messages})
  end

  def editar_mensaje(sender, reciever, mensajeNuevo, id_mensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:editar_mensaje, sender, mensajeNuevo, id_mensaje})
  end

  def eliminar_mensaje(idChatDestino, idMensaje ,idOrigen) do
    GenServer.call(idChatDestino, {:eliminar_mensaje, idMensaje, idOrigen})
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    {:ok, mensaje_id} = ChatUnoAUnoEntity.registrar_mensaje(state.chat_name, mensaje, sender)
    {:reply, {:ok, mensaje_id}, state}
  end


  def handle_call({:editar_mensaje,sender, mensajeNuevo, id_mensaje}, _from, state) do
    ChatUnoAUnoEntity.modificar_mensaje(state.chat_name, sender , mensajeNuevo, id_mensaje)
    {:reply, state, state}
  end


  def handle_call({:eliminar_mensaje, idMensaje, _idOrigen}, _from, state) do
    ChatUnoAUnoEntity.eliminar_mensaje(state.chat_name ,idMensaje)
    {:reply, state, state}
  end

  def handle_call({:get_messages}, _from, state) do
    mensajes = ChatUnoAUnoEntity.get_mensajes(state.chat_name)
    {:reply, mensajes, state}
  end

  defp get_chat_pid(username1, username2) do
    ChatUnoAUnoServer.get_chat(username1, username2)
  end

end
