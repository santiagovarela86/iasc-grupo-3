defmodule ChatDeGrupoAgent do
  use Agent

  def start_link(creador, nombre_grupo) do
    Agent.start_link(
      fn -> %{
        usuarios: MapSet.new([creador]),
        admins: MapSet.new([creador]),
        mensajes: Map.new,
        modificacion_usuarios: DateTime.utc_now(),
        modificacion_admins: DateTime.utc_now(),
        nombre_grupo: nombre_grupo
      } end,
      name: build_name(nombre_grupo))
  end

  def get_nombre(agente) do
    Agent.get(agente, &Map.get(&1, :nombre_grupo))
  end

  def get_modificacion_usuarios(agente) do
    Agent.get(agente, &Map.get(&1, :modificacion_usuarios))
  end

  def get_modificacion_admins(agente) do
    Agent.get(agente, &Map.get(&1, :modificacion_admins))
  end

  def agregar_usuario(agente, usuario) do
    update_time = fn(map) -> Map.update!(map, :modificacion_usuarios, fn(_time) -> DateTime.utc_now() end) end
    Agent.update(agente, fn(state) ->  Map.update!(update_time.(state), :usuarios, fn(usuarios) -> MapSet.put(usuarios, usuario) end) end)
  end

  def eliminar_usuario(agente, usuario) do
    update_time = fn(map) -> Map.update!(map, :modificacion_usuarios, fn(_time) -> DateTime.utc_now() end) end
    Agent.update(agente, fn(state) -> Map.update!(update_time.(state), :usuarios, fn (usuarios) -> MapSet.delete(usuarios, usuario) end) end )
  end

  def agregar_admin(agente, usuario) do
    update_time = fn(map) -> Map.update!(map, :modificacion_admins, fn(_time) -> DateTime.utc_now() end) end
    Agent.update(agente, fn(state) -> Map.update!(update_time.(state), :admins, fn(admins) -> MapSet.put(admins, usuario) end) end)
  end

  def eliminar_admin(agente, usuario) do
    update_time = fn(map) -> Map.update!(map, :modificacion_admins, fn(_time) -> DateTime.utc_now() end) end
    Agent.update(agente, fn(state) -> Map.update!(update_time.(state), :admins, fn (admins) -> MapSet.delete(admins, usuario) end) end )
  end
  def get_usuarios(agente) do
    ChatAgent.get_usuarios(agente)
  end

  def get_admins(agente) do
    Agent.get(agente, &Map.get(&1, :admins))
  end

  def get_mensajes(agente) do
    ChatAgent.get_mensajes(agente)
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

  def build_name(nombre_grupo) do
    name = :crypto.hash(:md5, nombre_grupo <> to_string(DateTime.utc_now)) |> Base.encode16()
    {:via, :swarm, name}
  end

end
