defmodule Entity do
  def checksum_respuesta(agente, getter) do
    :crypto.hash(:md5, getter.(agente))
  end

  def copiar_todo() do
    #obtener todos los grupos (si no existe forma directa, se podrian registrar los nombres de grupos asociados a todos los actores)
    #agrupar por tipo de entidad, crear las entidades con nombre = nombre_grupo, y copiar state de cada agent con copiar/2
  end

  def copiar(agente_copia, grupo_de_agentes) do
    agente_target = primera_respuesta(grupo_de_agentes, fn(a) -> a end)
    Agent.update(agente_copia, fn(_state) ->  Agent.get(agente_target, fn(state2) -> state2 end) end)
  end
  def campo_actualizado(grupo_swarm, getter) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> Entity.checksum_respuesta(agente, getter)end)
    |> Enum.to_list()
    |> (&Enum.all?(&1, fn(checksum) -> List.first(&1) == checksum end)).()
  end

  def primera_respuesta(grupo_swarm, funcion) do
    IO.puts("66666666666666666666")
    IO.inspect(grupo_swarm)
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> funcion.(agente) end, ordered: false)
    |> Stream.filter(fn({a, _}) -> a == :ok end)
    |> Enum.take(1)
    |> List.first()
    IO.puts("77777777777777777777777")

  end

  def aplicar_cambio(grupo_swarm, funcion) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> funcion.(agente) end, ordered: false)
    |> Enum.to_list()
  end
end
