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


  test "Test crear chats" do
    UsuarioServer.crear("juan")
    UsuarioServer.crear("franco")
    {_ok?, pidJuan} = UsuarioServer.get("juan")
    {_ok?, pidFranco} = UsuarioServer.get("franco")

    chat_name = Usuario.iniciar_chat("juan", "franco")

    Usuario.enviar_mensaje("juan", "franco", "holus")
    Usuario.enviar_mensaje("franco", "juan", "hola Juan, como va?")

    chats = Usuario.obtener_chats("juan")
    assert chats == [{["franco", "juan"], "franco"}]

    chats = Usuario.obtener_chats("franco")
    assert chats == [{["franco", "juan"], "juan"}]

    mensajes = ChatUnoAUno.get_messages("juan", "franco")

  end


  test "Test editar chats" do
    UsuarioServer.crear("fede")
    UsuarioServer.crear("guido")

    {_ok?, pidFede} = UsuarioServer.get("fede")
    {_ok?, pidGuido} = UsuarioServer.get("guido")

    chat_name = Usuario.iniciar_chat("fede", "guido")

    idChat = Usuario.enviar_mensaje("fede", "guido", "holus")
    idChat2 = Usuario.enviar_mensaje("guido", "fede", "hola Fede, como va?")

    respuestaUpdate = Usuario.editar_mensaje("fede", "guido" , "chau", idChat)

    assert respuestaUpdate == %{mensajes: [{idChat, "fede", "chau"}, {idChat2, "guido", "hola Fede, como va?"}], usuarios: ["guido" , "fede"]}


 end


end
