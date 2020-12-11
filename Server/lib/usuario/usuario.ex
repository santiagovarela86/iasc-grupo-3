defmodule Usuario do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: register(name))
  end

  def init(name) do
    state = %{nombre: name}
    {_, agente} = UsuarioAgent.start_link(name)
    ServerEntity.agregar_usuario(name)
    ServerEntity.copiar(agente, {:usuario_agent, name})
    Swarm.join({:usuario_agent, name}, agente)
    {:ok, state}

  end

  def child_spec(name) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name]},
      type: :worker,
      restart: :permanent
    }
  end

  defp get_pid(username) do
    {_ok?, pid} = UsuarioServer.get(username)
    pid
  end

  def iniciar_chat(username, destinatario) do
    pid = get_pid(username)
    GenServer.call(pid, {:crear_chat, destinatario})
  end

  def crear_grupo(username, nombre_grupo) do
    pid = get_pid(username)
    GenServer.call(pid, {:crear_grupo, nombre_grupo})
  end

  # def agregar_usuario(idChatDestino, usuario_origen, usuario) do
  #   GenServer.call(idChatDestino, {:agregar_usuario, usuario_origen, usuario})
  # end

  def agregar_usuario_a_grupo(user_admin, username, nombre_grupo) do
    pid = get_pid(user_admin)
    GenServer.call(pid, {:agregar_usuario_a_grupo, username, nombre_grupo})
  end

  def eliminar_usuario_grupo(user_admin, username, nombre_grupo) do
    pid = get_pid(user_admin)
    GenServer.call(pid, {:eliminar_usuario_grupo, username, nombre_grupo})
  end

  def ascender_usuario_grupo(user_admin, username, nombre_grupo) do
    pid = get_pid(user_admin)
    GenServer.call(pid, {:ascender_usuario_grupo, username, nombre_grupo})
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
    pid = get_pid(origen)
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

  def informar_chat_seguro(chat_name, _origen, destino) do
    pid = get_pid(destino)
    GenServer.cast(pid, {:informar_chat_seguro, chat_name})
  end

  def obtener_chats(username) do
    pid = get_pid(username)
    GenServer.call(pid, {:obtener_chats})
  end

  def obtener_mensajes(origen, destinatario) do
    pid = get_pid(origen)
    GenServer.call(pid, {:obtener_mensajes, destinatario})
  end

  def obtener_mensajes_grupo(origen, nombre_grupo) do
    pid = get_pid(origen)
    GenServer.call(pid, {:obtener_mensajes_grupo, nombre_grupo})
  end

  def obtener_mensajes_seguro(origen, destinatario) do
    pid = get_pid(origen)
    GenServer.call(pid, {:obtener_mensajes_seguro, destinatario})
  end

  def informar_grupo(nombre_grupo, username) do
    pid = get_pid(username)
    GenServer.cast(pid, {:informar_grupo, nombre_grupo})
  end

  def editar_mensaje_grupo(origen, nombre_grupo, mensaje_nuevo, id_mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje_grupo(origen, nombre_grupo, id_mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:eliminar_mensaje_grupo, nombre_grupo, id_mensaje})
  end

  def editar_mensaje_seguro(origen, destinatario, mensaje_nuevo, id_mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:editar_mensaje_seguro, destinatario, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje_seguro(origen, destinatario, id_mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:eliminar_mensaje_seguro, destinatario, id_mensaje})
  end

  def register(nombre) do
    {:via, :swarm, {:usuario, Node.self(), nombre}}
  end


#################################################################
######################## PRIVATE ################################
#################################################################


  def handle_call({:crear_grupo, nombre_grupo}, _from, state) do
    case ChatDeGrupoServer.crear(nombre_grupo, state.nombre) do
      {:already_exists, _pid} ->
        {:reply, :already_exists, state}

      {:ok, _} ->
        informar_grupo(nombre_grupo, state.nombre)
        {:reply, :ok, state}
    end
  end

  def handle_call({:crear_chat, destinatario}, _from, state) do
    case ChatUnoAUnoServer.crear(destinatario, state.nombre) do
      {:ok, _} ->
        Usuario.informar_chat(MapSet.new([destinatario, state.nombre]), state.nombre, destinatario)
        chat_name = MapSet.new([state.nombre, destinatario])
        UsuarioEntity.agregar_chat_uno_a_uno(state.nombre, chat_name)
        {:reply, chat_name, state}

      {:already_exists, _} ->{:reply, MapSet.new([state.nombre, destinatario]), state}
      {:error, error} -> {:reply, error, state}
    end
  end

  def handle_call({:crear_chat_seguro, destinatario, tiempo_limite}, _from, state) do
    ChatSeguroServer.crear(destinatario, state.nombre, tiempo_limite)
    chat_seguro_name = MapSet.new([destinatario, state.nombre])
    Usuario.informar_chat_seguro(chat_seguro_name, state.nombre, destinatario)
    UsuarioEntity.agregar_chat_seguros(state.nombre, chat_seguro_name)
    {:reply, chat_seguro_name, state}
  end

  def handle_call({:enviar_mensaje, destinatario, mensaje}, _from, state) do
    repuestaChat = ChatUnoAUno.enviar_mensaje(state.nombre, destinatario, mensaje)
    IO.puts("Sending Message to.. -> " <> destinatario)
    Enum.each(Swarm.members({:cliente, destinatario}), fn pid ->  send(pid , mensaje) end)

    {:reply, repuestaChat, state}
  end

  def handle_call({:agregar_usuario_a_grupo, username, nombre_grupo}, _from, state) do
    respuestaChat = ChatDeGrupo.agregar_usuario(nombre_grupo, state.nombre, username )
    {:reply, respuestaChat, state}
  end

  def handle_call({:eliminar_usuario_grupo, username, nombre_grupo}, _from, state) do
    respuestaChat = ChatDeGrupo.eliminar_usuario(nombre_grupo, state.nombre, username )
    {:reply, respuestaChat, state}
  end

  def handle_call({:ascender_usuario_grupo, username, nombre_grupo}, _from, state) do
    respuestaChat = ChatDeGrupo.ascender_usuario(nombre_grupo, state.nombre, username )
    {:reply, respuestaChat, state}
  end

  def handle_call({:enviar_mensaje_grupo, nombre_grupo, mensaje}, _from, state) do
    repuestaChat = ChatDeGrupo.enviar_mensaje(state.nombre, nombre_grupo, mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:enviar_mensaje_seguro, destinatario, mensaje_seguro}, _from, state) do
    repuestaChatSeguro = ChatSeguro.enviar_mensaje(state.nombre, destinatario, mensaje_seguro)

    IO.puts("Sending Secure Message to.. -> " <> destinatario)
    Enum.each(Swarm.members({:cliente, destinatario}), fn pid ->  send(pid , mensaje_seguro) end)

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

  def handle_call({:obtener_mensajes, destinatario}, _from, state) do
    mensajes = ChatUnoAUno.get_messages(state.nombre, destinatario)
    {:reply, mensajes, state}
  end

  def handle_call({:obtener_mensajes_grupo, nombre_grupo}, _from, state) do
    mensajes = ChatDeGrupo.get_messages(nombre_grupo)
    {:reply, mensajes, state}
  end

  def handle_call({:obtener_mensajes_seguro, destinatario}, _from, state) do
    mensajes = ChatSeguro.get_messages(state.nombre, destinatario)
    {:reply, mensajes, state}
  end

  def handle_call({:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje}, _from, state) do
    repuestaChat = ChatDeGrupo.editar_mensaje(state.nombre, nombre_grupo, mensaje_nuevo, id_mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:editar_mensaje_seguro, destinatario, mensaje_nuevo, id_mensaje}, _from, state) do
    repuestaChat = ChatSeguro.editar_mensaje(state.nombre, destinatario, mensaje_nuevo, id_mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:eliminar_mensaje_grupo, nombre_grupo, id_mensaje}, _from, state) do
    repuestaChat = ChatDeGrupo.eliminar_mensaje(state.nombre, nombre_grupo, id_mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:eliminar_mensaje_seguro, destinatario, id_mensaje}, _from, state) do
    repuestaChat = ChatSeguro.eliminar_mensaje(state.nombre, destinatario, id_mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_cast({:informar_chat, chat_name}, state) do
    UsuarioEntity.agregar_chat_uno_a_uno(state.nombre, chat_name)
    {:noreply, state}
  end

  def handle_cast({:informar_chat_seguro, chat_name}, state) do
    UsuarioEntity.agregar_chat_seguros(state.nombre, chat_name)
    {:noreply, state}
  end

  def handle_cast({:informar_grupo, nombre_grupo}, state) do
    UsuarioEntity.agregar_chat_de_grupo(state.nombre, nombre_grupo)
    {:noreply, state}
  end

end
