defmodule AutoConnect do
  use GenServer
  import Crontab.CronExpression

  @every30seconds ~e[*/10]e

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: AutoConnect)
  end

  def init(_arg) do
    create_job()
    {:ok, AutoConnect}
  end

  def conectar() do
    Pigeon.connect_to_cluster()
    :timer.sleep(10000)
  end

  defp create_job() do
    ChatSeguroScheduler.new_job()
      |> Quantum.Job.set_schedule(@every30seconds)
      |> Quantum.Job.set_overlap(false)
      |> Quantum.Job.set_task({AutoConnect, :conectar, []})
      |> ChatSeguroScheduler.add_job()
  end

end
