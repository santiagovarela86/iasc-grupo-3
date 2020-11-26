defmodule Test do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def test() do
    UsuarioServer.register_user("juan")
    UsuarioServer.register_user("franco")
    _pidJuan = UsuarioServer.get_user("juan")
    _pidFranco = UsuarioServer.get_user("franco")
    _chat_name = Usuario.iniciar_chat("juan", "franco")
    Usuario.enviar_mensaje("juan", "franco", "holus")
    Usuario.enviar_mensaje("franco", "juan", "hola Juan, como va?")
    Usuario.obtener_chats("juan")
    Usuario.obtener_chats("franco")
    ChatUnoAUno.get_messages("juan", "franco")
    UsuarioServer.register_user("juan")
    Usuario.crear_grupo("juan", "un_grupo")
    Usuario.enviar_mensaje_grupo("juan", "un_grupo", "hola")
  end

end
