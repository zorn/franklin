# Context Accessors

The following patterns are preferred when building a domain context and providing access functions.

## 1. Provide a `fetch_noun/1` function.

This `fetch_noun/1` function should have a return type similar to `Map.fetch/2` where the return type is `{:ok, Noun.t()} || {:error, :noun_not_found}`.

We prefer `:noun_not_found` over the more terse `:not_found` since it can be expected that this error value will pop up in various stacktraces, and `:not_found` on its own is not that helpful to understand the origin of the error value.

If you are only writing a single accessor function, this should be the pattern to use, as we want to encourage this error value over `nil` at the call sites.

## 2. Provide a `fetch_noun!/1` function.

Some call sites may prefer the simplicity of accessing the raw entity value as the return type in favor of the `:ok` tuple pattern. We mostly expect this in tests, scripts, or other places where the resource's existence is assumed, so raising will be uncommon. For those call sites, we can offer `fetch_noun!/1`, which will return the entity or raise an error like `App.NotFoundError` (or `Ecto.NoResultsError` if you are ok leaking Ecto as an implementation detail). Raising errors as a common form of logic flow is discouraged in Elixir, so use this pattern with caution.

## 3. Provide a `get_noun/2` function.

If the two access functions above can not fully meet your needs, you can consider a third option of `get_noun/2`. Similarly to our `fetch` functions, we want to mirror the behavior of the `Map` module, specifically `Map.get/3`. In this case, a default value is returned when an entity is not found. That default is, by default, `nil` but can be customized in the function arguments.

Because `nil` as a default value can cause harder to debug stacktraces, this pattern should be avoided, but allowances can be made when the tradeoffs are acceptable to the developer and the team at large.
