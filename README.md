# Tradie

Parallel task execution with retries, global timeout, and "best effort"
execution of work.

## Features

Tradie came out of a proof of concept spike to optimize requests to a third
party service. The best way to do this is to split the main query up into a
number of subqueries, execute them in parallel, and then combine the results.

With `Task.async/1` and `Task.await/2`, the happy case is easy in plain Elixir:

```elixir
subqueries
|> Enum.map(&Task.async(fn -> do_3rd_party_query(&1) end))
|> Enum.map(&Task.await/1)
# [result1, result2, result3...]
```

However it gets more complicated once you start to think about timeout and error
handling.

We want "best effort" results: Set a global timeout for the entire operation,
and return whatever has finished to the user. If any subqueries didn't complete,
that's OK. Just return what did. If any subqueries encountered errors, retry
them up until the timeout. If they never complete successfully, that's OK.

With Tradie you can do this:

```elixir
subqueries
|> Enum.map(&(fn -> do_3rd_party-query(&1) end))
|> Tradie.async
|> Tradie.await(5000) # 5 second timeout across ALL queries
# [{:ok, result1}, {:error, :timed_out}, {:ok, result2}...]
```

This is ideal for use cases like search engine queries where in the case of
intermittent errors it is better to display _some_ results to the user than to
fail the entire operation and display an error response to the user.

## Development Status

Very alpha. Based on a spike to test an idea. Not used in production anywhere.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add Tradie to your list of dependencies in `mix.exs`:

        def deps do
          [{:tradie, "~> 0.0.1"}]
        end

  2. Ensure Tradie is started before your application:

        def application do
          [applications: [:tradie]]
        end

## Maintainers

[@madlep](https://github.com/madlep)

## License

[MIT license](https://github.com/madlep/tradie/blob/master/LICENSE.txt)
