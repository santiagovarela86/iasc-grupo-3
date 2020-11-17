defmodule ChatRepository do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  ################## OPERATIONS ##################

  def create_one_to_one_chat(server, chat_info) do
    GenServer.call server, {:create_one_to_one_chat, chat_info}
  end

  def get_one_to_one_chat(server, id_one_to_one_chat) do
    GenServer.call server, {:get_one_to_one_chat, id_one_to_one_chat}
  end

  ################## CALLBACKS ##################

  def init(:ok) do
    map = %{}
    { :ok, map }
  end

  def handle_call({:create_one_to_one_chat, chat_info}, _from, map) do
    # WE NEED TO CHANGE THIS SO AS TO GENERATE THE SAME CHAT ID FOR THE TWO SAME USERS REGARDLESS OF THE ORDER AND HOW MANY TIMES WE RUN THIS
    # SOMETHING LIKE SORTING THE NAMES ALPHABETICALLY, HASING THE STRINGS AND THEN CONCATENATING THEM
    # OR JUST CHECKING IN THE CHAT LIST IF WE ALREADY HAVE A CHAT FOR THE SAME TWO USERS
    id_one_to_one_chat = Integer.to_string :random.uniform(1000000)
    {:reply, id_one_to_one_chat, Map.put(map, id_one_to_one_chat, chat_info)}
  end

  def handle_call({:get_one_to_one_chat, id_one_to_one_chat}, _from, map) do
    {:reply, Map.get(map, id_one_to_one_chat), map}
  end

end
