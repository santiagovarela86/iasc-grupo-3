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
    limite = ChatSeguroAgent.get_tiempo_limite(agente)

    ChatAgent.get_mensajes(agente)
    |> Enum.to_list()
    |> Enum.map( fn {id, {origen, mensaje, publicado, modificado}} -> cond do
      DateTime.diff(DateTime.utc_now(), publicado, :second) > limite -> {id, {origen, :borrado, publicado, modificado}}
      true -> {id, {origen, mensaje, publicado, modificado}}
    end end )
    |> Enum.into(%{})
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

  def registrar_mensaje(agente, mensaje, origen, fecha) do
    ChatAgent.registrar_mensaje(agente, mensaje, origen, fecha)
  end

  def eliminar_mensaje(agente, mensaje_id) do
    ChatAgent.eliminar_mensaje(agente, mensaje_id)
  end

  def modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id) do
    ChatAgent.modificar_mensaje(agente, origen, mensaje_nuevo, mensaje_id)
  end

  def build_name(usuario1, usuario2) do
    {:via, :swarm, {:chat_seguro_agent, Node.self(), MapSet.new([usuario1, usuario2])}}
  end
end
