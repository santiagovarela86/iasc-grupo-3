defmodule Cliente do

    use GenServer

    @user_server "userServer1"
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
        response = GenServer.call(pid,{:registrar})
    end

    def crear_chat(receiver, pid) do
        GenServer.call(pid,{:crear_chat, receiver})
    end

    def enviar_mensaje(receiver, mensaje, pid) do
        GenServer.call(pid,{:enviar_mensaje, receiver, mensaje}, @timeout)
    end

    def editar_mensaje(receiver, mensaje_nuevo, id_mensaje, pid) do
        GenServer.call(pid,{:editar_mensaje, receiver, mensaje_nuevo, id_mensaje})
    end

    def crear_chat_seguro(receiver, tiempo_limite, pid) do
        GenServer.call(pid,{:crear_chat_seguro, receiver, tiempo_limite})
    end

    def enviar_mensaje_seguro(receiver, mensaje, pid) do
        GenServer.call(pid,{:enviar_mensaje_seguro, receiver, mensaje}, @timeout)
    end

    def build_name(nombre) do
        name = :crypto.hash(:md5, nombre <> to_string(DateTime.utc_now)) |> Base.encode16()
        {:via, :swarm, name}
    end

######################################

    def handle_call({:registrar}, _from, state) do
        Node.connect(local_name(@user_server))
        response = :rpc.call(local_name(@user_server), UsuarioServer, :register_user, [state.userName])
        {:reply, response, state}
    end

    def handle_call({:crear_chat, receiver}, _from, state) do
        :rpc.call(local_name(@user_server), Usuario, :iniciar_chat, [state.userName, receiver])
        {:reply, state, state}
    end

    def handle_call({:enviar_mensaje, receiver, mensaje}, _from, state) do
        #:rpc.call(local_name(@user_server), Usuario, :iniciar_chat, [state.userName, receiver])
        response = :rpc.call(local_name(@user_server), Usuario, :enviar_mensaje, [state.userName, receiver, mensaje])
        #IO.puts("MMMMMMMMMMMMMMMMMMMMMMMMMMMM")
        #IO.inspect(response)
        {:reply, response, state}
    end

    def handle_call({:editar_mensaje, receiver, mensaje_nuevo, id_mensaje}, _from, state) do
        #:rpc.call(local_name(@user_server), Usuario, :iniciar_chat, [state.userName, receiver])
        response = :rpc.call(local_name(@user_server), Usuario, :editar_mensaje, [state.userName, receiver, mensaje_nuevo, id_mensaje])
        {:reply, response, state}
    end

    def handle_call({:crear_chat_seguro, receiver, tiempo_limite}, _from, state) do
        :rpc.call(local_name(@user_server), Usuario, :iniciar_chat_seguro, [state.userName, receiver, tiempo_limite])
        {:reply, state, state}
    end

    def handle_call({:enviar_mensaje_seguro, receiver, mensaje_seguro}, _from, state) do
        :rpc.call(local_name(@user_server), Usuario, :enviar_mensaje_seguro, [state.userName, receiver, mensaje_seguro])
        {:reply, state, state}
    end



    def handle_info({destinatario, mensaje}, state) do
        IO.puts("["<>destinatario<>"]: "<>mensaje)
        {:noreply, state}
    end

    defp local_name(name) do
        {:ok, hostname} = :inet.gethostname()
        String.to_atom(name <> "@127.0.0.1")
        #String.to_atom(name <> "@#{hostname}")
    end

end
