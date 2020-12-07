defmodule Pigeon do
  use Application

  def start(_type, _args) do
    IO.puts("Soy un server")
    connect_to_cluster()
    init = ApplicationSupervisor.start_link(keys: :unique, name: Registry.Pigeon)
    ServerAgentSupervisor.start_server_agent()
    ServerEntity.copiar_faltantes()
    init
  end

  def connect_to_cluster() do
    if(!List.foldl(nodos_router(), false, fn value, acum -> acum || Node.connect(value) end)) do
      raise RuntimeError.exception("No me pude conectar al router")
    end
    IO.puts("conectado")
  end

  def nodos_router() do
    [String.to_atom("router" <> "@router1"), String.to_atom("router" <> "@router2"), String.to_atom("router" <> "@router3")]
  end
end
