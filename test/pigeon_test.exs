defmodule PigeonTest do
  use ExUnit.Case
  doctest Pigeon


  # test "Test -> Crear, Editar y Eliminar mensajes" do
  #   {:ok, pidUsuario} = Usuario.start_link(:usuario1, [])
  #   chatCreado = Usuario.iniciar_chat(pidUsuario, :usuario2)

  #   respuestaChat = Usuario.enviar_mensaje(pidUsuario, :usuario2, "holaaa")
  #   assert respuestaChat == %{mensajes: [usuario1: "holaaa"], usuarios: [:usuario2 | :usuario1]}

  #   respuestaUpdate = Usuario.editar_mensaje(pidUsuario, :usuario2, "chau", 0)
  #   assert respuestaUpdate == %{mensajes: [usuario1: "chau"], usuarios: [:usuario2 | :usuario1]}

  #   Usuario.enviar_mensaje(pidUsuario, :usuario2, "perro")
  #   respuestaDelete = Usuario.eliminar_mensaje(:usuario1, :usuario2, "perror")
  #   assert respuestaDelete == %{mensajes: [usuario1: "perro"], usuarios: [:usuario2 | :usuario1]}
  # end


#   test "Test crear chats" do
#     UsuarioServer.register_user("juan")
#     UsuarioServer.register_user("franco")
#     pidJuan = UsuarioServer.get_user("juan")
#     pidFranco = UsuarioServer.get_user("franco")

#     chat_name = Usuario.iniciar_chat("juan", "franco")

#     Usuario.enviar_mensaje("juan", "franco", "holus")
#     Usuario.enviar_mensaje("franco", "juan", "hola Juan, como va?")

#     chats = Usuario.obtener_chats("juan")
#     assert chats == [{["franco", "juan"], "franco"}]

#     chats = Usuario.obtener_chats("franco")
#     assert chats == [{["franco", "juan"], "juan"}]

#     mensajes = ChatUnoAUno.get_messages("juan", "franco")

#   end


#   test "Test editar chats" do
#     UsuarioServer.register_user("fede")
#     UsuarioServer.register_user("guido")

#     pidFede = UsuarioServer.get_user("fede")
#     pidGuido = UsuarioServer.get_user("guido")

#     chat_name = Usuario.iniciar_chat("fede", "guido")

#     idChat = Usuario.enviar_mensaje("fede", "guido", "holus")
#     idChat2 = Usuario.enviar_mensaje("guido", "fede", "hola Fede, como va?")

#     respuestaUpdate = Usuario.editar_mensaje("fede", "guido" , "chau", idChat)

#     assert respuestaUpdate == %{mensajes: [{idChat, "fede", "chau"}, {idChat2, "guido", "hola Fede, como va?"}], usuarios: ["guido" , "fede"]}


#  end

  test "algooo" do
    LocalCluster.start()

    Application.ensure_all_started(:pigeon)

    ExUnit.start()

    [userServer] = LocalCluster.start_nodes("userServer",1)
    [nodeJuan] = LocalCluster.start_nodes("juan",1)
    [nodeFede] = LocalCluster.start_nodes("fede",1)


    assert Node.ping(nodeJuan) == :pong
    assert Node.ping(nodeFede) == :pong
    assert Node.ping(userServer) == :pong

    caller = self()

    #pid = Node.spawn(node1, fn -> Cliente.start_link("fede") end)
    #pid2 = Node.spawn(node2, fn -> Cliente.start_link("juan") end)
    
    #Node.spawn(node1, fn -> Cliente.registrar(pid) end)

    {:ok, pidJuan} = :rpc.call(nodeJuan, Cliente, :start_link, ["juan"])
    {:ok, pidFede} = :rpc.call(nodeFede, Cliente, :start_link, ["fede"])

    {:ok, _} = :rpc.call(nodeJuan, Cliente, :registrar, [pidJuan])
    {:ok, _} = :rpc.call(nodeFede, Cliente, :registrar, [pidFede])

    :rpc.call(nodeJuan, Cliente, :crear_chat, ["fede", pidJuan])
    
    {:ok, id_mensaje} = :rpc.call(nodeJuan, Cliente, :enviar_mensaje, ["fede", "holaaa", pidJuan])
    IO.puts(id_mensaje)
    #:rpc.call(nodeFede, Cliente, :enviar_mensaje, ["juan", "como estas?", pidFede])

  end  

end
