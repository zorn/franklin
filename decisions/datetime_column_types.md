# Database DateTime Column Types

We made some non-default choices regarding the database column types used for datetime values.

**Status:** Complete (March 7, 2023)

## Problem Context

While generally poor form, this decision documents two distinct problems and two independent code edits (happening in quick succession) that provided solutions. 

First, during development, we were [reminded][1] that the main reason Ecto chooses `NaiveDateTime` for its default implementation of `timestamps()` is for compatibility reasons. For a modern Elixir project using Postgres, it is more expressive to use the `:utc_datetime` format for those timestamps to end up with `DateTime` values over `NaiveDateTime` values in the Elixir code, which better codifies the UTC nature of these values.

Second, as we continued to expand our event-sourced code and tests, we observed a common code pattern where we were truncating DateTime values to the second. This would usually pop up as we would use `DateTime.utc_now/1` to generate a `published_at` value and then attempt to use it inside a `CreateArticle` command test case. As the command generated events, and then those events persisted, a projection of the `DateTime` value was being truncated in the database because we had [initially][2] created the `published_at` column using `:utc_datetime`, lacking the fidelity of microseconds. Later in the test, we would try to assert the value from the database projection vs. the value we generated in memory, but without the microseconds, it did not match.

[1]: https://code.krister.ee/new-project-commands-for-new-elixir-phoenix-liveview-project/
[2]: https://github.com/zorn/franklin/blob/2c84a41487d1a80416673124de8b32b92a789657/priv/repo/migrations/20221115214803_create_articles.exs#L9

## Decision Made

For the first problem, during [pull request #171](https://github.com/zorn/franklin/pull/171), we updated our database and Ecto schemas to use a `:utc_datetime` column type. This resulted in a more consistent value type of the `DateTime` now for `inserted_at` and `updated_at` fields in addition to the previous `published_at` field.

For the second problem, we again edited those migrations during [pull request #172](https://github.com/zorn/franklin/pull/172), now changing the column type from `:utc_datetime` to `:utc_datetime_usec`. While we do not have a business need for microsecond precision, the event tooling provided by the Commanded and related projection libraries prefers microsecond precision. Moving forward, it feels easier to use microsecond precision inside Franklin's domain contexts and be consistent across the board. Overall, this change resulted in more straightforward code.

## Known Consequences & Tradeoffs Considered

* We felt confident editing historical migration files because the app is not yet deployed.
* Adding this extra data has a database space cost. For the constraints of this simple app, it will be negligible, but if this were a more significant application, we would have to consider the size increase for N number of projected rows,
