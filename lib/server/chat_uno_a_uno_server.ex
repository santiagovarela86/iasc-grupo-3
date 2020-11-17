defmodule ChatServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ChatServer)
  end

  def init(args) do
    {:ok, args}
  end

  def get_chat(username1, username2) do
    GenServer.call(ChatServer, {:get_chat, build_chat_name(username1, username2)})
  end

  def register_chat(username1, username2) do
    GenServer.call(ChatServer, {:register_chat, username1, username2})
  end

  def handle_call({:get_chat, chat_name}, _from, state) do
    case ChatRegistry.lookup_chat(chat_name) do
      [{chatPid, _}] -> {:reply, chatPid, state}
      _ -> {:reply, :not_found, state}
    end
  end

  def handle_call({:register_chat, username1, username2}, _from, state) do
    chat_name = build_chat_name(username1, username2)
    case ChatSupervisor.start_child(chat_name, [username1, username2]) do
      {:ok, _} -> {:reply, chat_name, state}
      {:error, {:already_started, _}} -> {:reply, chat_name, state}
    end
  end

  def build_chat_name(username1, username2) do
    Enum.sort([username1, username2])
  end

end
