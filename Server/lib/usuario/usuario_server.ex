defmodule UsuarioServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: UsuarioServer)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get(nombre) do
    GenServer.call(UsuarioServer, {:get, nombre})
  end

  def crear(nombre) do
    IO.puts("CREANDO UN USUARIO")
	
    IO.puts("DEBUG C2: ")
	IO.puts(inspect(nombre))

	IO.puts("DEBUG C3: ")
	IO.puts(inspect(Router.servers()))

    GenServer.multi_call(Router.servers(), UsuarioServer, {:crear, nombre})
  end

  def handle_call({:get, nombre}, _from, state) do
    {:reply, get_private(nombre), state}
  end

  def handle_call({:crear, nombre}, _from, state) do
   case get_private(nombre) do
    {:ok, pid} -> 
	  IO.puts("DEBUG C3: ")
	  IO.puts(inspect(pid))
	  {:reply, {:already_exists, pid}, state}
    {:not_found, nil} ->
	  IO.puts("DEBUG C4: ")
      {_, agente} = UsuarioAgent.start_link(nombre)
	  IO.puts(inspect(agente))
	  IO.puts("DEBUG C5: ")
      Swarm.join({:usuario_agent, nombre}, agente)
	  IO.puts("DEBUG C6: ")
      ServerEntity.agregar_usuario(nombre)
	  IO.puts("DEBUG C7: ")
      pid = UsuarioSupervisor.start_child(nombre)
	  IO.puts("DEBUG C8: ")
	  IO.puts(inspect(pid))
	  
      {:reply, {:ok, pid}, state}
    error -> {:reply, {:error, error}, state}
   end
  end

  def get_private(nombre) do
    case UsuarioRegistry.lookup(nombre) do
      [{pid, _}] -> {:ok, pid}
      []->
        case Swarm.members({:usuario_agent, nombre}) do
          [] -> {:not_found, nil}
          _ ->
            {_, agente} = UsuarioAgent.start_link(nombre)
            ServerEntity.copiar(agente, {:usuario_agent, nombre})
            Swarm.join({:usuario_agent, nombre}, agente)
            pid = UsuarioSupervisor.start_child(nombre)
            {:ok, pid}
        end
      error -> {:error, error}
    end
  end

end
