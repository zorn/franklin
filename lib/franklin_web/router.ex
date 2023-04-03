defmodule FranklinWeb.Router do
  use FranklinWeb, :router

  import FranklinWeb.Admin.UserAuth
  import PhoenixStorybook.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :assign_root_layout do
    plug :put_root_layout, html: {FranklinWeb.Layouts, :root}
  end

  pipeline :assign_root_layout_admin do
    plug :put_root_layout, html: {FranklinWeb.LayoutsAdmin, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    storybook_assets()
  end

  scope "/", FranklinWeb do
    pipe_through [:browser, :assign_root_layout]

    scope "/articles", Articles do
      live "/", IndexLive, :index, as: :article_index
      live "/*slug", ViewerLive, :show, as: :article_viewer
    end

    live "/", HomeLive, :index
    get "/old-home", PageController, :home
    get "/index.xml", SyndicationController, :rss

    live_storybook("/storybook", backend_module: FranklinWeb.Storybook)
  end

  scope "/admin", FranklinWeb.Admin do
    pipe_through [:browser, :assign_root_layout_admin, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{FranklinWeb.Admin.UserAuth, :ensure_authenticated}] do
      live "/", IndexLive, :index, as: :admin_index
      live "/upload-demo", UploadDemoLive, :index, as: :admin_upload_demo
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      scope "/articles", Articles do
        live "/", IndexLive, :index, as: :admin_article_index
        live "/:id", ViewerLive, :show, as: :admin_article_viewer
        live "/editor/new", EditorLive, :new, as: :admin_article_editor
        live "/editor/:id", EditorLive, :edit, as: :admin_article_editor
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", FranklinWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:franklin, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FranklinWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/admin", FranklinWeb.Admin, as: :admin do
    pipe_through [:browser, :assign_root_layout_admin, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{FranklinWeb.Admin.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/log_in", UserLoginLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/admin", FranklinWeb.Admin, as: :admin do
    pipe_through [:browser, :assign_root_layout]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{FranklinWeb.Admin.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
