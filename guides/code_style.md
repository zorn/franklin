# Code Style

Where ever possible we prefer to enforce and auto suggest this project's code style preferences via tools like [credo] or the default Elixir `mix format`.

[credo]: https://github.com/rrrene/credo

## Open Concerns

Not sure I like how I've currently ended up with a bunch of files named `post.ex` in different folders. Might try to flatten some of that in time. 

## Prefer Alphabetical Attribute Sorting

Whenever constructing a struct value inline or defining the attributes of a schema, sort the keys in an alphabetical order.

Instead of this:

```elixir
%ArticleCreated{
    uuid: create.uuid,
    title: create.title,
    published_at: create.published_at
}
```

We prefer this:


```elixir
%ArticleCreated{
    published_at: create.published_at,
    title: create.title,
    uuid: create.uuid
}
```

Acknowledging that `uuid` being the identity value might be more meaningful at the top or the `title` value having some conceptual precedence over `published_at` -- on this project we prefer the consistency and later readability of an alphabetically sorted key list. 

This is not something that is currently enforced by credo but something that is strived for.
