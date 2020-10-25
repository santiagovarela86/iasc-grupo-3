defmodule UserTest do
  use ExUnit.Case
  doctest User

  test "user sends message" do
    assert User.send_message("hello", "pepe") == {"hello", "pepe"}
  end
end
