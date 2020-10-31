defmodule HistorialAgent do
  use Agent

  def start_link(state) do
    Agent.start_link(state)
  end

  def get_historial(identificador) do
    # state = Agent.get(__MODULE__, & &1)
    # {_, mensajes} = state.find( {identificador, _}, [] )
    # mensajes
  end

  def registrar_mensaje(identificador, message) do
    # Agent.update(state ->
    # state.map (identificador, mensajes} ->
    # {identificador, mensajes ++ [{body, from, time, read, delete_time}]})
    # )
  end
end

# [
# {{:user_chat, [usuario1, usuario2]} ,[{message, from, time, read, delete_time}, ...]},
# {{:group_chat, grupo} ,[{message, from, time, read, delete_time}}]
# ]
