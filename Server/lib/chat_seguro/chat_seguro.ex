defmodule ChatSeguro do
  use GenServer

  def start_link([chat_name, tiempo_limite]) do
    GenServer.start_link(__MODULE__, [chat_name, tiempo_limite],
      name: {:via, Registry, {ChatSeguroRegistry, chat_name}}
    )
  end

  def init([chat_name, tiempo_limite]) do
    state = %{chat_name: chat_name}
    [usuario1, usuario2] = MapSet.to_list(chat_name)
    {_, agente} = ChatSeguroAgent.start_link(usuario1, usuario2, tiempo_limite)
    ServerEntity.agregar_chat_seguro(chat_name)
    ServerEntity.copiar(agente, {:chat_seguro_agent, chat_name})
    Swarm.join({:chat_seguro_agent, chat_name}, agente)
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

  def editar_mensaje(idChatDestino, mensajeNuevo, idMensaje, idOrigen) do
    GenServer.call(idChatDestino, {:editar_mensaje, mensajeNuevo, idMensaje, idOrigen})
  end

  def eliminar_mensaje(idChatDestino, idMensaje, idOrigen) do
    GenServer.call(idChatDestino, {:eliminar_mensaje, idMensaje, idOrigen})
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    ChatSeguroEntity.registrar_mensaje(state.chat_name, mensaje, sender)
    {:reply, state, state}
  end

  def handle_call({:editar_mensaje, mensajeNuevo, idMensaje, idOrigen}, _from, state) do
    ChatSeguroEntity.modificar_mensaje(state.chat_name, idOrigen, mensajeNuevo, idMensaje)
    {:reply, state, state}
  end

  def handle_call({:eliminar_mensaje, idMensaje, _idOrigen}, _from, state) do
    ChatSeguroEntity.eliminar_mensaje(state.chat_name, idMensaje)
    {:reply, state, state}
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
