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

  def editar_mensaje(idChatDestino, mensajeNuevo, idMensaje ,idOrigen) do
    GenServer.call(idChatDestino, {:editar_mensaje, mensajeNuevo, idMensaje, idOrigen})
  end

  def eliminar_mensaje(idChatDestino, idMensaje ,idOrigen) do
    GenServer.call(idChatDestino, {:eliminar_mensaje, idMensaje, idOrigen})
  end


  def handle_call({:enviar_mensaje, mensaje, idOrigen}, _from, state) do
    #(existing_value :: value ->    updated_value :: value))
    newState = Map.update!(state, :mensajes, fn (mensajes) -> mensajes ++ [{idOrigen, mensaje}] end)
    {:reply, newState, newState}
  end


  def handle_call({:editar_mensaje, mensajeNuevo, idMensaje, idOrigen}, _from, state) do

    newState = Map.update!(state, :mensajes, fn (mensajes) ->  List.keyreplace(mensajes, idOrigen, 0, {idOrigen, mensajeNuevo})  end)
    {:reply, newState, newState}
  end


  def handle_call({:eliminar_mensaje, idMensaje, idOrigen}, _from, state) do

    newState = Map.update!(state, :mensajes, fn (mensajes) ->  List.delete_at(mensajes, 0)  end)
    {:reply, newState, newState}
  end

end
