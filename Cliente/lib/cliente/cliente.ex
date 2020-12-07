defmodule Cliente do
  use GenServer

  @timeout 10000

  def start_link(userName) do
    GenServer.start_link(__MODULE__, userName, name: build_name(userName))
  end

  def init(_userName) do
    state = %{
      userName: name(),
      pid: nil
    }


    Swarm.join({:cliente, name()}, self())
    registrarme()
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

  def registrar(pid) do
    GenServer.call(pid, {:registrar})
  end

  defp registrarme() do
    :rpc.call(routeo_nodo(), UsuarioServer, :crear, [name()])
    name()
  end

  ############## UNO A UNO ###################

  def enviar_mensaje(receiver, mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
	IO.puts("DEBUG A1: ")
	IO.puts(inspect(pid))
	IO.puts(inspect(receiver))
	IO.puts(inspect(mensaje))
    GenServer.call(pid, {:enviar_mensaje, receiver, mensaje}, @timeout)
  end

  def editar_mensaje(receiver, mensaje_nuevo, id_mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid,{:editar_mensaje, receiver, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje(receiver, id_mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid,{:eliminar_mensaje, receiver, id_mensaje})
  end

  def obtener_mensajes(receiver) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid,{:obtener_mensajes, receiver})
  end

  ############## GRUPOS ###################

  def eliminar_usuario_grupo(usuario, nombre_grupo) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:eliminar_usuario_grupo, usuario, nombre_grupo}, @timeout)
  end

  def ascender_usuario_grupo(usuario, nombre_grupo) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid,{:ascender_usuario_grupo, usuario, nombre_grupo})
  end

  def crear_grupo(nombre_grupo) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:crear_grupo, nombre_grupo})
  end

  def agregar_usuario_a_grupo(usuario, nombre_grupo) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:agregar_usuario_a_grupo, usuario, nombre_grupo}, @timeout)
  end

  def enviar_mensaje_grupo(nombre_grupo, mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:enviar_mensaje_grupo, nombre_grupo, mensaje}, @timeout)
  end

  def editar_mensaje_grupo(nombre_grupo, mensaje_nuevo, id_mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje}, @timeout)
  end

  def eliminar_mensaje_grupo(nombre_grupo, id_mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:eliminar_mensaje_grupo, nombre_grupo, id_mensaje}, @timeout)
  end

  def obtener_mensajes_grupo(nombre_grupo) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid,{:obtener_mensajes_grupo, nombre_grupo})
  end


  ############## CHAT SEGURO ###################

  def crear_chat_seguro(receiver, tiempo_limite) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:crear_chat_seguro, receiver, tiempo_limite})
  end

  def enviar_mensaje_seguro(receiver, mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:enviar_mensaje_seguro, receiver, mensaje}, @timeout)
  end

  def editar_mensaje_seguro(receiver, mensaje_nuevo, id_mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:editar_mensaje_seguro, receiver, mensaje_nuevo, id_mensaje}, @timeout)
  end

  def eliminar_mensaje_seguro(receiver, id_mensaje) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid, {:eliminar_mensaje_seguro, receiver, id_mensaje}, @timeout)
  end

  def obtener_mensajes_seguro(receiver) do
    pid = List.first(Enum.to_list(Enum.filter(clientes_mios(), fn(pid) -> is_local(pid) end)))
    GenServer.call(pid,{:obtener_mensajes_seguro, receiver})
  end

  def build_name(nombre) do
    name = :crypto.hash(:md5, nombre <> to_string(DateTime.utc_now())) |> Base.encode16()
    {:via, :swarm, name}
  end

  #################################################################################
  ############################### PRIVATE #########################################
  #################################################################################

  def handle_call({:registrar}, _from, state) do
    :rpc.call(routeo_nodo(), UsuarioServer, :crear, [name()])
    {:reply, state, state}
  end

  ############## UNO A UNO ###################


  def handle_call({:enviar_mensaje, receiver, mensaje}, _from, state) do
	IO.puts("DEBUG A2: ")
	IO.puts(inspect(routeo_nodo()))
	IO.puts("DEBUG A3: ")
	IO.puts(inspect(name()))
	IO.puts("DEBUG A4: ")
	IO.puts(inspect(receiver))
	IO.puts("DEBUG A5: ")
	IO.puts(inspect(mensaje))  
    :rpc.call(routeo_nodo(), Usuario, :iniciar_chat, [name(), receiver])
	IO.puts("DEBUG A6: ")
    :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje, [name(), receiver, mensaje])
	IO.puts("DEBUG A7: ")
    {:reply, state, state}
  end

  def handle_call({:editar_mensaje, receiver, mensaje_nuevo, id_mensaje}, _from, state) do
    response = :rpc.call(routeo_nodo(), Usuario, :editar_mensaje, [name(), receiver, mensaje_nuevo, id_mensaje])
    {:reply, response, state}
  end

  def handle_call({:eliminar_mensaje, receiver, id_mensaje}, _from, state) do
    response = :rpc.call(routeo_nodo(), Usuario, :eliminar_mensaje, [name(), receiver, id_mensaje])
    {:reply, response, state}
  end

  def handle_call({:obtener_mensajes, receiver}, _from, state) do
    response = :rpc.call(routeo_nodo(), Usuario, :obtener_mensajes, [state.userName, receiver])
    {:reply, response, state}
  end


    ############## GRUPOS ###################

    def handle_call({:crear_grupo, nombre_grupo}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :crear_grupo, [name(), nombre_grupo])
      {:reply, state, state}
    end

    def handle_call({:agregar_usuario_a_grupo, usuario, nombre_grupo}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :agregar_usuario_a_grupo, [name(), usuario, nombre_grupo])
      {:reply, state, state}
    end

    def handle_call({:eliminar_usuario_grupo, usuario, nombre_grupo}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :eliminar_usuario_grupo, [state.userName, usuario, nombre_grupo])
      {:reply, state, state}
    end

    def handle_call({:ascender_usuario_grupo, usuario, nombre_grupo}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :ascender_usuario_grupo, [state.userName, usuario, nombre_grupo])
      {:reply, state, state}
    end

    def handle_call({:enviar_mensaje_grupo, nombre_grupo, mensaje}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje_grupo, [name(), nombre_grupo, mensaje])
      {:reply, state, state}
    end

    def handle_call({:editar_mensaje_grupo, nombre_grupo, mensaje_nuevo, id_mensaje}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :editar_mensaje_grupo, [name(), nombre_grupo, mensaje_nuevo, id_mensaje])
      {:reply, state, state}
    end

    def handle_call({:eliminar_mensaje_grupo, nombre_grupo, id_mensaje}, _from, state) do
      :rpc.call(routeo_nodo(), Usuario, :eliminar_mensaje_grupo, [name(), nombre_grupo, id_mensaje])
      {:reply, state, state}
    end

    def handle_call({:obtener_mensajes_grupo, nombre_grupo}, _from, state) do
      response = :rpc.call(routeo_nodo(), Usuario, :obtener_mensajes_grupo, [state.userName, nombre_grupo])
      {:reply, response, state}
    end

   ############## CHAT SEGURO ###################

  def handle_call({:crear_chat_seguro, receiver, tiempo_limite}, _from, state) do
    :rpc.call(routeo_nodo(), Usuario, :iniciar_chat_seguro, [
      name(),
      receiver,
      tiempo_limite
    ])

    {:reply, state, state}
  end

  def handle_call({:enviar_mensaje_seguro, receiver, mensaje_seguro}, _from, state) do
    :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje_seguro, [
      name(),
      receiver,
      mensaje_seguro
    ])

    {:reply, state, state}
  end


  def handle_call({:editar_mensaje_seguro, receiver, mensaje_nuevo, id_mensaje}, _from, state) do
    :rpc.call(routeo_nodo(), Usuario, :editar_mensaje_seguro, [name(), receiver, mensaje_nuevo, id_mensaje])
    {:reply, state, state}
  end

  def handle_call({:eliminar_mensaje_seguro, receiver, id_mensaje}, _from, state) do
    :rpc.call(routeo_nodo(), Usuario, :eliminar_mensaje_seguro, [name(), receiver, id_mensaje])
    {:reply, state, state}
  end

  def handle_call({:obtener_mensajes_seguro, receiver}, _from, state) do
    response = :rpc.call(routeo_nodo(), Usuario, :obtener_mensajes_seguro, [state.userName, receiver])
    {:reply, response, state}
  end

  def handle_info(mensaje, state) do
    IO.puts(mensaje)
    {:noreply, state}
  end

  defp routeo_nodo() do
    Router.route()
  end

  def name() do
    List.first(String.split(to_string(Node.self),"@"))
  end

  defp clientes_mios() do
    Swarm.members({:cliente, name()})
  end

  defp is_local(pid) do
    Enum.take(:erlang.pid_to_list(pid), 2) == '<0'
  end


end
