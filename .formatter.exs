# Used by "mix format"
[
  import_deps: [:phoenix, :phoenix_live_view, :ecto, :ecto_sql],
  subdirectories: ["priv/*/migrations"],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter]
]
