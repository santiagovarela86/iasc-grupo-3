defmodule UserFinder do
  def findPidFromUsername(username) do
    case username do
      "username1" ->
        [{"username1", User1}]

      "username2" ->
        [{"username2", User2}]

      "username3" ->
        [{"username3", User3}]

      "group1" ->
        [
          {"username1", User1},
          {"username2", User2},
          {"username3", User3}
        ]

      _ ->
        []
    end
  end
end
