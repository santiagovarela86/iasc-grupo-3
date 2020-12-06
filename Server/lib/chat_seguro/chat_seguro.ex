defmodule ChatSeguro do
  use GenServer

  def start_link(chat_name) do
    GenServer.start_link(__MODULE__, chat_name, name: {:via, Registry, {ChatSeguroRegistry, chat_name}})
  end

  def init(chat_name) do
    state = %{chat_name: chat_name}
    {:ok, state}
  end

  def child_spec(chat_name) do
    %{
      id: chat_name,
      start: {__MODULE__, :start_link, [chat_name]},
      type: :worker,
      restart: :transient
    }
  end

  def enviar_mensaje(sender, receiver, mensaje) do
    pid = get_chat_pid(sender, receiver)
    GenServer.call(pid, {:enviar_mensaje, sender, mensaje})
  end

  def get_messages(username1, username2) do
    pid = get_chat_pid(username1, username2)
    GenServer.call(pid, {:get_messages})
  end

  def editar_mensaje(sender, receiver, mensaje_nuevo, id_mensaje) do
    pid = get_chat_pid(sender, receiver)
    GenServer.call(pid, {:editar_mensaje, sender, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje(sender, receiver, id_mensaje) do
    pid = get_chat_pid(sender, receiver)
    GenServer.call(pid, {:eliminar_mensaje, id_mensaje})
  end

  def eliminar_mensajes_expirados(sender, receiver) do
    pid = get_chat_pid(sender, receiver)
    IO.puts("DEBUG: Se llamó al borrado de mensajes expirados.")
    GenServer.cast(pid, {:eliminar_mensajes_expirados})
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    ChatSeguroEntity.registrar_mensaje(state.chat_name, mensaje, sender)
    {:reply, state, state}
  end

  def handle_call({:editar_mensaje, sender, mensaje_nuevo, id_mensaje}, _from, state) do
    ChatSeguroEntity.modificar_mensaje(state.chat_name, sender , mensaje_nuevo, id_mensaje)
    {:reply, state, state}
  end

  def handle_call({:eliminar_mensaje, id_mensaje}, _from, state) do
    ChatSeguroEntity.eliminar_mensaje(state.chat_name, id_mensaje)
    {:reply, state, state}
  end

  def handle_cast({:eliminar_mensajes_expirados}, state) do
    ChatSeguroEntity.eliminar_mensajes_expirados(state.chat_name)
    {:noreply, state}
  end

  def handle_call({:get_messages}, _from, state) do
    mensajes = ChatSeguroEntity.get_mensajes(state.chat_name)
    {:reply, mensajes, state}
  end

  defp get_chat_pid(username1, username2) do
    {_ok?, id} = ChatSeguroServer.get(username1, username2)
    id
  end

end
