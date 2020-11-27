defmodule ChatUnoAUnoServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ChatUnoAUnoServer)
  end

  def init(args) do
    {:ok, args}
  end

  def get_chat(username1, username2) do
    GenServer.call(ChatUnoAUnoServer, {:get_chat, build_chat_name(username1, username2)})
  end

  def register_chat(username1, username2) do
    GenServer.call(ChatUnoAUnoServer, {:register_chat, username1, username2})
  end

  def handle_call({:get_chat, chat_name}, _from, state) do
    case ChatUnoAUnoRegistry.lookup_chat(chat_name) do
      [{chatPid, _}] -> {:reply, chatPid, state}
      _ -> {:reply, :not_found, state}
    end
  end

  def handle_call({:register_chat, username1, username2}, _from, state) do
    chat_name = build_chat_name(username1, username2)
    {:ok, pidAgent} = ChatUnoAUnoAgent.start_link(username1, username2)
    Swarm.join({:chat_uno_a_uno_agent, chat_name}, pidAgent)
    #tendria que usar un supervisor para crear al agent
    #tendria que usar un case, o el case ya hecho para cuando ya existe, o cuando no existe el grupo, etc?
    case ChatUnoAUnoSupervisor.start_child(chat_name) do
      {:ok, pidUnoAUno} -> Swarm.join({:chat_uno_a_uno, chat_name}, pidUnoAUno)
      {:reply, chat_name, state}
      {:error, {:already_started, _}} -> {:reply, chat_name, state}
    end
  end

  def build_chat_name(username1, username2) do
    Enum.sort([username1, username2])
  end

end
