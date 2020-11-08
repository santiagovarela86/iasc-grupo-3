defmodule Messenger do

  def create_one_to_one_chat(oneUser, anotherUser) do
    MessengerServer.create_one_to_one_chat({:global, GlobalMessenger}, oneUser, anotherUser)
  end

  def get_one_to_one_chat(id_one_to_one_chat) do
    MessengerServer.get_one_to_one_chat({:global, GlobalMessenger}, id_one_to_one_chat)
  end

end
