# Pigeon

## How to install the dependencies

- Run "mix deps.get" in the project root folder.

<br>

## How to run the tests

- Run "mix test" in the project root folder.

<br>

## How to test the application using nodes

- Go to the project root folder and open three different command lines there.

- First the routers: 
   - If you want to use a single router node without fallback:
      - type=router iex --sname router-1 -S mix (Linux)
      - $env:type = 'router'; iex.bat --werl --sname "router-1@localhost" -S mix (Windows)

   - If you want to use router with fallback nodes, you'll need to create 3 nodes
      - type=router iex --sname router-1@localhost --erl "-config config/router-1" -S mix
      - type=router iex --sname router-2@localhost --erl "-config config/router-2" -S mix
      - type=router iex --sname router-3@localhost --erl "-config config/router-3" -S mix

- Then the server nodes. Name then server-n where n is a different number each time
  - type=server iex --sname server-1 -S mix (Linux)
  - $env:type = 'server'; iex.bat --werl --sname server-1 -S mix (Windows)

- Then the clients: 
  - Usuario1
    - type=client iex --sname usuario1 -S mix (Linux)
    - $env:type = 'client'; iex.bat --sname usuario1 --werl -S mix (Windows)
    - {:ok, pid} = Cliente.start_link("usuario1")
    - Cliente.registrar(pid)

  - Usuario2
    - type=client iex --sname usuario2 -S mix (Linux)
    - $env:type = 'client'; iex.bat --sname usuario2 --werl -S mix (Windows)
    - {:ok, pid} = Cliente.start_link("usuario2")
    - Cliente.registrar(pid)

- You can create as many users/clients as you want.

- Then you can start sending messages to other users, for instance, from "usuario1":
    - Cliente.enviar_mensaje("usuario2", "message", pid)

- Or you can create a secure chat, specifying after which the message will be deleted, in this case, 60 seconds:
    - Cliente.crear_chat_seguro("usuario2", 60, pid)

- And then, send secure messages:
    - Cliente.enviar_mensaje_seguro("usuario2", "a secure message", pid)

- You can get all your secure chats:
    - {:ok, chat_seguros} = Cliente.obtener_chats_seguros(pid)

<br>

## DEPRECATED
## How to test the application without using nodes

- Run **iex -S mix** in the project folder
- Register a user with "UsuarioServer.register_user("juan")"
- Register another user with "UsuarioServer.register_user("franco")"
- Get Juan's PID with "pidJuan = UsuarioServer.get_user("juan")"
- Get Franco's PID with "pidFranco = UsuarioServer.get_user("franco")"
- Create a chat with "chat_name = Usuario.iniciar_chat("juan", "franco")"
- Create a secure chat with "secure_chat_name = Usuario.iniciar_chat_seguro("juan", "franco", 10)"
<br>(Time in which messages should be deleted automatically should be specified in seconds).
- Send a message with "Usuario.enviar_mensaje("juan", "franco", "holus")"
- Send a secure message with "Usuario.enviar_mensaje_seguro("juan", "franco", "holus seguro")"
- Get the user's chats with "Usuario.obtener_chats("juan")"
- Get the user's chat messages "ChatUnoAUno.get_messages("juan","franco")"
