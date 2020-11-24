defmodule Pigeon do
  use Application

  def start(_type, _args) do
    ##User.start_link(UnUser)
    ApplicationSupervisor.start_link(keys: :unique, name: Registry.Pigeon)
  end
end


# UsuarioServer.register_user("juan")
# UsuarioServer.register_user("franco")
# pidJuan = UsuarioServer.get_user("juan")
# pidFranco = UsuarioServer.get_user("franco")

# chat_name = Usuario.iniciar_chat("juan", "franco")

# Usuario.enviar_mensaje("juan", "franco", "holus")
# Usuario.enviar_mensaje("franco", "juan", "hola Juan, como va?")

# Usuario.obtener_chats("juan")
# Usuario.obtener_chats("franco")
# ChatUnoAUno.get_messages("juan", "franco")

# UsuarioServer.register_user("juan")
# Usuario.crear_grupo("juan", "un_grupo")
# Usuario.enviar_mensaje_grupo("juan", "un_grupo", "hola")
