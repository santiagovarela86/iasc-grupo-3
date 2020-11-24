defmodule Chat do
  use GenServer

  def start_link(chat_name) do
    GenServer.start_link(__MODULE__, chat_name, name: {:via, Registry, {ChatRegistry, chat_name}})
  end

  def init(chat_name) do
    state = chat_name
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

  def enviar_mensaje(sender, reciever, mensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:enviar_mensaje, sender, mensaje})
  end

  def get_messages(username1, username2) do
    pid = get_chat_pid(username1, username2)
    GenServer.call(pid, {:get_messages})
  end

  def editar_mensaje(idChatDestino, mensajeNuevo, idMensaje ,idOrigen) do
    GenServer.call(idChatDestino, {:editar_mensaje, mensajeNuevo, idMensaje, idOrigen})
  end

  def eliminar_mensaje(idChatDestino, idMensaje ,idOrigen) do
    GenServer.call(idChatDestino, {:eliminar_mensaje, idMensaje, idOrigen})
  end


  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    my_agent = ChatUnoAUnoAgentRegistry.lookup(state)
    ChatUnoAUnoAgent.registrar_mensaje(my_agent, mensaje, sender)
    {:reply, state, state}
  end


  def handle_call({:editar_mensaje, mensajeNuevo, idMensaje, idOrigen}, _from, state) do
    my_agent = ChatUnoAUnoAgentRegistry.lookup(state)
    ChatUnoAUnoAgent.modificar_mensaje(my_agent, idOrigen , mensajeNuevo, idMensaje)
    {:reply, state, state}
  end


  def handle_call({:eliminar_mensaje, idMensaje, _idOrigen}, _from, state) do
    my_agent = ChatUnoAUnoAgentRegistry.lookup(state)
    ChatUnoAUnoAgent.eliminar_mensaje(my_agent,idMensaje)
    {:reply, state, state}
  end

  def handle_call({:get_messages}, _from, state) do
    my_agent = ChatUnoAUnoAgentRegistry.lookup(state)
    mensajes = ChatUnoAUnoAgent.get_mensajes(my_agent)
    {:reply, mensajes, state}
  end

  defp get_chat_pid(username1, username2) do
    ChatServer.get_chat(username1, username2)
  end
end
