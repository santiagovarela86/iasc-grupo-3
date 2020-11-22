defmodule Cliente2.Interact do


    @user_server :userServer@iaschost

    def registrar(userName) do

        pid = spawn(Cliente.Interact , :listen, [])
        Process.register pid, String.to_atom(userName)
        new_user(userName)
        
    end


    def enviar_mensaje(sender, receiver, mensaje) do
        Node.connect(@user_server)
        :rpc.call(@user_server, Usuario, :iniciar_chat, [sender, receiver])
        :rpc.call(@user_server, Usuario, :enviar_mensaje, [sender ,receiver, mensaje])
    end    

    defp new_user(userName) do
        Node.connect(@user_server)
        :rpc.call(@user_server, UsuarioServer, :register_user, [userName])
    end    
 
    def listen do
        IO.puts("listening.. ")
        receive do
            mensaje ->
                IO.puts " #{mensaje} "
        end        
        listen
    end    

end
