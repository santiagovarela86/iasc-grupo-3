defmodule MessageServer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_cast({:send, {message, from, to}}, _) do
    # pid_user_list = get_users(to)
    # Enum.Map(pid_user_list, fn
    # user.receive_message(message, from)

    users = getUsersToSend(from, to)
    Enum.each(users, fn {_u, pid} -> User.receive_message(message, from, pid) end)

    {:noreply, []}
  end

  def send_message(message, from, to) do
    GenServer.cast(MessageServer, {:send, {message, from, to}})
  end

  def getUsersToSend(from, to) do
    users = UserFinder.findPidFromUsername(to)

    Enum.filter(users, fn {u, _pid} ->
      u != from
    end)
  end

  # def add_user(user, id) do

  # end

  # def add_group(group) do

  # end

  # def get_user_id(user) do
  #   :id
  # end
end
