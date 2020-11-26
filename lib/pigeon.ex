defmodule Pigeon do
  use Application

  def start(_type, _args) do
    ApplicationSupervisor.start_link(keys: :unique, name: Registry.Pigeon)
  end
end
