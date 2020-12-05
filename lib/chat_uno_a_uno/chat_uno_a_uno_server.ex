defmodule ChatUnoAUnoServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ChatUnoAUnoServer)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get(usuario1, usuario2) do
    GenServer.call(ChatUnoAUnoServer, {:get, usuario1, usuario2})
  end

  def crear(usuario1, usuario2) do
    IO.puts("CREANDO UN CHAT UNO A UNO")
    GenServer.call(ChatUnoAUnoServer, {:crear, usuario1, usuario2})
  end

  def handle_call({:get, usuario1, usuario2}, _from, state) do
    {:reply, get_private(usuario1, usuario2), state}
  end

  def handle_call({:crear, usuario1, usuario2}, _from, state) do
    case get_private(usuario1, usuario2) do
    {:ok, pid} -> {:reply, {:already_exists, pid}, state}
    {:not_found, _} ->
      {_, agente} = ChatUnoAUnoAgent.start_link(usuario1, usuario2)
      chat_id = MapSet.new([usuario1, usuario2])
      Swarm.join({:chat_uno_a_uno_agent, chat_id}, agente)
      ServerEntity.agregar_chat_uno_a_uno(chat_id)
      chatPid = ChatUnoAUnoSupervisor.start_child(chat_id)
      {:reply, {:ok, chatPid}, state}
    error -> {:reply, {:error, error}, state}
   end
  end

  defp get_private(usuario1, usuario2) do
    chat_id = MapSet.new([usuario1, usuario2])
    case ChatUnoAUnoRegistry.lookup(chat_id) do
      [{chatPid, _}] -> {:ok, chatPid}
      []->
        case Swarm.members({:chat_uno_a_uno_agent, chat_id}) do
          [] -> {:not_found, nil}
          _ ->
            {_, agente} = ChatUnoAUnoAgent.start_link(usuario1, usuario2)
            ServerEntity.copiar(agente, {:chat_uno_a_uno_agent, chat_id})
            Swarm.join({:chat_uno_a_uno_agent, chat_id}, agente)
            chatPid = ChatUnoAUnoSupervisor.start_child(chat_id)
            {:ok, chatPid}
        end
      error -> {:error, error}
    end
  end

end
