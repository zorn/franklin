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

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: FranklinWeb.Layouts]

      import Plug.Conn

      import FranklinWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FranklinWeb.Layouts, :live}

      unquote(html_helpers())
    end
  end

  def admin_live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FranklinWeb.Layouts, :live_admin}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      # import FranklinWeb.CoreComponents
      # import FranklinWeb.Gettext

      import FranklinWeb.CoreComponents, only: [translate_error: 1]

      use PrimerLive

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Components
      import FranklinWeb.Components.Avatar
      import FranklinWeb.Components.ContentPreview
      import FranklinWeb.Components.NamePlate
      import FranklinWeb.Components.Navigation
      import FranklinWeb.Components.NowSummary
      import FranklinWeb.Components.SocialCard
      import FranklinWeb.Components.AdminSidebar
      import FranklinWeb.Components.AdminSidebarButton
      import FranklinWeb.Components.AdminSimpleTable
      # import FranklinWeb.Components.Button
      import FranklinWeb.Components.AdminFormError
      import FranklinWeb.Components.AdminFormInput

      @doc """
      Generates tag for inlined form input errors.
      """
      def error_tag(form, field, class \\ "invalid-feedback") do
        Enum.map(Keyword.get_values(form.errors, field), fn error ->
          Phoenix.HTML.Tag.content_tag(:span, translate_error(error),
            class: class,
            phx_feedback_for: Phoenix.HTML.Form.input_name(form, field)
          )
        end)
      end

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: FranklinWeb.Endpoint,
        router: FranklinWeb.Router,
        statics: FranklinWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
