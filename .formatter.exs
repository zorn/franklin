[
  import_deps: [:ecto, :phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "priv/*/seeds.exs",
    "{config,lib,storybook,test}/**/*.{heex,ex,exs}"
  ],
  subdirectories: ["priv/*/migrations"]
]
