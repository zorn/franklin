alias Franklin.Articles

# Never pry for `Kernel.dbg()`.
Application.put_env(:elixir, :dbg_callback, {Macro, :dbg, []})

# Alternative: You can also launch the app with `--no-pry`.
# $ iex --no-pry -S mix phx.server
