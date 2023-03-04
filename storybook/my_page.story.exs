defmodule Storybook.MyPage do
  use PhoenixStorybook.Story, :page

  def description, do: "My page description"

  # Declare an optional tab-based navigation in your page:
  def navigation do
    [
      {:tab_one, "Tab One", {:fa, "dice-one", :regular}},
      {:tab_two, "Tab Two", {:fa, "dice-two", :regular}}
    ]
  end

  # This is a dummy fonction that you should replace with your own HEEx content.
  def render(assigns) do
    ~H"<h1>An example page</h1>"
  end
end
