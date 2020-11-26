defmodule ChatSeguroServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ChatSeguroServer)
  end

  def init(args) do
    {:ok, args}
  end

  def get_chat(username1, username2) do
    GenServer.call(ChatSeguroServer, {:get_chat, build_secure_chat_name(username1, username2)})
  end

  def register_chat_seguro(username1, username2, tiempo_limite) do
    GenServer.call(ChatSeguroServer, {:register_chat_seguro, username1, username2, tiempo_limite})
  end

  def handle_call({:get_chat, secure_chat_name}, _from, state) do
    case ChatSeguroRegistry.lookup_chat(secure_chat_name) do
      [{chatPid, _}] -> {:reply, chatPid, state}
      _ -> {:reply, :not_found, state}
    end
  end

  def handle_call({:register_chat_seguro, username1, username2, tiempo_limite}, _from, state) do
    secure_chat_name = build_secure_chat_name(username1, username2)
    {:ok, agent} = ChatSeguroAgent.start_link(username1, username2, tiempo_limite)
    Swarm.join([username1, username2], agent)
    #tendria que usar un supervisor para crear al agent
    #tendria que usar un case, o el case ya hecho para cuando ya existe, o cuando no existe el grupo, etc?
    case ChatSeguroSupervisor.start_child(secure_chat_name) do
      {:ok, _} -> {:reply, secure_chat_name, state}
      {:error, {:already_started, _}} -> {:reply, secure_chat_name, state}
    end
  end

  def build_secure_chat_name(username1, username2) do
    Enum.sort([username1, username2])
  end

end
