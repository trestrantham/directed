Directed
========

A distributed computation framework for Elixir.

**Note: The content below is an attempt at RDD (README-driven development) in
an effort to properly flesh out the ideas of this framework. Some (very) basic
functionality exists today while the rest is yet to come. Please feel free to
provide feedback via Issues or Pull Request.**

### Graphs

Computations are represented as a directed graph of nodes through which data
flows. Graphs provide a mapping of one or more Source, Vertex, and Sink and
defines the path data can take through a given computation. For instance, data
emitted from a Source can be consumed by multiple Vertices. And likewise, a
single Vertex can consume multiple Sources (or Vertices). Together, all
definitions of data flow make up the computational Graph.

The most basic example of a Graph contains one Source (`MyApp.UsersSource`),
optionally one Vertex (`Vertex.Sort`), and one Sink (`MyApp.UsersJSON`):

```elixir
defmodule UsersGraph do
  use Directed.Graph

  source :users,
    module: MyApp.UsersSource

  vertex :sort,
    module: Vertex.Sort,
    input: :users

  sink :output,
    module: MyApp.UsersJSON,
    input: :sort
end
```

### Sources

Sources are the inputs to your computation graph. Sources emit data to a Graph
where Vertices and/or Sinks consume data. You can define multiple sources per
Graph and each can accept a list of parameters.

For instance, you could define `MyApp.UsersSource` with the ability to accept
parameters in order to reuse the source within multiple contexts:

```elixir
defmodule MyApp.UsersSource do
  import Ecto.Query
  use Directed.Source

  def init(params) do
    {:ok, params}
  end

  def run(params) do
    query = from u in User,
          where: u.age > params[:age]
         select: u
    Repo.all(query)
  end
end
```

Once `run` has completed, its return value (all our database records in the
case) will be emitted one record at a time to `Vertex.Sort` as defined in the
Graph example above.

If you wanted to explicitly emit records you may call `Message.emit/2` manually.
This can be useful if you have a long running (or unbounded) Source function
and want to start processing records (downstream via a Vertex) as soon as they
are available.

```elixir
defmodule MyApp.ExplicitSource do
  use Directed.Source, emit: :explicit

  def run(_params, manager) do
    generator = Stream.repeatedly(fn -> :random.uniform end)

    # Pro tip: Don't do this
    Enum.each generator, fn(x) ->
      Message.emit(x, manager)
    end
  end
end
```

Note: Records (Messages) are sent as `GenEvent` events therefore the `manager`
above is a `GenEvent` manager.

### Vertices

Vertices are single computational units within a graph. They accept input data
from one or more input Sources (or Vertices) and output data to one or more
outputs.

Directed comes with some primitive predefined functions (like `Vertex.Sort`
above), but you can easily create your own:

```elixir
defmodule Uppercaser do
  use Directed.Vertex, mode: :transform

  def process(record) do
    record |> String.upcase
  end
end
```

A Vertex can operate in 1 of 3 modes:

- `transform` mode emits one output record for each input record it receives as
  the output of the `process` function.
- `aggregate` mode allows for accumulation of input records and can emit any
  number of output records per input record. Some examples of aggregates are
  deduping records, encoding (emitting less output records than input records),
  and decoding (emitting more output records than input records).
- `join` mode accepts two or more inputs and emits a single output of any
  number of output records per input record(s).

### Sinks

Sinks are the last node(s) of a directed graph and are where computation
terminates. A Sink accepts one input but does not emit records. Instead, a Sink
combines (or processes) all input records. Some examples of Sinks would be JSON
encoding the output of a Graph, inserting the Graph output to a database,
returning raw data back to the caller, or any combination thereof.

An example of a simple JSON encoder that encodes all records as a list might
look like:

```elixir
defmodule MyApp.UsersJSON do
  use Directed.Sink, mode: :aggregate
  use Jazz

  def process(record, records) do
    [to_string(record) | records]
  end

  def finish(records) do
    JSON.encode!(records)
  end
end
```

A Sink that inserts a record into a database for each input record might look
like:

```elixir
defmodule InsertUsers do
  use Directed.Sink
  use Ecto.Model

  def process(record) do
    user = %User{name: record[:name], age: record[:age]}
    Repo.insert(user)
  end
end
```

## The Future

Eventually, this will contain actual milestones, but for now consider the list
below a rough plan with random thoughts and (possibly) awesome ideas judiciously
mixed in.

### Parallelism

After working through everything outlined above, the plan is to introduce
parallelism for Vertices. It may be too use case specific to apply parallelism
to the Sources and/or Sinks but I think that would also be an interesting path
to explore.

Specific types of Vertices may require departitioned data, but most computations
(transforms, sorts, rollups/aggregations) can be partitioned by common keys that
would lend itself well to parallelism.

Once the logistics are ironed out, this should Just Work at any scale*. The
possibilities here are really exciting and are what drove me to start this
project in the first place.

### Distribution

The next step would be to provide ease of distribution (hey, it's in the
description) so that any of the Graph nodes above could be distributed across
many Elixir nodes. Some possibilities here are Source-specific nodes that house
a database or in-memory store that is available across multiple Graphs and/or
Vertices.

Or maybe you have some expensive computations and would like those specific
Vertices to run on a beefier box to mitigate potential bottlenecks.

### Records

Currently, Directed will emit whatever record it receives (or generates)
irrespective to format and/or struture. It requires all nodes to be well
coordinated (by the developer) with respects to data structure. In the future,
I would like to entertain the idea of (optionally) specifying input and/or
output record types (via structs) to both enforce structure and provide data
validation along the Graph.
