defmodule ChatDeGrupoRegistry do

  def start_link(_) do
    Registry.start_link(keys: :unique, name: ChatDeGrupoRegistry)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end

  def lookup(grupo_name) do
    Registry.lookup(ChatDeGrupoRegistry, grupo_name)
  end

  def build_name(grupo_name) do
    {:via, Registry, {ChatDeGrupoRegistry, grupo_name}}
  end

end
