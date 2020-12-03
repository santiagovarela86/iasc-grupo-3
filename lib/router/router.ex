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

  def route(nodo_origen) do
    GenServer.call({:global, __MODULE__}, {:route, nodo_origen})
  end

  def servers() do
    GenServer.call({:global, __MODULE__}, :servers)
  end

  def handle_call(:route, _from, state) do
    nodo = Enum.at(get_servers(), :rand.uniform(Enum.count(get_servers())) - 1)
    IO.inspect("routeo a #{nodo}")
    {:reply, nodo, state}
  end

  def handle_call({:route, nodo_origen}, _from, state) do
    servers = Enum.filter(get_servers(), fn elem -> elem != nodo_origen end)
    nodo = Enum.at(servers, :rand.uniform(Enum.count(servers)) - 1)
    IO.inspect("routeo a #{nodo}")
    {:reply, nodo, state}
  end

  def handle_call(:servers, _from, state) do
    {:reply, get_servers(), state}
  end

  def get_servers do
    Enum.filter(Node.list(), fn nodo ->
      String.contains?(String.downcase(Atom.to_string(nodo)), "server")
    end)
  end
end
