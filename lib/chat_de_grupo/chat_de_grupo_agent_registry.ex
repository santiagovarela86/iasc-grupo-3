defmodule ChatDeGrupoAgentRegistry do

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
    Swarm.members(chat_id)
  end

  def build_name(nombre_grupo) do
    name = :crypto.hash(:md5, nombre_grupo <> to_string(DateTime.utc_now)) |> Base.encode16()
    {:via, :swarm, name}
  end
end
