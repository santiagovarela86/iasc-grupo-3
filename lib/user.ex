defmodule User do

  def send_message(message, to) do
    {message, to}
  end

  def receive_message(message, from) do
    {message, from}
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
