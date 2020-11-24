defmodule Usuario do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: UsuarioRegistry.build_name(name))
  end

  def init(name) do
    state = name
    {:ok, state}
  end

  def child_spec(name) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name]},
      type: :worker,
      restart: :transient
    }
  end

  defp get_pid(username) do
    UsuarioServer.get_user(username)
  end

  def iniciar_chat(username, destinatario) do
    pid = get_pid(username)
    GenServer.call(pid, {:crear_chat, destinatario})
  end

  def enviar_mensaje(origen, destinatario, mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:enviar_mensaje, destinatario, mensaje})
  end

  def editar_mensaje(origen, destinatario, mensajeNuevo, idMensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:editar_mensaje, destinatario, mensajeNuevo, idMensaje})
  end

  def eliminar_mensaje(origen, destinatario, mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:eliminar_mensaje, destinatario, mensaje})
  end

  def informar_chat(chat_name, _origen, destino) do
    pid = get_pid(destino)
    GenServer.cast(pid, {:informar_chat, chat_name})
  end

  def obtener_chats(username) do
    pid = get_pid(username)
    GenServer.call(pid, {:obtener_chats})
  end

  def handle_call({:crear_chat, destinatario}, _from, state) do
    UsuarioServer.get_user(destinatario)
    chat_name = ChatServer.register_chat(destinatario, state)
    Usuario.informar_chat(chat_name, state, destinatario)
    mi_agente = UsuarioAgentRegistry.lookup(state)
    UsuarioAgent.agregar_chat_uno_a_uno(mi_agente, chat_name)
    {:reply, chat_name, state}
  end

  def handle_call({:enviar_mensaje, destinatario, mensaje}, _from, state) do
    repuestaChat = Chat.enviar_mensaje(state, destinatario, mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:editar_mensaje, destinatario, mensajeNuevo, idMensaje}, _from, state) do
    repuestaChat = Chat.editar_mensaje(state, destinatario, mensajeNuevo, idMensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:eliminar_mensaje, destinatario, mensaje}, _from, state) do
    repuestaChat = Chat.eliminar_mensaje(state, destinatario, mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:obtener_chats}, _from, state) do
    mi_agente = UsuarioAgentRegistry.lookup(state)
    chats = UsuarioAgent.get_chats_uno_a_uno(mi_agente)
    {:reply, chats, state}
  end

  def handle_cast({:informar_chat, chat_name}, state) do
    mi_agente = UsuarioAgentRegistry.lookup(state)
    UsuarioAgent.agregar_chat_uno_a_uno(mi_agente, chat_name)
    {:noreply, state}
  end

end

# {:ok, pidUsuario} = Usuario.start_link(:usuario1, [])
# chatCreado = Usuario.iniciar_chat(pidUsuario, :usuario2)
# respuestaChat = Usuario.enviar_mensaje(pidUsuario, :usuario2, "holaa")
