defmodule Cliente do
  use GenServer

  @timeout 10000

  def start_link(userName) do
    GenServer.start_link(__MODULE__, userName, name: build_name(userName))
  end

  def init(userName) do
    state = %{
      userName: userName,
      pid: nil
    }

    Swarm.join({:cliente, userName}, self())
    {:ok, state}
  end

  def registrar(pid) do
    GenServer.call(pid, {:registrar})
  end

  ############## UNO A UNO ###################

  def enviar_mensaje(receiver, mensaje, pid) do
    GenServer.call(pid, {:enviar_mensaje, receiver, mensaje}, @timeout)
  end

  def editar_mensaje(receiver, mensaje_nuevo, id_mensaje, pid) do
    GenServer.call(pid,{:editar_mensaje, receiver, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje(receiver, id_mensaje, pid) do
    GenServer.call(pid,{:eliminar_mensaje, receiver, id_mensaje})
  end

  ############## GRUPOS ###################


  def crear_grupo(nombre_grupo, pid) do
    GenServer.call(pid, {:crear_grupo, nombre_grupo})
  end

  def agregar_usuario_a_grupo(usuario, nombre_grupo, pid) do
    GenServer.call(pid, {:agregar_usuario_a_grupo, usuario, nombre_grupo}, @timeout)
  end

  def enviar_mensaje_grupo(nombre_grupo, mensaje, pid) do
    GenServer.call(pid, {:enviar_mensaje_grupo, nombre_grupo, mensaje}, @timeout)
  end

  def editar_mensaje_grupo(nombre_grupo, mensaje_nuevo, id_mensaje, pid) do
    GenServer.call(pid, {:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje}, @timeout)
  end

  def eliminar_mensaje_grupo(nombre_grupo, id_mensaje, pid) do
    GenServer.call(pid, {:eliminar_mensaje_grupo, nombre_grupo, id_mensaje}, @timeout)
  end

  ############## CHAT SEGURO ###################

  def crear_chat_seguro(receiver, tiempo_limite, pid) do
    GenServer.call(pid, {:crear_chat_seguro, receiver, tiempo_limite})
  end

  def enviar_mensaje_seguro(receiver, mensaje, pid) do
    GenServer.call(pid, {:enviar_mensaje_seguro, receiver, mensaje}, @timeout)
  end

  def obtener_chats_seguros(pid) do
    GenServer.call(pid, {:obtener_chats_seguros})
  end

  def build_name(nombre) do
    name = :crypto.hash(:md5, nombre <> to_string(DateTime.utc_now())) |> Base.encode16()
    {:via, :swarm, name}
  end

  #################################################################################
  ############################### PRIVATE #########################################
  #################################################################################

  def handle_call({:registrar}, _from, state) do
    :rpc.call(routeo_nodo(), UsuarioServer, :register_user, [state.userName])
    {:reply, state, state}
  end

  ############## UNO A UNO ###################


  def handle_call({:enviar_mensaje, receiver, mensaje}, _from, state) do
    :rpc.call(routeo_nodo(), Usuario, :iniciar_chat, [state.userName, receiver])
    :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje, [state.userName, receiver, mensaje])
    {:reply, state, state}
  end

  def handle_call({:editar_mensaje, receiver, mensaje_nuevo, id_mensaje}, _from, state) do
    response = :rpc.call(routeo_nodo(), Usuario, :editar_mensaje, [state.userName, receiver, mensaje_nuevo, id_mensaje])
    {:reply, response, state}
  end

  def handle_call({:eliminar_mensaje, receiver, id_mensaje}, _from, state) do
    response = :rpc.call(routeo_nodo(), Usuario, :eliminar_mensaje, [state.userName, receiver, id_mensaje])
    {:reply, response, state}
  end


    ############## GRUPOS ###################

    def handle_call({:crear_grupo, nombre_grupo}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :crear_grupo, [state.userName, nombre_grupo])
      {:reply, state, state}
    end

    def handle_call({:agregar_usuario_a_grupo, usuario, nombre_grupo}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :agregar_usuario_a_grupo, [state.userName, usuario, nombre_grupo])
      {:reply, state, state}
    end

    def handle_call({:enviar_mensaje_grupo, nombre_grupo, mensaje}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje_grupo, [state.userName, nombre_grupo, mensaje])
      {:reply, state, state}
    end

    def handle_call({:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :editar_mensaje_grupo, [state.userName, nombre_grupo, mensaje_nuevo, id_mensaje])
      {:reply, state, state}
    end

    def handle_call({:eliminar_mensaje_grupo, nombre_grupo, id_mensaje}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :eliminar_mensaje_grupo, [state.userName, nombre_grupo, id_mensaje])
      {:reply, state, state}
    end

   ############## CHAT SEGURO ###################

  def handle_call({:crear_chat_seguro, receiver, tiempo_limite}, _from, state) do
    :rpc.call(routeo_nodo(), Usuario, :iniciar_chat_seguro, [
      state.userName,
      receiver,
      tiempo_limite
    ])

    {:reply, state, state}
  end

  def handle_call({:enviar_mensaje_seguro, receiver, mensaje_seguro}, _from, state) do
    :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje_seguro, [
      state.userName,
      receiver,
      mensaje_seguro
    ])

    {:reply, state, state}
  end

  def handle_call({:obtener_chats_seguros}, _from, state) do
    chats_seguros = :rpc.call(routeo_nodo(), Usuario, :obtener_chats_seguros, [state.userName])
    {:reply, chats_seguros, state}
  end

  def handle_info(mensaje, state) do
    IO.puts(mensaje)
    {:noreply, state}
  end

  defp routeo_nodo() do
    Router.route()
  end
end
