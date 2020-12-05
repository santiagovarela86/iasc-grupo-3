defmodule ChatSeguroRegistry do

  def start_link(_) do
    Registry.start_link(keys: :unique, name: ChatSeguroRegistry)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end

  def lookup(chat_name) do
    Registry.lookup(ChatSeguroRegistry, chat_name)
  end

  def build_name(usuario1, usuario2) do
    {:via, Registry, {ChatSeguroRegistry, MapSet.new([usuario1, usuario2])}}
  end

end
