defmodule WerepairWeb.Router do
  use WerepairWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WerepairWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WerepairWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WerepairWeb do
    get "/health", HealthController, :show
  end

  scope "/", WerepairWeb do
    pipe_through :browser

    get "/", PlatformController, :home
    get "/sign-in", SessionController, :new
    post "/sign-in", SessionController, :create
    post "/sign-out", SessionController, :delete
    get "/register", SessionController, :register
    post "/register", SessionController, :save
    get "/technicians", PlatformController, :directory
    get "/people/:id", PlatformController, :person
    get "/requests", RepairController, :index
    get "/requests/new", RepairController, :new
    post "/requests", RepairController, :create
    get "/requests/:id", RepairController, :show
    get "/requests/:id/photo", RepairController, :photo
    post "/requests/:id/entries", RepairController, :entry
    post "/requests/:id/choose", RepairController, :choose
    post "/requests/:id/status", RepairController, :status
    post "/requests/:id/confirm", RepairController, :confirm
    post "/requests/:id/reviews", RepairController, :review
    get "/requests/:id/journal", RepairController, :journal
    post "/requests/:id/wiki", RepairController, :wiki
    get "/events", EventController, :index
    get "/events/new", EventController, :new
    post "/events", EventController, :create
    get "/events/:id", EventController, :show
    post "/events/:id/join", EventController, :join
    post "/events/:id/items", EventController, :item
    post "/events/:id/participations/:participation_id", EventController, :record
    post "/events/:id/complete", EventController, :complete
    get "/profile", PlatformController, :profile
    post "/profile", PlatformController, :save_profile
    get "/costs", PlatformController, :costs
    get "/learn", PlatformController, :learn
    get "/about", PlatformController, :about
    get "/reports/new", PlatformController, :report
    post "/reports", PlatformController, :save_report
    get "/admin", PlatformController, :admin
    post "/admin/reports/:id", PlatformController, :resolve
    post "/admin/costs", PlatformController, :add_cost
  end

  # Other scopes may use custom stacks.
  # scope "/api", WerepairWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:werepair, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
