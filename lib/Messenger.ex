defmodule Messenger do

  def create_one_to_one_chat(oneUser, anotherUser) do
    MessengerServer.create_one_to_one_chat({:global, GlobalMessenger}, oneUser, anotherUser)
  end

end
