defmodule UsuarioAgent do
  use Agent

  def start_link(nombre) do
    Agent.start_link(fn -> %{
      nombre: nombre,
      chats_uno_a_uno: MapSet.new(),
      chats_seguros: MapSet.new(),
      chats_de_grupo: MapSet.new()
    } end,
    name: UsuarioAgentRegistry.build_name(nombre)
    )
  end

  def get_nombre(agente) do
    Agent.get(agente, &Map.get(&1, :nombre))
  end

  def get_chats_uno_a_uno(agente) do
    Agent.get(agente, &Map.get(&1, :chats_uno_a_uno))
  end

  def get_chats_seguros(agente) do
    Agent.get(agente, &Map.get(&1, :chats_seguros))
  end

  def get_chats_de_grupo(agente) do
    Agent.get(agente, &Map.get(&1, :chats_de_grupo))
  end

  def agregar_chat_uno_a_uno(agente, chat_id) do
    Agent.update(agente, fn(state) -> Map.update!(state, :chats_uno_a_uno, fn(chats_uno_a_uno) -> MapSet.put(chats_uno_a_uno, chat_id) end) end)
  end

  def agregar_chat_seguros(agente, chat_id) do
    Agent.update(agente, fn(state) -> Map.update!(state, :chats_seguros, fn(chats_seguros) -> MapSet.put(chats_seguros, chat_id) end) end)
  end

  def agregar_chat_de_grupo(agente, chat_id) do
    Agent.update(agente, fn(state) -> Map.update!(state, :chats_de_grupo, fn(chats_de_grupo) -> MapSet.put(chats_de_grupo, chat_id) end) end)
  end

end
