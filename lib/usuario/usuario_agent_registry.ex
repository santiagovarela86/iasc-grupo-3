defmodule UsuarioAgentRegistry do

  def start_link(_) do
    Registry.start_link(keys: :duplicate, name: UsuarioRegistry)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end

  def lookup(username) do
    Registry.lookup(UsuarioAgentRegistry, username)
  end

  def register(username) do
    Registry.register(UsuarioAgentRegistry, username, [])
  end
end
