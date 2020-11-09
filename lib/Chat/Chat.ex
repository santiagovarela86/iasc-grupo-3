defmodule Chat do
  use GenServer

  def start_link(mensajes, usuarios, name) do
    GenServer.start_link(__MODULE__, {mensajes, usuarios}, name: name)
  end

  def init({mensajes, usuarios}) do
    state = %{
      mensajes: mensajes,
      usuarios: usuarios
    }

    {:ok, state}
  end

  def enviar_mensaje(idChatDestino, mensaje, idOrigen) do
    GenServer.call(idChatDestino, {:enviar_mensaje, mensaje, idOrigen})
  end

  def handle_call({:enviar_mensaje, mensaje, idOrigen}, _from, state) do
    #(existing_value :: value ->    updated_value :: value))
    newState = Map.update!(state, :mensajes, fn (mensajes) -> mensajes ++ [{idOrigen, mensaje}] end)
    {:reply, newState, newState}
  end
end
