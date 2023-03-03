defmodule FranklinWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use FranklinWeb, :controller
      use FranklinWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(articles assets fonts images favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: FranklinWeb

      import Plug.Conn
      import FranklinWeb.Gettext
      alias FranklinWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/franklin_web/templates",
        namespace: FranklinWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FranklinWeb.LayoutView, :live}

      unquote(view_helpers())
    end
  end

  def admin_live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FranklinWeb.LayoutView, :live_admin}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import FranklinWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.Component

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import FranklinWeb.ErrorHelpers
      import FranklinWeb.Gettext
      alias FranklinWeb.Router.Helpers, as: Routes

      import FranklinWeb.Components.Avatar
      import FranklinWeb.Components.ContentPreview
      import FranklinWeb.Components.NamePlate
      import FranklinWeb.Components.Navigation
      import FranklinWeb.Components.NowSummary
      import FranklinWeb.Components.SocialCard
      import FranklinWeb.Components.AdminSidebar
      import FranklinWeb.Components.AdminSidebarButton
      import FranklinWeb.Components.AdminSimpleTable
      import FranklinWeb.Components.Button

      import FranklinWeb.Components.AdminFormError
      import FranklinWeb.Components.AdminFormInput
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
