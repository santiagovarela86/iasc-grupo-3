defmodule Entity do
  def checksum_respuesta(agente, getter) do
    :crypto.hash(:md5, inspect(getter.(agente)))
  end

  def copiar_todo() do
    IO.puts("a copiar")
    node = Router.route(Node.self)
    IO.puts("voy a routear a #{node}")
    usuarios = ServerEntity.get_usuarios()
    IO.puts("Obtuve estos usuarios: #{usuarios}")
    Enum.map(usuarios, fn usuario -> UsuarioServer.init_user(usuario) end)
    #obtener todos los grupos (si no existe forma directa, se podrian registrar los nombres de grupos asociados a todos los actores)
    #agrupar por tipo de entidad, crear las entidades con nombre = nombre_grupo, y copiar state de cada agent con copiar/2
  end

  def copiar(agente_copia, grupo_de_agentes) do
      case primera_respuesta(grupo_de_agentes, fn(a) -> a end) do
        nil -> {}
        agente_target ->
          Agent.update(agente_copia, fn(_state) ->  Agent.get(agente_target, fn(state2) -> state2 end) end)
    end
  end

  def campo_actualizado(grupo_swarm, getter) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> Entity.checksum_respuesta(agente, getter)end)
    |> Enum.to_list()
    |> (&Enum.all?(&1, fn(checksum) -> List.first(&1) == checksum end)).()
  end

  def primera_respuesta(grupo_swarm, funcion) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> funcion.(agente) end, ordered: false)
    |> Stream.filter(fn({ok?, _}) -> ok? == :ok end)
    #|> Stream.map(fn {_, value} -> value end)
    |> Enum.take(1)
    |> List.first()
  end

  def aplicar_cambio(grupo_swarm, funcion) do
    Enum.each(Swarm.members(grupo_swarm), fn(agente) -> Task.start(fn -> funcion.(agente) end) end)
    :ok
  end

  def consenso(grupo_swarm, getter) do
    Swarm.members(grupo_swarm)
    |> Task.async_stream(fn(agente) -> {agente, Entity.checksum_respuesta(agente, getter)}end)
    |> Enum.to_list()
    |> Enum.filter(&match?({:ok, _}, &1))
    |> Enum.map(fn({_ok, response}) -> response end)
    |> Enum.group_by(fn({_agente,checksum}) -> checksum end)
    |> Enum.max_by(fn({_checksum, grupo }) -> length(grupo) end)
    |> case do {_checksum, lista_de_respuestas} -> lista_de_respuestas end
    |> List.first()
    |> case do {agente, _checksum} -> agente end
  end
  def exportar_campo(de_agent, a_grupo_swarm, campo_atom) do
      fn(_usuarios) -> Agent.get(de_agent, &Map.get(&1, campo_atom)) end
      |> (&fn(state) -> Map.update!(state, campo_atom, &1) end).()
      |> (&fn(agente) -> Agent.update(agente, &1) end).()
      |> (&Entity.aplicar_cambio(a_grupo_swarm, &1)).()
  end
end
