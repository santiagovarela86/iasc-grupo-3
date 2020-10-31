defmodule Pigeon do
  use Application

  def start(_type, _args) do
    User.start_link(UnUser)
  end
end
