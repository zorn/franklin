# Franklin

Franklin is a custom blog application that will (in the future) power MikeZornek.com.

Franklin is written in [Elixir], [Phoenix], and [LiveView] and is an intentionally over-engineered blog application. It uses an event-sourced / CQRS core (via [commanded]) along side modern component-based UI presentation. It aims to make even the simple things overly complex in the spirit of personal education towards these architecture decisions.

[Elixir]: https://elixir-lang.org/
[Phoenix]: https://www.phoenixframework.org/
[LiveView]: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
[commanded]: https://github.com/commanded/commanded

Franklin currently remains in a very hacky state and many things are incomplete or only partial implemented. A rough timeline of things to come:

## Current Goal: Technical Preview One (January 16th)

* Basic article publishing with title, markdown-formatted body, and basic page metadata.
* Basic frontend design layout.
* Basic admin design layout.
* Stretch: Some helpful GitHub Action CI testing.

## Next Goals: Technical Preview Two

* The ability to host static pages at root urls.
* An RSS feed for recent content.
* The ability to customize page slugs.
* The ability to upload images and other assets to be used by blog articles.
* TBD

## Technical Preview Three

* The ability to import the current MikeZornek.com blog archive.
* TBD

## Running Locally

To get the project dependencies and setup the two local databases (one is an event store, the other is the typical Ecto repo storing event projections) use:

```
$ mix setup
```

To launch the Phoenix server (which will host the site at <http://localhost:4000>) attached to an iex session use:

```
$ iex -S mix phx.server
```

If you ever want to reset the two local databases, include local dev seeds, use:

```
$ mix reset_databases
```

To run the full test suite use:

```
$ mix test
```

To render the current docs and open the root index page run:

```
$ mix docs; open doc/index.html
```

***

For more info on these mix commands see the `aliases` private function inside of [`mix.exs`](https://github.com/zorn/franklin/blob/main/mix.exs).
