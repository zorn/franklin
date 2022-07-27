defmodule Franklin.CommandedApplication do
  use Commanded.Application, otp_app: :franklin

  router(Franklin.Router)
end
