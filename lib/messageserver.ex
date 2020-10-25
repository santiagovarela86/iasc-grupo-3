defmodule MessageServer do

  def send_message(message, from, to) do
    {message, from, to}

    # pid_user_list = get_users(to)
    # Enum.Map(pid_user_list, fn
    # user.receive_message(message, from)
  end

  # def add_user(user, id) do

  # end

  # def add_group(group) do

  # end

  # def get_user_id(user) do
  #   :id
  # end

end
