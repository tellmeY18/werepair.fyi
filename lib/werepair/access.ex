defmodule Werepair.Access do
  def allow!(true), do: :ok
  def allow!(_), do: raise(Werepair.ForbiddenError)

  def actor!(user) do
    active = user && Werepair.Accounts.current_user(user.id)
    allow!(not is_nil(active))
    active
  end

  def admin!(user) do
    user = actor!(user)
    allow!(user.admin)
    user
  end
end
