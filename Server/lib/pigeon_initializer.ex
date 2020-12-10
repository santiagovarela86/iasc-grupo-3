defmodule PigeonInitializer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, pid} = ServerAgent.start_link()
    Swarm.join(:server_agent, pid)
    ServerEntity.copiar_faltantes()
    {:ok, []}
  end

  def child_spec do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]},
      type: :worker,
      restart: :permanent
    }
  end

end
