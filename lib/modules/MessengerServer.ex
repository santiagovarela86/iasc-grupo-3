defmodule MessengerServer do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  def create_one_to_one_chat(server, oneUser, anotherUser) do
    GenServer.call server, {:create_one_to_one_chat, oneUser, anotherUser}
  end

  ################## CALLBACKS ##################

  def handle_call({:create_one_to_one_chat, oneUser, anotherUser}, _from, state) do
    # do something like this...
    # id_chat = ChatRepository.create(oneUser, anotherUser) ### if the chat already exists... should we return the already existing id or should we crash?
    # {:reply, id_chat, state}
  end

end
