defmodule UsuarioServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: UsuarioServer)
  end

  def init(args) do
    {:ok, args}
  end

  def get_user(username) do
    GenServer.call(UsuarioServer, {:get_user, username})
  end

  def register_user(username) do
    GenServer.call(UsuarioServer, {:register_user, username})
  end

  def handle_call({:get_user, username}, _from, state) do
    IO.puts("buscar a " <> username)
    lookup = UsuarioRegistry.lookup_user(username)
    IO.inspect(lookup)
    result = case lookup do
      [{userPid, _}] -> {:reply, userPid, state}
      _ -> {:reply, :not_found, state}
    end
    IO.inspect(result)
    result
  end

  def handle_call({:register_user, username}, _from, state) do
    case UsuarioSupervisor.start_child(username) do
      {:ok, pid} -> {:reply, pid, state}
      {:error, {:already_started, pid}} -> {:reply, pid, state}
    end
  end
end
