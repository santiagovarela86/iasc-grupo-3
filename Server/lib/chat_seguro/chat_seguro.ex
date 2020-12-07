defmodule ChatSeguro do
  use GenServer
  import Crontab.CronExpression
  @every30seconds ~e[*/30]e
  #@every10seconds ~e[*/10]e
  #@every5seconds ~e[*/5]e
  #@everysecond ~e[*/1]e

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

    create_job(List.first(MapSet.to_list(chat_name)), List.last(MapSet.to_list(chat_name)))

    {:ok, state}
  end

  def child_spec(chat_name) do
    %{
      id: chat_name,
      start: {__MODULE__, :start_link, [chat_name]},
      type: :worker,
      restart: :permanent
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
    #IO.puts("DEBUG: Se llamó al borrado de mensajes expirados.")
    GenServer.cast(pid, {:eliminar_mensajes_expirados})
  end

  def handle_call({:enviar_mensaje, sender, mensaje}, _from, state) do
    ChatSeguroEntity.registrar_mensaje(state.chat_name, mensaje, sender)
    {:reply, state, state}
  end

  def handle_call({:get_messages}, _from, state) do
    mensajes = ChatSeguroEntity.get_mensajes(state.chat_name)
    {:reply, mensajes, state}
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
    eliminar_mensajes_expirados(state.chat_name)
    {:noreply, state}
  end

  defp get_chat_pid(username1, username2) do
    {_ok?, id} = ChatSeguroServer.get(username1, username2)
    id
  end

  def eliminar_mensajes_expirados(chat_id) do
    ChatSeguroEntity.get_mensajes(chat_id)
    |> elem(1)
    |> Map.to_list()
    |> Enum.filter(fn({_, {_, _, msg_date, _}}) -> DateTime.diff(DateTime.utc_now, msg_date, :second) > elem(ChatSeguroEntity.get_tiempo_limite(chat_id),1) end)
    |> Enum.each(fn({id, {_, _, _, _}}) -> ChatSeguroEntity.eliminar_mensaje(chat_id, id) end)
    #IO.puts("DEBUG: Se terminó de ejecutar el borrado de mensajes expirados.")
  end

  defp create_job(usuario1, usuario2) do
    ChatSeguroScheduler.new_job()
      |> Quantum.Job.set_schedule(@every30seconds)
      |> Quantum.Job.set_overlap(false)
      |> Quantum.Job.set_task({ChatSeguro, :eliminar_mensajes_expirados, [usuario1, usuario2]})
      |> ChatSeguroScheduler.add_job()

    #IO.puts("DEBUG: Se creo el job de eliminado de mensajes.")
  end
end
