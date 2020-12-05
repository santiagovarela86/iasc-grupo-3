
defmodule Cliente do
use GenServer

  def start_link(userName) do
    GenServer.start_link(__MODULE__, userName, name: build_name(userName))
  end

  def init(userName) do
    state = %{
      userName: userName,
      pid: nil
    }

    Swarm.join({:cliente, userName}, self())
    registrar()
    {:ok, state}
  end

  def child_spec(name) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name]},
      type: :worker,
      restart: :transient
    }
  end

  def connect_to_cluster() do
    if(!List.foldl(nodos_router(), false, fn value, acum -> acum || Node.connect(value) end)) do
      raise RuntimeError.exception("No me pude conectar al router")
    end
    IO.puts("conectado")
  end

  def nodos_router() do
    [String.to_atom("router-1" <> "@localhost"), String.to_atom("router-2" <> "@localhost"), String.to_atom("router-3" <> "@localhost")]
  end

  def registrar() do
    :rpc.call(routeo_nodo(), UsuarioServer, :register_user, [name()])
  end



  ############## UNO A UNO ###################

  def enviar_mensaje(receiver, mensaje) do
    :rpc.call(routeo_nodo(), Usuario, :iniciar_chat, [name(), receiver])
    :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje, [name(), receiver, mensaje])
  end

  def editar_mensaje(receiver, mensaje_nuevo, id_mensaje) do
    :rpc.call(routeo_nodo(), Usuario, :editar_mensaje, [name(), receiver, mensaje_nuevo, id_mensaje])
  end

  def eliminar_mensaje(receiver, id_mensaje) do
    :rpc.call(routeo_nodo(), Usuario, :eliminar_mensaje, [name(), receiver, id_mensaje])
  end


  ############## GRUPOS ###################


  def crear_grupo(nombre_grupo) do
    :rpc.call(routeo_nodo(), Usuario, :crear_grupo, [name(), nombre_grupo])
  end

  def agregar_usuario_a_grupo(usuario, nombre_grupo) do
    :rpc.call(routeo_nodo(), Usuario, :agregar_usuario_a_grupo, [name(), usuario, nombre_grupo])
  end

  def enviar_mensaje_grupo(nombre_grupo, mensaje) do
    :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje_grupo, [name(), nombre_grupo, mensaje])
  end

  def editar_mensaje_grupo(nombre_grupo, mensaje_nuevo, id_mensaje) do
    :rpc.call(routeo_nodo(), Usuario, :editar_mensaje_grupo, [name(), nombre_grupo, mensaje_nuevo, id_mensaje])
  end

  def eliminar_mensaje_grupo(nombre_grupo, id_mensaje) do
    :rpc.call(routeo_nodo(), Usuario, :eliminar_mensaje_grupo, [name(), nombre_grupo, id_mensaje])
  end

  ############## CHAT SEGURO ###################

  def crear_chat_seguro(receiver, tiempo_limite) do
    :rpc.call(routeo_nodo(), Usuario, :iniciar_chat_seguro, [
      name(),
      receiver,
      tiempo_limite
    ])  end

  def enviar_mensaje_seguro(receiver, mensaje_seguro) do
    :rpc.call(routeo_nodo(), Usuario, :enviar_mensaje_seguro, [
      name(),
      receiver,
      mensaje_seguro
    ])  end

  def build_name(nombre) do
    name = :crypto.hash(:md5, nombre <> to_string(DateTime.utc_now())) |> Base.encode16()
    {:via, :swarm, name}
  end

  def handle_info(mensaje, state) do
    IO.puts(mensaje)
    {:noreply, state}
  end

  def routeo_nodo() do
    Router.route()
  end

  def name() do
    List.first(String.split(to_string(Node.self),"@"))
  end

end
