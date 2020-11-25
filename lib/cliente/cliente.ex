defmodule Cliente do

    use GenServer

    @user_server "userServer"

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
        GenServer.call(pid,{:registrar})
    end

    def enviar_mensaje(receiver, mensaje, pid) do
        GenServer.call(pid,{:enviar_mensaje, receiver, mensaje})
    end

    def enviar_mensaje_seguro(receiver, mensaje, pid) do
        GenServer.call(pid,{:enviar_mensaje_seguro, receiver, mensaje})
    end

    def build_name(nombre) do
        name = :crypto.hash(:md5, nombre <> to_string(DateTime.utc_now)) |> Base.encode16()
        {:via, :swarm, name}
    end

######################################

    def handle_call({:registrar}, _from, state) do
        Node.connect(local_name(@user_server))
        :rpc.call(local_name(@user_server), UsuarioServer, :register_user, [state.userName])
        {:reply, state, state}
    end

    def handle_call({:enviar_mensaje, receiver, mensaje}, _from, state) do
        :rpc.call(local_name(@user_server), Usuario, :iniciar_chat, [state.userName, receiver])
        :rpc.call(local_name(@user_server), Usuario, :enviar_mensaje, [state.userName, receiver, mensaje])
        {:reply, state, state}
    end

    def handle_call({:enviar_mensaje_seguro, receiver, mensaje_seguro}, _from, state) do
        :rpc.call(local_name(@user_server), Usuario, :iniciar_chat_seguro, [state.userName, receiver])
        :rpc.call(local_name(@user_server), Usuario, :enviar_mensaje_seguro, [state.userName, receiver, mensaje_seguro])
        {:reply, state, state}
    end

    def handle_info(mensaje, state) do
        IO.puts(mensaje)
        {:noreply, state}
    end

    defp local_name(name) do
        {:ok, hostname} = :inet.gethostname()
        String.to_atom(name <> "@#{hostname}")
    end

    #def handle_info(_msg, state) do
    #    IO.puts(state)
    #    {:noreply, state}
    #end

end
