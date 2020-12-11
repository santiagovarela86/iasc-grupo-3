defmodule Pigeon do
  use Application

  def start(_type, _args) do
        IO.puts("Soy el router")

        ApplicationSupervisor.start_link(Router.name)
  end

  def connect_to_cluster() do
    if(!List.foldl(nodos_router(), false, fn value, acum -> acum || Node.connect(value) end)) do
      raise RuntimeError.exception("No me pude conectar al router")
    end
  end

  def nodos_router() do
    [String.to_atom("Router1" <> "@router1"), String.to_atom("Router2" <> "@router2"), String.to_atom("Router3" <> "@router3")]
  end
end
