defmodule ChatDeGrupo do
  use GenServer

  def start_link(mensajes, usuarios, administradores, name) do
    GenServer.start_link(__MODULE__, {mensajes, usuarios, administradores}, name: ChatRegistry.build_name(name))
  end

  def init({mensajes, usuarios, administradores}) do
    state = %{
      mensajes: mensajes,
      usuarios: usuarios,
      administradores: administradores
    }

    {:ok, state}
  end

  def child_spec({mensajes, users, chat_name}) do
    %{
      id: chat_name,
      start: {__MODULE__, :start_link, [mensajes, users, chat_name]},
      type: :worker,
      restart: :transient
    }
  end

  def enviar_mensaje(sender, reciever, mensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:enviar_mensaje, sender, mensaje})
  end

  def get_messages(username1, username2) do
    pid = get_chat_pid(username1, username2)
    GenServer.call(pid, {:get_messages})
  end

  def editar_mensaje(sender, reciever, mensajeNuevo, mensajeViejo) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:editar_mensaje, sender, reciever, mensajeNuevo, mensajeViejo})
  end

  def eliminar_mensaje(sender, reciever, idMensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:eliminar_mensaje, idMensaje })
  end


  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    # (existing_value :: value ->    updated_value :: value))
    newState = Map.update!(state, :mensajes, fn mensajes -> mensajes ++ [{sender, mensaje}] end)
    {:reply, newState, newState}
  end

  def handle_call({:editar_mensaje, _, _, _, _}, _from, state) do
    IO.inspect(state)
    newState = Map.update!(state, :mensajes, fn (mensajes) ->  List.delete_at(mensajes, 0)  end)
    IO.inspect(newState)
    {:reply, newState, newState}
  end


  def handle_call({:eliminar_mensaje, _, _}, _from, state) do
    newState = Map.update!(state, :mensajes, fn mensajes ->  List.delete_at(mensajes, 0)  end)
    {:reply, newState, newState}
  end

  def handle_call({:get_messages}, _from, state) do
    {:reply, state.mensajes, state}
  end

  def getHash(mensaje) do
    :crypto.hash(:md5, mensaje <> to_string(DateTime.utc_now)) |> Base.encode16()
  end

  defp get_chat_pid(username1, username2) do
    ChatServer.get_chat(username1, username2)
  end
end
