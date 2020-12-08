defmodule ChatDeGrupo do
  use GenServer

  def start_link([nombre_grupo, usuario_admin]) do
    GenServer.start_link(__MODULE__, [nombre_grupo, usuario_admin], name: register(nombre_grupo))
  end

  def init([nombre_grupo, usuario_admin]) do
    state = %{
      nombre_grupo: nombre_grupo
    }
    {_, agente} = ChatDeGrupoAgent.start_link(usuario_admin, nombre_grupo)
    ServerEntity.agregar_chat_de_grupo(nombre_grupo)
    ServerEntity.copiar(agente, {:chat_de_grupo_agent, nombre_grupo})
    Swarm.join({:chat_de_grupo_agent, nombre_grupo}, agente)
    {:ok, state}
  end

  def child_spec(nombre_grupo) do
    %{
      id: nombre_grupo,
      start: {__MODULE__, :start_link, [nombre_grupo]},
      type: :worker,
      restart: :permanent
    }
  end

  def enviar_mensaje(sender, grupo, mensaje) do
    {_ok?, pid} = ChatDeGrupoServer.get(grupo)
    GenServer.call(pid, {:enviar_mensaje, sender, mensaje})
  end

  def get_messages(grupo) do
    {_ok?, pid} = ChatDeGrupoServer.get(grupo)
    GenServer.call(pid, {:get_messages})
  end

  def editar_mensaje(sender, grupo, mensaje_nuevo, id_mensaje) do
    {_ok?, pid} = ChatDeGrupoServer.get(grupo)
    GenServer.call(pid, {:editar_mensaje, sender, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje(sender, grupo, id_mensaje) do
    {_ok?, pid} = ChatDeGrupoServer.get(grupo)
    GenServer.call(pid, {:eliminar_mensaje, sender, id_mensaje})
  end

  def ascender_usuario(nombre_grupo, usuario_origen, usuario_ascendido) do
    {_ok?, pid} = ChatDeGrupoServer.get(nombre_grupo)
    GenServer.call(pid, {:ascender_usuario, usuario_origen, usuario_ascendido})
  end

  def eliminar_usuario(nombre_grupo, usuario_origen, usuario) do
    {_ok?, pid} = ChatDeGrupoServer.get(nombre_grupo)
    GenServer.call(pid, {:eliminar_usuario, usuario_origen, usuario})
  end

  def agregar_usuario(nombre_grupo, usuario_origen, usuario) do
    {_ok?, pid} = ChatDeGrupoServer.get(nombre_grupo)
    GenServer.call(pid, {:agregar_usuario, usuario_origen, usuario})
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    ChatDeGrupoEntity.registrar_mensaje(state.nombre_grupo, mensaje, sender)

    {:ok, usuarios} = ChatDeGrupoEntity.get_usuarios(state.nombre_grupo)

    fn(cliente) -> send(cliente, mensaje) end
    |> (&fn(usuario) -> Enum.each(Swarm.members({:cliente, usuario}), &1)end).()
    |> (&Enum.each(usuarios, fn(usuario) -> Task.start(fn -> &1.(usuario) end) end)).()

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

  def handle_call({:editar_mensaje, sender, mensaje_nuevo, id_mensaje}, _from, state) do
    fn_a_ejecutar = fn ->
      ChatDeGrupoEntity.modificar_mensaje(state.nombre_grupo, sender, mensaje_nuevo, id_mensaje)

    {:reply, :ok, state}
    end

    ejecutar_si_tiene_permiso(state.nombre_grupo, sender, id_mensaje, fn_a_ejecutar)
  end

  def handle_call({:eliminar_mensaje, sender, id_mensaje}, _from, state) do
    fn_a_ejecutar = fn -> ChatDeGrupoEntity.eliminar_mensaje(state.nombre_grupo, id_mensaje) end
    ejecutar_si_tiene_permiso(state.nombre_grupo, sender, id_mensaje, fn_a_ejecutar)
    {:reply, :ok, state}
  end

  def handle_call({:get_messages}, _from, state) do
    {:reply, ChatDeGrupoEntity.get_mensajes(state.nombre_grupo), state}
  end


  def getHash(mensaje) do
    :crypto.hash(:md5, mensaje <> to_string(DateTime.utc_now)) |> Base.encode16()
  end

  def ejecutar_si_tiene_permiso(nombre_grupo, origen, id_mensaje, fn_a_ejecutar) do
    {_, mensajes} = ChatDeGrupoEntity.get_mensajes(nombre_grupo)

    case Map.has_key?(mensajes, id_mensaje) do
      false ->
        :not_found
      true ->
        if(puede_borrar(nombre_grupo, Map.fetch!(mensajes, id_mensaje), origen)) do
          fn_a_ejecutar.()
          #:ok
        else
          :forbidden
        end
    end
  end

  defp es_administrador(usuario, nombre_grupo) do
    Enum.member?(obtener_administradores(nombre_grupo), usuario)
  end

  defp obtener_administradores(nombre_grupo) do
    {_, admins} = ChatDeGrupoEntity.get_admins(nombre_grupo)
    admins
  end

  defp es_usuario(ususario, nombre_grupo) do
    Enum.member?(obtener_usuarios(nombre_grupo), ususario)
  end

  defp obtener_usuarios(nombre_grupo) do
    {_, usuarios} = ChatDeGrupoEntity.get_usuarios(nombre_grupo)
    usuarios
  end

  defp agregar_administrador(usuario_ascendido, nombre_grupo) do
    ChatDeGrupoEntity.agregar_admin(nombre_grupo, usuario_ascendido)
  end

  defp puede_borrar(nombre_grupo, mensaje, origen) do
    es_administrador(origen, nombre_grupo) || mensaje.origen == origen
  end

  def register(nombre) do
    {:via, :swarm, {:chat_de_grupo, Node.self(), nombre}}
  end
end
