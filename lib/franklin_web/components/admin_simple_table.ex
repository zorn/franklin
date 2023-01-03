defmodule FranklinWeb.Components.AdminSimpleTable do
  use Phoenix.Component

  slot :column, doc: "Columns with column labels" do
    attr :label, :string, required: true, doc: "Column label"
  end

  attr :rows, :list, default: []

  @spec admin_simple_table(map()) :: Phoenix.LiveView.Rendered.t()
  def admin_simple_table(assigns) do
    ~H"""
    <table class="min-w-full divide-y divide-gray-300">
      <thead class="bg-gray-50">
        <tr>
          <%= for col <- @column do %>
            <%= if col.label == "Edit" do %>
              <th scope="col" class="relative px-3 py-3.5 ">
                <span class="sr-only">Edit</span>
              </th>
            <% else %>
              <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                <%= col.label %>
              </th>
            <% end %>
          <% end %>
        </tr>
      </thead>
      <%= for row <- @rows do %>
        <tr>
          <%= for col <- @column do %>
            <%= if col.label == "Edit" do %>
              <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                <%= render_slot(col, row) %>
                <%!-- <a href="#" class="text-indigo-600 hover:text-indigo-900">
                  Edit<span class="sr-only">, Lindsay Walton</span>
                </a> --%>
              </td>
            <% else %>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                <%= render_slot(col, row) %>
              </td>
            <% end %>
          <% end %>
        </tr>
      <% end %>
    </table>
    """
  end

  # @spec admin_simple_table(map()) :: Phoenix.LiveView.Rendered.t()
  # def admin_simple_table(assigns) do
  #   ~H"""
  #   <div class="mt-8 flex flex-col">
  #     <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
  #       <div class="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
  #         <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
  #           <table class="min-w-full divide-y divide-gray-300">
  #             <thead class="bg-gray-50">
  #               <tr>
  #                 <%= for col <- @column do %>
  #                   <th
  #                     scope="col"
  #                     class="py-3.5 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6"
  #                   >
  #                     <%= col.label %>
  #                   </th>
  #                 <% end %>
  #                 <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
  #                   <span class="sr-only">Edit</span>
  #                 </th>
  #               </tr>
  #             </thead>
  #             <%= for row <- @rows do %>
  #               <tr>
  #                 <%= for col <- @column do %>
  #                   <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
  #                     <%= render_slot(col, row) %>
  #                   </td>
  #                 <% end %>
  #                 <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
  #                   <a href="#" class="text-indigo-600 hover:text-indigo-900">
  #                     Edit<span class="sr-only">, Lindsay Walton</span>
  #                   </a>
  #                 </td>
  #               </tr>
  #             <% end %>
  #           </table>
  #         </div>
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end
end
