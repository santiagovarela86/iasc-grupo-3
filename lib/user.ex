defmodule User do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def handle_call(:receive_message, _from, state) do
    IO.puts "I received a message"
    {:reply, state, state}
  end

  def send_message(message, to) do
    {message, to}
  end

  def receive_message(message, from, pid) do
    # {message, from}
    {_ , actual_pid} = pid
    GenServer.call(actual_pid, {:receive_message})
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
