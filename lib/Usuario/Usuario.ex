defmodule Usuario do
  use GenServer

  def start_link(name, chats) do
    GenServer.start_link(__MODULE__, {name, chats}, name: name)
  end

  def init({name, chats}) do
    state = %{
      name: name,
      chats: chats
    }
    {:ok, state}
  end

  def iniciar_chat(pid, destinatario) do
    GenServer.call(pid, {:crear_chat, destinatario})
  end

  def enviar_mensaje(pid, destinatario, mensaje) do
    GenServer.call(pid, {:enviar_mensaje, destinatario, mensaje})

  end

  def editar_mensaje(pid, destinatario, mensajeNuevo, idMensaje) do
    GenServer.call(pid, {:editar_mensaje, destinatario, mensajeNuevo, idMensaje})

  end

  def eliminar_mensaje(pid, destinatario, idMensaje) do
    GenServer.call(pid, {:eliminar_mensaje, destinatario, idMensaje})

  end

  def get_historial(:group_chat, group) do

  end

  defp obtener_chat_destino(_destino) do
    ## Separado
    :id_chat
  end

  def handle_call({:crear_chat, destinatario}, _from, state) do
    mensajesIniciales = []
    personasInvolucradas = [destinatario] ++ state.name

    {:ok, pidChat} = Chat.start_link(mensajesIniciales, personasInvolucradas, :id_chat)

    nuevoState = Map.update!(state, :chats, fn(chats) -> chats ++ [pidChat] end)

    {:reply, :id_chat, nuevoState}

  end

  def handle_call({:enviar_mensaje, destinatario, mensaje}, _from, state) do
    idChatDestino = obtener_chat_destino(destinatario)
    repuestaChat = Chat.enviar_mensaje(idChatDestino, mensaje, state.name)
    {:reply, repuestaChat, state}
  end

  def handle_call({:editar_mensaje, destinatario, mensajeNuevo, idMensaje}, _from, state) do
    idChatDestino = obtener_chat_destino(destinatario)
    repuestaChat = Chat.editar_mensaje(idChatDestino, mensajeNuevo, idMensaje, state.name)
    {:reply, repuestaChat, state}
  end

  def handle_call({:eliminar_mensaje, destinatario, idMensaje}, _from, state) do
    idChatDestino = obtener_chat_destino(destinatario)
    repuestaChat = Chat.eliminar_mensaje(idChatDestino, idMensaje, state.name)
    {:reply, repuestaChat, state}
  end

end

# {:ok, pidUsuario} = Usuario.start_link(:usuario1, [])
# chatCreado = Usuario.iniciar_chat(pidUsuario, :usuario2)
# respuestaChat = Usuario.enviar_mensaje(pidUsuario, :usuario2, "holaa")
