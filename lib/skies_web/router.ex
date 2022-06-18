defmodule SkiesWeb.Router do
  use SkiesWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {SkiesWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SkiesWeb do
    pipe_through(:browser)
    live("/planets", PlanetLive.Index, :index)
    live("/planets/new", PlanetLive.Index, :new)
    live("/planets/:id/edit", PlanetLive.Index, :edit)

    live("/planets/:id", PlanetLive.Show, :show)
    live("/planets/:id/show/edit", PlanetLive.Show, :edit)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", SkiesWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: SkiesWeb.Telemetry)
    end
  end
end
