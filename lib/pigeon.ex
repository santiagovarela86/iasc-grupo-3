defmodule Pigeon do
  use Application

  def start(_type, _args) do
    type = System.get_env("type")

    case type do
      "router" ->
        IO.puts("Soy un router")
        Router.start_link([])

      "client" ->
        IO.puts("Soy un cliente")
        connect_to_cluster()
        name = System.get_env("name")
        {:ok, pid} = Cliente.start_link(name)
        Cliente.registrar(pid)
        {:ok, pid}

      "server" ->
        IO.puts("Soy un server")
        connect_to_cluster()
        ApplicationSupervisor.start_link(keys: :unique, name: Registry.Pigeon)
    end
  end

  def connect_to_cluster() do
    if(!List.foldl(nodos_router(), false, fn value, acum -> acum || Node.connect(value) end)) do
      raise RuntimeError.exception("No me pude conectar al router")
    end
  end

  def nodos_router() do
    {:ok, hostname} = :inet.gethostname()
    [String.to_atom("router" <> "@#{hostname}")]
  end
end
