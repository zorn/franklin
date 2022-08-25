defmodule Franklin.Posts.Commands.CreatePost do
  use Domo

  alias Franklin.Posts.Validations

  @type t :: %__MODULE__{
          published_at: DateTime.t(),
          title: Validations.title(),
          # should we call this field id? or identity?
          uuid: Ecto.UUID.t()
        }

  defstruct [
    :published_at,
    :title,
    :uuid
  ]

  # TODO: We might want to make a more explcit `new/1` constructor so that we can enforce turncation of published at at the command level since that is the max resolution we are insterested in storing.
end
