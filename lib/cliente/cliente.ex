defmodule Cliente do

    use GenServer

    @user_server :userServer@iaschost

    def start_link(userName) do
        {:ok, pid} = GenServer.start_link(__MODULE__, userName, name: build_name(userName))
    end    

    def init(userName) do
        state = %{
          userName: userName,
          pid: nil
        }
        Swarm.join(userName, self)
        {:ok, state}
    end

    def registrar(pid) do
        GenServer.call(pid,{:registrar})
    end

    def enviar_mensaje(receiver, mensaje, pid) do 
        GenServer.call(pid,{:enviar_mensaje, receiver, mensaje})
    end    


    def build_name(nombre) do
        name = :crypto.hash(:md5, nombre <> to_string(DateTime.utc_now)) |> Base.encode16()
        {:via, :swarm, name}
      end


######################################


    def handle_call({:registrar}, _from, state) do
        Node.connect(@user_server)
        :rpc.call(@user_server, UsuarioServer, :register_user, [state.userName])

        {:reply, state, state}
    end    

    def handle_call({:enviar_mensaje, receiver, mensaje}, _from, state) do
        :rpc.call(@user_server, Usuario, :iniciar_chat, [state.userName, receiver])
        :rpc.call(@user_server, Usuario, :enviar_mensaje, [state.userName, receiver, mensaje])
        {:reply, state, state}
    end   

    def handle_info(mensaje, state) do
        IO.puts(mensaje)
        {:noreply, state}
    end   

    def handle_info(_msg, state) do
        IO.puts(state)
        {:noreply, state}
    end   


  end
  