defmodule Pigeon do
  use Application

  def start(_type, _args) do
    type = System.get_env("type")

    case type do
      "router" ->
        IO.puts("Soy el router")
        Router.start_link([])

      "client" ->
        IO.puts("Soy un cliente")
        connect_to_cluster()
        {:ok, spawn(fn -> :ok end)}

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
    IO.puts("conectado")
  end

  def nodos_router() do
    [String.to_atom("router-1" <> "@localhost"), String.to_atom("router-2" <> "@localhost"), String.to_atom("router-3" <> "@localhost")]
  end
end
