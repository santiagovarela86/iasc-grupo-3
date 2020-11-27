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

  def actualizar(grupo_swarm) do
    #compara checksums en cada campo del grupo del swarm y resuelve conflictos si alguno difiere (segun criterios en cada entidad)
  end

  def primera_respuesta(grupo_swarm, funcion) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> funcion.(agente) end, ordered: false)
    |> Stream.filter(fn({a, _}) -> a == :ok end)
    |> Enum.take(1)
    |> List.first()
  end

  def aplicar_cambio(grupo_swarm, funcion) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> funcion.(agente) end, ordered: false)
    |> Enum.to_list()
  end
end
