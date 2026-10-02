defmodule WerepairWeb.PlatformController do
  use WerepairWeb, :controller
  import WerepairWeb.Auth, only: [require_user: 2]
  alias Werepair.{Accounts, Community, Repairs, Events}

  plug :require_user
       when action in [
              :profile,
              :save_profile,
              :report,
              :save_report,
              :admin,
              :resolve,
              :add_cost
            ]

  def home(conn, _),
    do:
      render(conn, :home,
        technicians: length(Accounts.directory()),
        requests: Repairs.list(),
        events: Events.list()
      )

  def directory(conn, params),
    do:
      render(conn, :directory,
        people: Accounts.directory(params["q"] || ""),
        form: Phoenix.Component.to_form(params),
        q: params["q"] || ""
      )

  def person(conn, %{"id" => id}) do
    person = Accounts.get_user!(id)
    Werepair.Access.allow!(not person.banned)

    render(conn, :person,
      person: person,
      stats: Community.stats(person),
      requests: Repairs.list("", person.id)
    )
  end

  def profile(conn, _) do
    user = conn.assigns.current_scope

    render(conn, :profile,
      form: Phoenix.Component.to_form(Accounts.User.profile_changeset(user, %{})),
      requests: Repairs.list("", user.id),
      stats: Community.stats(user)
    )
  end

  def save_profile(conn, %{"user" => attrs}) do
    case Accounts.update_profile(conn.assigns.current_scope, attrs) do
      {:ok, _} ->
        conn |> put_flash(:info, "Profile saved.") |> redirect(to: ~p"/profile")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:profile,
          form: Phoenix.Component.to_form(changeset),
          requests: Repairs.list("", conn.assigns.current_scope.id),
          stats: Community.stats(conn.assigns.current_scope)
        )
    end
  end

  def costs(conn, _) do
    costs = Community.costs()
    month = Date.utc_today() |> Date.beginning_of_month()
    current = Enum.filter(costs, &(Date.compare(&1.date, month) != :lt))

    total = fn kind ->
      current
      |> Enum.filter(&(&1.kind == kind))
      |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.amount, &2))
    end

    render(conn, :costs, costs: costs, spent: total.("expense"), donated: total.("donation"))
  end

  def learn(conn, _), do: render(conn, :learn)
  def about(conn, _), do: render(conn, :about)

  def report(conn, params),
    do:
      render(conn, :report,
        type: params["type"],
        target_id: params["id"],
        form: Phoenix.Component.to_form(%{}, as: :report)
      )

  def save_report(conn, %{"type" => type, "target_id" => id, "report" => attrs}) do
    case Community.report(conn.assigns.current_scope, type, id, attrs) do
      {:ok, _} ->
        conn |> put_flash(:info, "Report sent to the organiser.") |> redirect(to: ~p"/")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:report, type: type, target_id: id, form: Phoenix.Component.to_form(changeset))
    end
  end

  def admin(conn, _),
    do:
      render(conn, :admin,
        reports: Community.reports(conn.assigns.current_scope),
        form:
          Phoenix.Component.to_form(
            Community.Cost.changeset(%Community.Cost{date: Date.utc_today()}, %{})
          )
      )

  def resolve(conn, %{"id" => id, "action" => action}) do
    Community.resolve(conn.assigns.current_scope, id, action)
    conn |> put_flash(:info, "Moderation decision recorded.") |> redirect(to: ~p"/admin")
  end

  def add_cost(conn, %{"cost" => attrs}) do
    case Community.add_cost(conn.assigns.current_scope, attrs) do
      {:ok, _} ->
        conn |> put_flash(:info, "Ledger updated.") |> redirect(to: ~p"/costs")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:admin,
          reports: Community.reports(conn.assigns.current_scope),
          form: Phoenix.Component.to_form(changeset)
        )
    end
  end
end
