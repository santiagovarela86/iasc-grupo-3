defmodule Cliente2 do

    defdelegate registrar(userName), to: Cliente.Interact
    defdelegate enviar_mensaje(sender, receiver, mensaje), to: Cliente.Interact
  
  end
  