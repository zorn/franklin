defmodule FranklinWeb.NotFoundError do
  defexception message: "The page or resource being requested could not be found.",
               plug_status: 404
end
