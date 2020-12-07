defmodule Router do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def route() do
    GenServer.call({:global, __MODULE__}, :route)
  end

  def servers() do
    GenServer.call({:global, __MODULE__}, :servers)
  end

  def servers(nodo) do
    GenServer.call({:global, __MODULE__}, {:servers, nodo})
  end

  def handle_call(:route, _from, state) do
    nodo = Enum.at(get_servers(), :rand.uniform(Enum.count(get_servers())) - 1)
    IO.inspect("routeo a #{nodo}")
    {:reply, nodo, state}
  end

  def handle_call(:servers, _from, state) do
    {:reply, get_servers(), state}
  end

  def handle_call({:servers, nodo}, _from, state) do
    {:reply, get_servers(nodo), state}
  end

  def get_servers do
    Enum.filter(Node.list(), fn nodo ->
      String.contains?(String.downcase(Atom.to_string(nodo)), "server")
    end)
  end

  def get_servers(nodo_excluido) do
      Enum.filter(get_servers(), fn node -> node != nodo_excluido end)
  end
end
