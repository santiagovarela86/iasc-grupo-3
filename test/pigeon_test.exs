defmodule PigeonTest do
  use ExUnit.Case
  doctest Pigeon


  test "algo" do
    {:ok, pidUsuario} = Usuario.start_link(:usuario1, [])
    chatCreado = Usuario.iniciar_chat(pidUsuario, :usuario2)

    respuestaChat = Usuario.enviar_mensaje(pidUsuario, :usuario2, "holaaa")
    assert respuestaChat == %{mensajes: [usuario1: "holaaa"], usuarios: [:usuario2 | :usuario1]}
    
    respuestaUpdate = Usuario.editar_mensaje(pidUsuario, :usuario2, "chau", 0)
    assert respuestaUpdate == %{mensajes: [usuario1: "chau"], usuarios: [:usuario2 | :usuario1]}

    Usuario.enviar_mensaje(pidUsuario, :usuario2, "perro")
    respuestaDelete = Usuario.eliminar_mensaje(pidUsuario, :usuario2, 0)
    assert respuestaDelete == %{mensajes: [usuario1: "perro"], usuarios: [:usuario2 | :usuario1]}


  end

end


