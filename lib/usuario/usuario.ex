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

  def enviar_mensaje(origen, destinatario, mensaje) do
    pid = get_pid(origen)
    GenServer.call(pid, {:enviar_mensaje, destinatario, mensaje})
  end

  def enviar_mensaje_grupo(origen, nombre_grupo, mensaje) do
    pid = UsuarioServer.get_user(origen)
    GenServer.call(pid, {:enviar_mensaje_grupo, nombre_grupo, mensaje})
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

  def informar_grupo(nombre_grupo, username) do
    pid = UsuarioServer.get_user(username)
    GenServer.cast(pid, {:informar_grupo, nombre_grupo})
  end

  defp obtener_chat_destino(origen, destino) do
    ChatUnoAUnoServer.get_chat(origen, destino)
  end

  def handle_call({:crear_grupo, nombre_grupo}, _from, state) do
    case GrupoServer.crear_grupo(nombre_grupo, state.nombre) do
      :already_exists -> {:reply, :already_exists, state.nombre}
      _ -> informar_grupo(nombre_grupo, state.nombre)
      {:reply, :ok, state}
    end
  end
  def handle_call({:crear_chat, destinatario}, _from, state) do
    UsuarioServer.get_user(destinatario)
    chat_name = ChatUnoAUnoServer.register_chat(destinatario, state.nombre)
    Usuario.informar_chat(chat_name, state.nombre, destinatario)
    mi_agente = UsuarioAgentRegistry.lookup(state.nombre)
    UsuarioAgent.agregar_chat_uno_a_uno(mi_agente, chat_name)
    {:reply, chat_name, state}

  end

  def handle_call({:enviar_mensaje, destinatario, mensaje}, _from, state) do
    repuestaChat = ChatUnoAUno.enviar_mensaje(state.nombre, destinatario, mensaje)
    
    IO.puts("Sending Message to.. -> "<>destinatario)
    host = String.to_atom(destinatario<>"@"<>"iaschost")
    Node.connect(host)
    send List.first(Swarm.members({:cliente, destinatario})), mensaje

    {:reply, repuestaChat, state}
  end

  def handle_call({:enviar_mensaje_grupo, destinatario, mensaje}, _from, state) do
    repuestaChat = ChatDeGrupo.enviar_mensaje(state.nombre, destinatario, mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:editar_mensaje, destinatario, mensajeNuevo, idMensaje}, _from, state) do
    repuestaChat = ChatUnoAUno.editar_mensaje(state.nombre, destinatario, mensajeNuevo, idMensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:eliminar_mensaje, destinatario, mensaje}, _from, state) do
    repuestaChat = ChatUnoAUno.eliminar_mensaje(state.nombre, destinatario, mensaje)
    {:reply, repuestaChat, state}
  end

  def handle_call({:obtener_chats}, _from, state) do
    mi_agente = UsuarioAgentRegistry.lookup(state.nombre)
    chats = UsuarioAgent.get_chats_uno_a_uno(mi_agente)
    {:reply, chats, state}
  end

  def handle_cast({:informar_chat, chat_name}, state) do
    mi_agente = UsuarioAgentRegistry.lookup(state.nombre)
    UsuarioAgent.agregar_chat_uno_a_uno(mi_agente, chat_name)
    {:noreply, state}
  end

  def handle_cast({:informar_grupo, nombre_grupo}, state) do
    mi_agente = UsuarioAgentRegistry.lookup(state.nombre)
    UsuarioAgent.agregar_chat_de_grupo(mi_agente, nombre_grupo)
    {:noreply, state}
  end
end

# {:ok, pidUsuario} = Usuario.start_link(:usuario1, [])
# chatCreado = Usuario.iniciar_chat(pidUsuario, :usuario2)
# respuestaChat = Usuario.enviar_mensaje(pidUsuario, :usuario2, "holaa")
