defmodule Test do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def test() do
    UsuarioServer.crear("juan")
    UsuarioServer.crear("franco")
    _pidJuan = UsuarioServer.get("juan")
    _pidFranco = UsuarioServer.get("franco")
    _chat_name = Usuario.iniciar_chat("juan", "franco")
    Usuario.enviar_mensaje("juan", "franco", "holus")
    Usuario.enviar_mensaje("franco", "juan", "hola Juan, como va?")
    Usuario.obtener_chats("juan")
    Usuario.obtener_chats("franco")
    ChatUnoAUno.get_messages("juan", "franco")
    UsuarioServer.crear("juan")
    Usuario.crear_grupo("juan", "un_grupo")
    Usuario.enviar_mensaje_grupo("juan", "un_grupo", "hola")
  end

end
