defmodule WerepairWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use WerepairWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <a class="skip" href="#main">Skip to content</a>
    <header>
      <a class="brand" href={~p"/"}>werepair.fyi</a>
      <nav aria-label="Main navigation">
        <a href={~p"/requests"}>Requests</a>
        <a href={~p"/technicians"}>Technicians</a>
        <a href={~p"/events"}>Events</a>
        <a href={~p"/learn"}>Wiki & learning</a>
        <a href={~p"/costs"}>What it costs</a>
        <a :if={@current_scope} href={~p"/profile"}>My profile</a>
        <a :if={@current_scope && @current_scope.admin} href={~p"/admin"}>Admin</a>
        <a :if={!@current_scope} href={~p"/sign-in"}>Sign in</a>
        <.form :if={@current_scope} for={%{}} action={~p"/sign-out"} id="sign-out-form" class="inline">
          <button>Sign out</button>
        </.form>
      </nav>
    </header>
    <main id="main">
      <p :if={Application.get_env(:werepair, :demo, false)} class="notice small">
        DEMO · Fictional people, repairs and ledger. Do not contact these listings.
      </p>
      <.flash_group flash={@flash} />
      {render_slot(@inner_block)}
    </main>
    <footer>
      Repair over Replace. · <a href={~p"/about"}>Rules & privacy</a>
      · <a href={~p"/costs"}>What it costs</a>
      · <a href={Werepair.Wiki.base_url()}>Wiki · CC BY-SA 4.0</a>
      · Code: AGPL-3.0 · <a href="mailto:hello@werepair.fyi">Contact</a>
    </footer>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end
end
