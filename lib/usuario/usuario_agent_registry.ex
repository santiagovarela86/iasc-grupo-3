defmodule UsuarioAgentRegistry do

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

  def lookup(nombre) do
    List.first(Swarm.members(nombre))
  end

  def build_name(nombre) do
    #name = :crypto.hash(:md5, nombre <> to_string(DateTime.utc_now)) |> Base.encode16()
    #creo que el nombre tendria que ser simplemente el nombre del usuario
    {:via, :swarm, nombre}
  end
end
