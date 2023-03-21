defmodule FranklinWeb.PageHTML do
  use FranklinWeb, :html

  import FranklinWeb.CoreComponents, only: [flash_group: 1]

  embed_templates "page_html/*"
end
