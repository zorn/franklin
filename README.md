# Franklin

A custom blog system written in Elixir and Phoenix to power mikezornek.com.

## Running Locally

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Reset Local Databases.

As a CQRS / Event Source codebase we have two databases, the event store database and the projections database. If you want to reset these use the following command:

    $ mix event_store.drop; mix event_store.create; mix event_store.init; mix ecto.reset

    $ MIX_ENV=test mix event_store.drop; MIX_ENV=test mix event_store.create; MIX_ENV=test mix event_store.init; MIX_ENV=test mix ecto.reset


## Browsing Product Documentation 

This project uses `ex_doc` to help render inline module/function documentation as well as project guides.

To render the current docs and open the root index page run:

```
$ mix docs; open doc/index.html
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
