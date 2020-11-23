defmodule ChatUnoAUnoAgentRegistry do

  def start_link(_) do
    Registry.start_link(keys: :duplicate, name: ChatUnoAUnoAgentRegistry)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end

  def lookup(chat_id) do
    Registry.lookup(ChatUnoAUnoAgentRegistry, chat_id)
  end

  def register(chat_id) do
    Registry.register(ChatUnoAUnoAgentRegistry, chat_id, [])
  end
end
