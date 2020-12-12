defmodule Pigeon do
  use Application

  def start(_type, _args) do
    IO.puts("Soy un server")
    connect_to_cluster()
    ApplicationSupervisor.start_link(keys: :unique, name: Registry.Pigeon)

  end

  def connect_to_cluster() do
    Enum.map(Pigeon.nodos_router, fn(nodo) -> Node.connect(nodo) end)
  end

  def nodos_router() do
    [String.to_atom("Router1" <> "@router1"), String.to_atom("Router2" <> "@router2"), String.to_atom("Router3" <> "@router3")]
  end
end
