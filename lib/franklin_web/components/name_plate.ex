defmodule FranklinWeb.Components.NamePlate do
  use Phoenix.Component

  attr :name, :string, required: true
  attr :title, :string, required: true
  attr :bio, :string, required: true

  @spec name_plate(map()) :: Phoenix.LiveView.Rendered.t()
  def name_plate(assigns) do
    ~H"""
    <div class="bg-orange-500"><%= @name %></div>
    <div><%= @title %></div>
    <div><%= @bio %></div>
    """
  end
end
