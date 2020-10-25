defmodule Group do

  def new_group_chat(creator_user) do
    :groupid
  end

  def add_member_to_group(groupid, new_member) do
    {groupid, new_member}
  end

  def remove_member_from_group(groupid, remove_member) do
    {groupid, remove_member}
  end

  def make_user_admin(groupid, admin_user) do
    {groupid, admin_user}
  end

end
