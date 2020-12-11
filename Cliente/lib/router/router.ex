defmodule Router do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: {:global, name})
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def child_spec(name) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name]},
      type: :worker,
      restart: :transient
    }
  end

  def route() do
    GenServer.call({:global, any_router()}, :route)
  end

  def route(nodo_origen) do
    GenServer.call({:global, any_router()}, {:route, nodo_origen})
  end

  def servers() do
    GenServer.call(any_router(), :servers)
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

  defp any_router do
    routers = Enum.map(router_names(), fn name -> {name, :global.whereis_name name} end)
    |> Enum.filter(fn {_, pid} -> pid != :undefined end)
    |> Enum.map(fn {name, _} -> name end)
    if Enum.empty?(routers) do
      raise "no me pude conectar"
    else
    Enum.at(routers, :rand.uniform(Enum.count(routers)) - 1)
    end
  end

  defp router_names do
    [
      :Router1,
      :Router2,
      :Router3
  ]
  end

end
