defmodule Cliente do

    use GenServer

    @user_server :userServer@iaschost

    def start_link(userName) do
        {:ok, pid} = GenServer.start_link(__MODULE__, userName, name: __MODULE__)
    end    

    def init(name) do
        state = %{
          userName: name,
          pid: nil
        }
        {:ok, state}
    end

    def registrar() do
        GenServer.call(__MODULE__,{:registrar, pid})
    end

    def enviar_mensaje(receiver, mensaje) do 
        GenServer.call(__MODULE__,{:enviar_mensaje, receiver, mensaje})
    end    


######################################


    def handle_call({:registrar, pid}, _from, state) do
        Node.connect(@user_server)
        :rpc.call(@user_server, UsuarioServer, :register_user, [state.userName, pid])

        {:reply, state, state}
    end    

    def handle_call({:enviar_mensaje, receiver, mensaje}, _from, state) do
        :rpc.call(@user_server, Usuario, :iniciar_chat, [state.userName, receiver])
        :rpc.call(@user_server, Usuario, :enviar_mensaje, [state.userName, receiver, mensaje])
        {:reply, state, state}
    end   

    def handle_info(mensaje, state) do
        IO.puts("BBBBBBBBBBBBBBBBBBBBBBBBBB")
        IO.puts("CCCCCCCCCCCCCCCCCCCCCCCCC"<>state)

        {:reply, state, state}
    end   

    def handle_info(_msg, state) do
        IO.puts("ZZZZZZZZZZZZZZ")
        {:reply, state, state}
    end   


  end
  