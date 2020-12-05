defmodule Pigeon do
  use Application

  def start(_type, _args) do
        IO.puts("Soy el router")
        Router.start_link([])
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