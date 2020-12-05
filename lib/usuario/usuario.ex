defmodule Usuario do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: UsuarioRegistry.build_name(name))
  end

  def init(name) do
    state = %{nombre: name}
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

  def crear_grupo(username, nombre_grupo) do
    pid = UsuarioServer.get_user(username)
    GenServer.call(pid, {:crear_grupo, nombre_grupo})
  end

  # def agregar_usuario(idChatDestino, usuario_origen, usuario) do
  #   GenServer.call(idChatDestino, {:agregar_usuario, usuario_origen, usuario})
  # end

  def agregar_usuario_a_grupo(user_admin, username, nombre_grupo) do
    pid = UsuarioServer.get_user(user_admin)
    GenServer.call(pid, {:agregar_usuario_a_grupo, username, nombre_grupo})
  end

  def iniciar_chat_seguro(username, destinatario, tiempo_limite) do
    pid = get_pid(username)
    GenServer.call(pid, {:crear_chat_seguro, destinatario, tiempo_limite})
  end

  def enviar_mensaje(origen, destinatario, mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:enviar_mensaje, destinatario, mensaje})
  end

  def enviar_mensaje_grupo(origen, nombre_grupo, mensaje) do
    pid = UsuarioServer.get_user(origen)
    GenServer.call(pid, {:enviar_mensaje_grupo, nombre_grupo, mensaje})
  end

  def enviar_mensaje_seguro(origen, destinatario, mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:enviar_mensaje_seguro, destinatario, mensaje})
  end

  def editar_mensaje(origen, destinatario, mensajeNuevo, idMensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:editar_mensaje, destinatario, mensajeNuevo, idMensaje})
  end

  def eliminar_mensaje(origen, destinatario, id_mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:eliminar_mensaje, destinatario, id_mensaje})
  end

  def informar_chat(chat_name, _origen, destino) do
    pid = get_pid(destino)
    GenServer.cast(pid, {:informar_chat, chat_name})
  end

  def obtener_chats(username) do
    pid = get_pid(username)
    GenServer.call(pid, {:obtener_chats})
  end

  def informar_grupo(nombre_grupo, username) do
    pid = UsuarioServer.get_user(username)
    GenServer.cast(pid, {:informar_grupo, nombre_grupo})
  end

  def editar_mensaje_grupo(origen, nombre_grupo, mensaje_nuevo, id_mensaje) do
    pid = UsuarioServer.get_user(origen)
    GenServer.call(pid, {:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje_grupo(origen, nombre_grupo, id_mensaje) do
    pid = UsuarioServer.get_user(origen)
    GenServer.call(pid, {:eliminar_mensaje_grupo, nombre_grupo, id_mensaje})
  end

#################################################################
######################## PRIVATE ################################
#################################################################


  def handle_call({:crear_grupo, nombre_grupo}, _from, state) do
    case ChatDeGrupoServer.crear_grupo(nombre_grupo, state.nombre) do
      :already_exists ->
        {:reply, :already_exists, state.nombre}

      _ ->
        informar_grupo(nombre_grupo, state.nombre)
        {:reply, :ok, state}
    end
  end

  def handle_call({:crear_chat, destinatario}, _from, state) do
    case ChatUnoAUnoServer.get_chat(state.nombre, destinatario) do
      :not_found ->
        chat_name = ChatUnoAUnoServer.register_chat(destinatario, state.nombre)
        Usuario.informar_chat(chat_name, state.nombre, destinatario)
        UsuarioEntity.agregar_chat_uno_a_uno(state.nombre, chat_name)
        {:reply, chat_name, state}

      _ ->
        {:reply, ChatUnoAUnoServer.build_chat_name(state.nombre, destinatario), state}
    end
  end

  def handle_call({:crear_chat_seguro, destinatario, tiempo_limite}, _from, state) do
    UsuarioServer.get_user(destinatario)

    chat_seguro_name =
      ChatSeguroServer.register_chat_seguro(destinatario, state.nombre, tiempo_limite)

    Usuario.informar_chat(chat_seguro_name, state.nombre, destinatario)
    UsuarioEntity.agregar_chat_seguros(state.nombre, chat_seguro_name)
    {:reply, chat_seguro_name, state}
  end

  def handle_call({:enviar_mensaje, destinatario, mensaje}, _from, state) do
    repuestaChat = ChatUnoAUno.enviar_mensaje(state.nombre, destinatario, mensaje)
    IO.inspect(repuestaChat)
    IO.puts("Sending Message to.. -> " <> destinatario)
    send(List.first(Swarm.members({:cliente, destinatario})), mensaje)

    {:reply, repuestaChat, state}
  end

  def handle_call({:agregar_usuario_a_grupo, username, nombre_grupo}, _from, state) do
    respuestaChat = ChatDeGrupo.agregar_usuario(nombre_grupo, state.nombre, username )
    {:reply, respuestaChat, state}
  end

  def handle_call({:enviar_mensaje_grupo, nombre_grupo, mensaje}, _from, state) do
    repuestaChat = ChatDeGrupo.enviar_mensaje(state.nombre, nombre_grupo, mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:enviar_mensaje_seguro, destinatario, mensaje_seguro}, _from, state) do
    repuestaChatSeguro = ChatSeguro.enviar_mensaje(state.nombre, destinatario, mensaje_seguro)

    IO.puts("Sending Secure Message to.. -> " <> destinatario)
    send(List.first(Swarm.members({:cliente, destinatario})), mensaje_seguro)

    {:reply, repuestaChatSeguro, state}
  end

  def handle_call({:editar_mensaje, destinatario, mensajeNuevo, idMensaje}, _from, state) do
    repuestaChat = ChatUnoAUno.editar_mensaje(state.nombre, destinatario, mensajeNuevo, idMensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:eliminar_mensaje, destinatario, id_mensaje}, _from, state) do
    repuestaChat = ChatUnoAUno.eliminar_mensaje(state.nombre, destinatario, id_mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:obtener_chats}, _from, state) do
    chats = UsuarioEntity.get_chats_uno_a_uno(state.nombre)
    {:reply, chats, state}
  end

  def handle_cast({:informar_chat, chat_name}, state) do
    UsuarioEntity.agregar_chat_uno_a_uno(state.nombre, chat_name)
    {:noreply, state}
  end

  def handle_cast({:informar_grupo, nombre_grupo}, state) do
    UsuarioEntity.agregar_chat_de_grupo(state.nombre, nombre_grupo)
    {:noreply, state}
  end

  def handle_call({:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje}, _from, state) do
    repuestaChat = ChatDeGrupo.editar_mensaje(state.nombre, nombre_grupo, mensaje_nuevo, id_mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:eliminar_mensaje_grupo, nombre_grupo, id_mensaje}, _from, state) do
    repuestaChat = ChatDeGrupo.eliminar_mensaje(state.nombre, nombre_grupo, id_mensaje)
    {:reply, repuestaChat, state}
  end

end
