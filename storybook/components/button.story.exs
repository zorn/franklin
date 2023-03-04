defmodule Storybook.Components.Button do
  use PhoenixStorybook.Story, :component

  alias PhoenixStorybook.Stories.Variation

  # iframe needed to properly pickup font family.
  def container, do: :iframe

  def function, do: &FranklinWeb.Components.Button.button/1

  def attributes, do: []
  def slots, do: []

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Subscribe"
        }
      }
    ]
  end
end
