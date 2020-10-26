defmodule Pigeon do
  use Application

  def start(_type, _args) do
    User.start_link("username1", User1)
    User.start_link("username2", User2)
    User.start_link("username3", User3)
    MessageServer.start_link()

  end

end
