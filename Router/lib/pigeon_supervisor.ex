defmodule ApplicationSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(router_name) do
    children = [{RouterSupervisor, router_name}]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
