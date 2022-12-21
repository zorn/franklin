defmodule FranklinWeb.Components.AdminFormInput do
  use Phoenix.Component

  import FranklinWeb.Components.AdminFormError

  def admin_form_input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn ->
      _name = Phoenix.HTML.Form.input_name(f, field)
      # if assigns.multiple, do: name <> "[]", else: name
    end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn -> translate_errors(f.errors || [], field) end)
    |> admin_form_input()
  end

  def admin_form_input(assigns) do
    ~H"""
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
      <div class="mt-1">
        <input
          type="email"
          name="email"
          id="email"
          class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          placeholder="you@example.com"
          aria-describedby="email-description"
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

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(BlogWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BlogWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
