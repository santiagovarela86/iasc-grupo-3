defmodule ChatSeguroAgent do
  use Agent

  def start_link(usuario1, usuario2, tiempo_limite) do
    Agent.start_link(fn -> %{
      usuarios: MapSet.new([usuario1, usuario2]),
      mensajes: Map.new,
      tiempo_limite: tiempo_limite,
      modificacion_tiempo_limite: DateTime.utc_now()
    } end,
    name: build_name(usuario1, usuario2)
    )
  end

  def get_usuarios(agente) do
    ChatAgent.get_usuarios(agente)
  end

  def get_mensajes(agente) do
    ChatAgent.get_mensajes(agente)
  end

  def get_tiempo_limite(agente) do
    Agent.get(agente, &Map.get(&1, :tiempo_limite))
  end

  def get_modificacion_tiempo_limite(agente) do
    Agent.get(agente, &Map.get(&1, :modificacion_tiempo_limite))
  end

  def cambiar_tiempo_limite(agente, tiempo_nuevo) do
    update_time = fn(map) -> Map.update!(map, :modificacion_tiempo_limite, fn(_time) -> DateTime.utc_now() end) end
    Agent.update(agente, fn(state) ->  Map.update!(update_time.(state), :tiempo_limite, fn(_tiempo) -> tiempo_nuevo end) end)
  end

  @spec registrar_mensaje(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def registrar_mensaje(agente, mensaje, origen) do
    ChatAgent.registrar_mensaje(agente, mensaje, origen)
  end

  def eliminar_mensaje(agente, mensaje_id) do
    ChatAgent.eliminar_mensaje(agente, mensaje_id)
  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do
    ChatAgent.modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id)
  end

  def build_name(usuario1, usuario2) do
    #usuarios_en_orden = Enum.sort([usuario1, usuario2])
    usuarios_en_orden = Enum.sort([usuario1, usuario2, @secure_suffix])
    name = :crypto.hash(:md5, List.first(usuarios_en_orden) <> List.last(usuarios_en_orden) <> to_string(DateTime.utc_now)) |> Base.encode16()
    {:via, :swarm, name}
  end
end
