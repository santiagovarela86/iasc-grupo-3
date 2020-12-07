defmodule ChatUnoAUnoRegistry do

  def start_link(_) do
    Registry.start_link(keys: :unique, name: ChatUnoAUnoRegistry)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent
    }
  end

  def lookup(chat_name) do
    Registry.lookup(ChatUnoAUnoRegistry, chat_name)
  end

  def build(usuario1, usuario2) do
    {:via, Registry, {ChatUnoAUnoRegistry, MapSet.new([usuario1, usuario2])}}
  end

end
