defmodule ChatUnoAUno do
  use GenServer

  def start_link(chat_name) do
    GenServer.start_link(__MODULE__, chat_name, name: {:via, Registry, {ChatUnoAUnoRegistry, chat_name}})
  end

  def init(chat_name) do
    state = %{chat_name: chat_name}
    [usuario1, usuario2] = MapSet.to_list(chat_name)
    {_, agente} = ChatUnoAUnoAgent.start_link(usuario1, usuario2)
    ServerEntity.agregar_chat_uno_a_uno(chat_name)
    ServerEntity.copiar(agente, {:chat_uno_a_uno_agent, chat_name})
    Swarm.join({:chat_uno_a_uno_agent, chat_name}, agente)
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

  def editar_mensaje(sender, reciever, mensaje_nuevo, id_mensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:editar_mensaje, sender, mensaje_nuevo, id_mensaje})
  end

  def eliminar_mensaje(sender, reciever, id_mensaje) do
    pid = get_chat_pid(sender, reciever)
    GenServer.call(pid, {:eliminar_mensaje, sender, id_mensaje})
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    ChatUnoAUnoEntity.registrar_mensaje(state.chat_name, mensaje, sender)
    {:reply, state, state}
  end


  def handle_call({:editar_mensaje, sender, mensaje_nuevo, id_mensaje}, _from, state) do
    ChatUnoAUnoEntity.modificar_mensaje(state.chat_name, sender , mensaje_nuevo, id_mensaje)
    {:reply, state, state}
  end


  def handle_call({:eliminar_mensaje, _sender, id_mensaje}, _from, state) do
    ChatUnoAUnoEntity.eliminar_mensaje(state.chat_name, id_mensaje)
    {:reply, state, state}
  end

  def handle_call({:get_messages}, _from, state) do
    mensajes = ChatUnoAUnoEntity.get_mensajes(state.chat_name)
    {:reply, mensajes, state}
  end

  defp get_chat_pid(username1, username2) do
    {_ok?, pid} = ChatUnoAUnoServer.get(username1, username2)
    pid
  end

end
