defmodule ServerAgentSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    Supervisor.init([], strategy: :one_for_one)
  end

  def start_server_agent() do
    spec = %{
      id: ServerAgent,
      start: {ServerAgent, :start_link, []},
      type: :worker,
      restart: :transient
    }

    {:ok, pid} = Supervisor.start_child(ServerAgentSupervisor, spec)
    IO.inspect(pid)
    Swarm.join(:server_agent, pid)
  end
end
