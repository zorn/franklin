defmodule FranklinWeb.Components.AdminFormInput do
  use Phoenix.Component

  import FranklinWeb.Components.AdminFormError

  def admin_form_input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn -> Phoenix.HTML.Form.input_name(f, field) end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn ->
      FranklinWeb.CoreComponents.translate_errors(f.errors || [], field)
    end)
    |> admin_form_input()
  end

  def admin_form_input(assigns) do
    ~H"""
    <div>
      <.label for={@id}>
        <%= @label %>
      </.label>

      <div class="mt-1">
        <input
          type={@type}
          name={@name}
          id={@id || @name}
          value={@value}
          class={[
            input_border(@errors),
            "block w-full rounded-md  shadow-sm   sm:text-sm"
          ]}
        />
      </div>
      <p class="mt-2 text-sm text-gray-500" id="email-description">We'll only use this for spam.</p>
    </div>

    <div>
      <label for="email" class="block text-sm font-medium text-gray-700"><%= @label %></label>
      <div class="relative mt-1 rounded-md shadow-sm">
        <input
          type="email"
          name="email"
          id="email"
          class="block w-full rounded-md border-red-300 pr-10 text-red-900 placeholder-red-300 focus:border-red-500 focus:outline-none focus:ring-red-500 sm:text-sm"
          placeholder="you@example.com"
          value="adamwathan"
          aria-invalid="true"
          aria-describedby="email-error"
        />
        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3">
          <!-- Heroicon name: mini/exclamation-circle -->
          <svg
            class="h-5 w-5 text-red-500"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z"
              clip-rule="evenodd"
            />
          </svg>
        </div>
      </div>
      <.admin_form_error :for={msg <- @errors}><%= msg %></.admin_form_error>
    </div>
    """
  end

  defp input_border([] = _errors),
    do: "border-indigo-300 focus:border-indigo-400 focus:ring-indigo-800/5"

  defp input_border([_ | _] = _errors),
    do: "border-red-400 focus:border-red-400 focus:ring-red-400/10"

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-medium text-gray-700">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end
end
