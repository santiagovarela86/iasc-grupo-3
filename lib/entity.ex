defmodule Entity do
  def checksum_mensajes(agente) do
    :crypto.hash(:md5, Agent.get(agente, fn(state) -> state.mensajes end))
  end

  def copiar(agente, agente_target) do
  Agent.update(agente, fn(_state) ->  Agent.get(agente_target, fn(state2) -> state2 end) end)
  end

  def actualizar(agente) do
    #llamada async para compara con otros members del swarm y actualizar si la mayoria no es igual
  end

  def resolver_conflicto(agente) do
    #tiene que comparar los mensajes con los agents que no tengan mismo checksum y ju
  end

  def primera_respuesta(grupo_swarm, funcion) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(chat) -> funcion.(chat) end, ordered: false)
    |> Stream.filter(fn({a, _}) -> a == :ok end)
    |> Enum.take(1)
  end
end
