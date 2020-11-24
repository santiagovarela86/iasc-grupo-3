defmodule ChatDeGrupoAgent do
  use Agent

  def start_link(creador, nombre_grupo) do
    Agent.start_link(
      fn -> %{
        usuarios: MapSet.new([creador]),
        admins: MapSet.new([creador]),
        mensajes: Map.new,
        nombre_grupo: nombre_grupo
      } end,
      name: ChatDeGrupoAgentRegistry.build_name(nombre_grupo))
  end

  def get_nombre(agente) do
    Agent.get(agente, &Map.get(&1, :nombre_grupo))
  end

  def agregar_usuario(agente, usuario) do
    Agent.update(agente, fn(state) -> Map.update!(state, :usuarios, fn(usuarios) -> MapSet.put(usuarios, usuario) end) end)
  end

  def eliminar_usuario(agente, usuario) do
    Agent.update(agente, fn(state) -> Map.update!(state, :usuarios, fn (usuarios) -> MapSet.delete(usuarios, usuario) end) end )
  end

  def agregar_admin(agente, usuario) do
    Agent.update(agente, fn(state) -> Map.update!(state, :admins, fn(admins) -> MapSet.put(admins, usuario) end) end)
  end

  def eliminar_admin(agente, usuario) do
    Agent.update(agente, fn(state) -> Map.update!(state, :admins, fn (admins) -> MapSet.delete(admins, usuario) end) end )
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

end
