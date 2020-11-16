defmodule UsuarioRegistry do

  def start_link(_) do
    Registry.start_link(keys: :unique, name: UsuarioRegistry)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end

  def lookup_user(username) do
    Registry.lookup(UsuarioRegistry, username)
  end

  def build_name(username) do
    {:via, Registry, {UsuarioRegistry, username}}
  end
end
