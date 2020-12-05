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

  def lookup(username) do
    Registry.lookup(UsuarioRegistry, username)
  end

  def registered_users() do
    Registry.select(UsuarioRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def build_name(username) do
    {:via, Registry, {UsuarioRegistry, username}}
  end
end
