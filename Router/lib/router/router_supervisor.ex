defmodule RouterSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, name, name: __MODULE__)
  end

  def init(name) do
    children = [
      {Router, name}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
