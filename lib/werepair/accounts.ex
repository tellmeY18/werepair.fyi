defmodule Werepair.Accounts do
  import Ecto.Query
  alias Werepair.{Repo, Accounts.User}

  def register(attrs) do
    changeset = User.registration_changeset(%User{}, attrs)

    changeset =
      if changeset.valid?,
        do:
          Ecto.Changeset.put_change(
            changeset,
            :password_hash,
            Pbkdf2.hash_pwd_salt(Ecto.Changeset.get_field(changeset, :password))
          ),
        else: changeset

    Repo.insert(changeset)
  end

  def authenticate(email, password) do
    user = Repo.get_by(User, email: String.downcase(String.trim(email)))

    cond do
      user && Pbkdf2.verify_pass(password, user.password_hash) && !user.banned ->
        {:ok, user}

      user ->
        {:error, :invalid_credentials}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  def current_user(id) when is_integer(id),
    do: Repo.one(from u in User, where: u.id == ^id and not u.banned)

  def current_user(_), do: nil
  def get_user!(id), do: Repo.get!(User, id)

  def update_profile(user, attrs),
    do: Repo.update(User.profile_changeset(Werepair.Access.actor!(user), attrs))

  def directory(query \\ "") do
    term = "%#{query}%"

    Repo.all(
      from u in User,
        where:
          u.technician and not u.banned and
            (like(u.name, ^term) or like(u.area, ^term) or like(u.skills, ^term)),
        order_by: [asc: u.name],
        limit: 100
    )
  end
end
