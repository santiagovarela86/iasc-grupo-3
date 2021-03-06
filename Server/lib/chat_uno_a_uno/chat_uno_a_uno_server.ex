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
    #IO.puts("CREANDO UN CHAT UNO A UNO")
    GenServer.call(ChatUnoAUnoServer, {:crear, usuario1, usuario2})
  end
  def handle_call({:get, usuario1, usuario2}, _from, state) do
    {:reply, get_private(usuario1, usuario2), state}
  end

  def handle_call({:crear, usuario1, usuario2}, _from, state) do
    case get_private(usuario1, usuario2) do
    {:ok, pid} -> {:reply, {:already_exists, pid}, state}
    {:not_found, _} ->
      chat_id = MapSet.new([usuario1, usuario2])
      {:ok, chatPid} = ChatUnoAUnoSupervisor.start_child(chat_id)
      Task.start(fn () -> GenServer.multi_call(Router.servers(Node.self), ChatUnoAUnoServer, {:crear, usuario1, usuario2}) end)
      {:reply, {:ok, chatPid}, state}
   end
  end

  defp get_private(usuario1, usuario2) do
    chat_id = MapSet.new([usuario1, usuario2])
    case Swarm.whereis_name({:chat_uno_a_uno, Node.self(), chat_id}) do
      :undefined->
        case Swarm.members({:chat_uno_a_uno_agent, chat_id}) do
          [] -> {:not_found, nil}
          _ ->
            {:ok, chatPid} = ChatUnoAUnoSupervisor.start_child(chat_id)
            {:ok, chatPid}
        end
      pid -> {:ok, pid}
    end
  end
end
