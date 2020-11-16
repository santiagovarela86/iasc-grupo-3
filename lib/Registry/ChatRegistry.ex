defmodule ChatRegistry do

  def start_link(_) do
    Registry.start_link(keys: :unique, name: ChatRegistry)
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
    Registry.lookup(ChatRegistry, chat_name)
  end

  def build_name(chat_name) do
    {:via, Registry, {ChatRegistry, chat_name}}
  end
end
