defmodule ChatUnoAUnoAgentRegistry do

  def start_link(_) do
    Swarm.Registry.start_link()
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :transient
    }
  end

  def lookup(chat_id) do
    Registry.lookup(ChatUnoAUnoAgentRegistry, chat_id)
  end

  def register(chat_id) do
    Swarm.Registry.register(chat_id, [])
  end

  def build_name(usuario1, usuario2) do
    name = :crypto.hash(:md5, usuario1 <> usuario2 <> to_string(DateTime.utc_now)) |> Base.encode16()
    {:via, :swarm, name}
  end
end