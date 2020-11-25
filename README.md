# Pigeon

## How to test it

- Run **iex -S mix** in the project folder
- Register a user with "UsuarioServer.register_user('juan')"
- Get the user's PID with "pidJuan = UsuarioServer.get_user('juan')"
- Create a chat with "chat_name = Usuario.iniciar_chat('juan', 'franco')"
- Send a message with "Usuario.enviar_mensaje('juan', 'franco', 'holus')"
- Get the user's chats with "Usuario.obtener_chats('juan')"
- Get the user's chat messages "ChatUnoAUno.get_messages('juan','franco')"

## Con Nodos

- iex --sname userServer -S mix
- iex --sname juan -S mix 
- iex --sname pepe -S mix
- en cada nodo de los clientes ejecutar: 
    - {:ok, pid} = Cliente.start_link({nombre_del_usuario})
    - Cliente.registrar(pid)
- Cliente.enviar_mensaje({UserName Destino}, " { mensaje }" , pid)
