defmodule ChatSeguroAgentRegistry do

  @secure_suffix "~~~~~~SECURE"

  def start_link(_) do
    Swarm.Registry.start_link()
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :transient
    }
  end

  def lookup(chat_id) do
    # List.first(Swarm.members(chat_id))
    List.first(Swarm.members({:chat_seguro, chat_id}))
  end

  def build_name(usuario1, usuario2) do
    #usuarios_en_orden = Enum.sort([usuario1, usuario2])
    usuarios_en_orden = Enum.sort([usuario1, usuario2, @secure_suffix])
    name = :crypto.hash(:md5, List.first(usuarios_en_orden) <> List.last(usuarios_en_orden) <> to_string(DateTime.utc_now)) |> Base.encode16()
    {:via, :swarm, name}
  end

end
