defmodule PigeonTest do
  use ExUnit.Case
  doctest Pigeon

  test "Start a Router" do

      case Router.start_link([]) do
        {:ok, pid} ->  assert(pid, "Not initialize!")
        {:already_started, pid} -> assert(pid, "Not initialize!")
        {:error, reason} -> IO.puts "Error: #{reason}"
      end

  end


  test "Start a Server" do
    Pigeon.connect_to_cluster()
    ApplicationSupervisor.start_link(keys: :unique, name: Registry.Pigeon)
end

end
