defmodule User do
  use GenServer

  def start_link(username, name) do
    GenServer.start_link(__MODULE__, username, name: name)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_cast({:receive_message, {message, from, _to}}, userNameTo) do
    IO.puts("Im #{userNameTo} and #{from} says: #{message}")
    {:noreply, userNameTo}
  end

  def handle_cast({:send_message, {message, to}}, usernameFrom) do
    MessageServer.send_message(message, usernameFrom, to)
    {:noreply, usernameFrom}
  end

  def send_message(message, pidFrom, to) do
    GenServer.cast(pidFrom, {:send_message, {message, to}})
  end

  def receive_message(message, from, pid) do
    GenServer.cast(pid, {:receive_message, {message, from, pid}})
  end

  def modify_message(message, new_message) do
    {message, new_message}
  end

  def delete_message(message) do
    {message}
  end

  def send_secure_message(message, duration, to) do
    {message, duration, to}
  end
end
