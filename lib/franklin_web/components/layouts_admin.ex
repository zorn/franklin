defmodule FranklinWeb.LayoutsAdmin do
  use FranklinWeb, :admin_html

  use PrimerLive

  embed_templates "layouts_admin/*"
end
