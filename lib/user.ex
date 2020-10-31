defmodule User do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end


  def enviar_mensaje(identificador, mensaje) do
    SupervisorMensajero.start_child({identificador, mensaje})
  end

  @spec receive_message(any, any, atom | pid | {atom, any} | {:via, atom, any}) :: :ok
  def receive_message(message, from, pid) do
    GenServer.cast(pid, {:receive_message, {message, from, pid}})
  end

  def get_historial(:user_chat, from, to) do
    SupervisorHistorialManager.start_child({:get_historial, {:user_chat, from, to}})
  end

  def get_historial(:group_chat, group) do
    SupervisorHistorialManager.start_child({:get_historial, {:group_chat, group}})
  end

  def modify_message(message, new_message) do
    {message, new_message}
  end

  def delete_message(message) do
    {message}
  end

  def send_secure_message(message, duration, to) do
    {message, duration, to}
  end
end
