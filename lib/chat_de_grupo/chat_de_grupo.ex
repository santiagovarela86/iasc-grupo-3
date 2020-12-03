defmodule ChatDeGrupo do
  use GenServer

  def start_link(nombre_grupo) do
    GenServer.start_link(__MODULE__, nombre_grupo, name: ChatUnoAUnoRegistry.build_name(nombre_grupo))
  end

  def init(nombre_grupo) do
    state = %{
      nombre_grupo: nombre_grupo
    }

    {:ok, state}
  end

  def child_spec(nombre_grupo) do
    %{
      id: nombre_grupo,
      start: {__MODULE__, :start_link, [nombre_grupo]},
      type: :worker,
      restart: :transient
    }
  end

  def enviar_mensaje(sender, grupo, mensaje) do
    pid = get_grupo_pid(grupo)
    GenServer.call(pid, {:enviar_mensaje, sender, mensaje})
  end

  def get_messages(grupo) do
    pid = get_grupo_pid(grupo)
    GenServer.call(pid, {:get_messages})
  end

  def editar_mensaje(idChatDestino, mensajeNuevo, idMensaje, idOrigen) do
    GenServer.call(idChatDestino, {:editar_mensaje, mensajeNuevo, idMensaje, idOrigen})
  end

  def eliminar_mensaje(idChatDestino, idMensaje, idOrigen) do
    GenServer.call(idChatDestino, {:eliminar_mensaje, idMensaje, idOrigen})
  end

  def ascender_usuario(nombre_grupo, usuario_origen, usuario_ascendido) do
    pid = get_grupo_pid(nombre_grupo)
    GenServer.call(pid, {:ascender_usuario, usuario_origen, usuario_ascendido})
  end

  def eliminar_usuario(idChatDestino, usuario_origen, usuario_ascendido) do
    GenServer.call(idChatDestino, {:eliminar_usuario, usuario_origen, usuario_ascendido})
  end

  def agregar_usuario(nombre_grupo, usuario_origen, usuario) do
    pid = get_grupo_pid(nombre_grupo)
    GenServer.call(pid, {:agregar_usuario, usuario_origen, usuario})
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    ChatDeGrupoEntity.registrar_mensaje(state.nombre_grupo, mensaje, sender)
    {:reply, :ok, state}
  end

  def handle_call({:ascender_usuario, usuario_origen, usuario_ascendido}, _from, state) do
    if(es_administrador(usuario_origen, state.nombre_grupo)) do
      if(es_usuario(usuario_ascendido, state.nombre_grupo)) do
        agregar_administrador(usuario_ascendido, state.nombre_grupo)
      else
        {:reply, :user_not_found, state}
      end
    else
      {:reply, :not_admin, state}
    end

    {:reply, :ok, state}
  end

  def handle_call({:agregar_usuario, usuario_origen, usuario}, _from, state) do
    if(es_administrador(usuario_origen, state.nombre_grupo)) do
        ChatDeGrupoEntity.agregar_usuario(state.nombre_grupo, usuario)
        {:reply, :ok, state}
    else
      {:reply, :not_admin, state}
    end
  end

  def handle_call({:eliminar_usuario, usuario_origen, usuario_eliminado}, _from, state) do
    if(es_administrador(usuario_origen, state.nombre_grupo)) do
      if(es_usuario(usuario_eliminado, state.nombre_grupo)) do
        ChatDeGrupoEntity.eliminar_usuario(state.nombre_grupo, usuario_eliminado)
      else
        {:reply, :user_not_found, state}
      end
    else
      {:reply, :not_admin, state}
    end

    {:reply, :ok, state}

  end

  def handle_call({:editar_mensaje, mensajeNuevo, idMensaje, idOrigen}, _from, state) do
    fn_a_ejecutar = fn ->
      ChatDeGrupoEntity.modificar_mensaje(state.nombre_grupo, idOrigen, mensajeNuevo, idMensaje)
    end

    ejecutar_si_tiene_permiso(state.nombre_grupo, idOrigen, idMensaje, fn_a_ejecutar)
  end

  def handle_call({:eliminar_mensaje, idMensaje, idOrigen}, _from, state) do
    fn_a_ejecutar = fn -> ChatDeGrupoEntity.eliminar_mensaje(state.nombre_grupo, idMensaje) end
    ejecutar_si_tiene_permiso(state.nombre_grupo, idOrigen, idMensaje, fn_a_ejecutar)
  end

  def handle_call({:get_messages}, _from, state) do
    {:reply, ChatDeGrupoEntity.get_mensajes(state.nombre_grupo), state}
  end


  def getHash(mensaje) do
    :crypto.hash(:md5, mensaje <> to_string(DateTime.utc_now)) |> Base.encode16()
  end

  def ejecutar_si_tiene_permiso(nombre_grupo, origen, id_mensaje, fn_a_ejecutar) do
    case Enum.find(ChatDeGrupoEntity.get_mensajes(nombre_grupo), :not_found, fn m ->
           m.mensaje_id == id_mensaje
         end) do
      :not_found ->
        :not_found
      mensaje ->
        if(puede_borrar(nombre_grupo, mensaje, origen)) do
          fn_a_ejecutar.()
          :ok
        else
          :forbidden
        end
    end
  end

  defp get_grupo_pid(nombre_grupo) do
    GrupoServer.get_grupo(nombre_grupo)
  end

  defp es_administrador(usuario, nombre_grupo) do
    Enum.member?(obtener_administradores(nombre_grupo), usuario)
  end

  defp obtener_administradores(nombre_grupo) do
    ChatDeGrupoEntity.get_admins(nombre_grupo)
  end

  defp es_usuario(ususario, nombre_grupo) do
    Enum.member?(obtener_usuarios(nombre_grupo), ususario)
  end

  defp obtener_usuarios(nombre_grupo) do
    ChatDeGrupoEntity.get_usuarios(nombre_grupo)
  end

  defp agregar_administrador(usuario_ascendido, nombre_grupo) do
    ChatDeGrupoEntity.agregar_admin(nombre_grupo, usuario_ascendido)
  end

  defp puede_borrar(nombre_grupo, mensaje, origen) do
    es_administrador(origen, nombre_grupo) || mensaje.origen == origen
  end

end
