defmodule ChatSeguroServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ChatSeguroServer)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get(usuario1, usuario2) do
    GenServer.call(ChatSeguroServer, {:get, usuario1, usuario2})
  end

  def crear(usuario1, usuario2, tiempo_limite) do
    IO.puts("CREANDO UN CHAT SEGURO")
    GenServer.call(ChatSeguroServer, {:crear, usuario1, usuario2, tiempo_limite})
  end

  def handle_call({:get, usuario1, usuario2}, _from, state) do
    {:reply, get_private(usuario1, usuario2), state}
  end

  def handle_call({:crear, usuario1, usuario2, tiempo_limite}, _from, state) do
    case get_private(usuario1, usuario2) do
    {:ok, pid} -> {:reply, {:already_exists, pid}, state}
    {:not_found, nil} ->
      {_, agente} = ChatSeguroAgent.start_link(usuario1, usuario2, tiempo_limite)
      chat_id = MapSet.new([usuario1, usuario2])
      Swarm.join({:chat_seguro_agent, chat_id}, agente)
      ServerEntity.agregar_chat_seguro(chat_id)
      chatPid = ChatSeguroSupervisor.start_child(chat_id)
      {:reply, {:ok, chatPid}, state}
    error -> {:reply, {:error, error}, state}
   end
  end

  defp get_private(usuario1, usuario2) do
    chat_id = MapSet.new([usuario1, usuario2])
    case ChatSeguroRegistry.lookup(chat_id) do
      [{chatPid, _}] -> {:ok, chatPid}
      []-> {
        case Swarm.members({:chat_seguro_agent, chat_id}) do
          [] -> {:not_found, nil}
          _ ->
            {_, agente} = ChatSeguroAgent.start_link(usuario1, usuario2, 0)
            ServerEntity.copiar(agente, {:chat_seguro_agent, chat_id})
            Swarm.join({:chat_seguro_agent, chat_id}, agente)
            chatPid = ChatSeguroSupervisor.start_child(chat_id)
            {:ok, chatPid}
        end
      }
      error -> {:error, error}
    end
  end
end
