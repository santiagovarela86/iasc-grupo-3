defmodule MessengerServer do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  ################## OPERATIONS ##################

  def create_one_to_one_chat(server, oneUser, anotherUser) do
    GenServer.call server, {:create_one_to_one_chat, oneUser, anotherUser}
  end

  def get_one_to_one_chat(server, id_one_to_one_chat) do
    GenServer.call server,{:get_one_to_one_chat, id_one_to_one_chat}
  end

  ################## CALLBACKS ##################

  def init(:ok) do
    {:ok, chatRepository} = ChatRepository.start_link
    {:ok, {chatRepository}}
  end

  def handle_call({:create_one_to_one_chat, oneUser, anotherUser}, _from, {chatRepository}) do
    one_to_one_chat_info = %{
      oneUser: oneUser,
      anotherUser: anotherUser
    }
    id_one_to_one_chat = ChatRepository.create_one_to_one_chat(chatRepository, one_to_one_chat_info)
    {:reply, id_one_to_one_chat, {chatRepository}}
  end

  def handle_call({:get_one_to_one_chat, id_one_to_one_chat}, _from, {chatRepository}) do
    {:reply, ChatRepository.get_one_to_one_chat(chatRepository, id_one_to_one_chat)}
  end

end
