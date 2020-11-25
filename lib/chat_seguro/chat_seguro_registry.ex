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

  def lookup_chat(chat_name) do
    Registry.lookup(ChatSeguroRegistry, chat_name)
  end

  def build_name(chat_name) do
    {:via, Registry, {ChatSeguroRegistry, chat_name}}
  end
end
