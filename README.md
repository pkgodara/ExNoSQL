# ExNoSQL
Simple NoSQL Database using file in Elixir.
Can `Insert`, `Select`, `Delete` documents.
Updating records not allowed.

## Interact
Checkout to this directory, and run `iex -S mix` to open interactive shell.

Commands - 

```
cd ex_nosql
mix deps.get
iex -S mix
```

Run `direnv allow` to load env variables

## Examples

### Create record
Command - 
```
ExNoSQL.insert %{"key" => "value", "key-i" => 1, "key-d" => 1.1}
```
Output -
```
%{
  "_id" => "3af27707-6169-4455-b344-9f7d8e20dcb2",
  "key" => "value",
  "key-d" => 1.1,
  "key-i" => 1
}
```

### Select * records
Select All Command - 
```
ExNoSQL.select(%{})
```
output - 
```
[
  %{
    "_id" => "3af27707-6169-4455-b344-9f7d8e20dcb2",
    "key" => "value",
    "key-d" => 1.1,
    "key-i" => 1
  },
  %{"_id" => "4672c613-84e6-48d6-98f9-94ad151ef274", "k" => 2},
  %{"_id" => "cb458566-66af-4378-a5c6-ec2174827ebe", "k" => 2, "k1" => 1},
  %{"_id" => "e85d0023-9a5d-4459-ab87-569cc386f31c", "k" => 3}
]
```

Select * based on given key-values
```
ExNoSQL.select(%{"key" => "value"})
```
or
```
ExNoSQL.select(%{"key" => "value", "key-d" => 1.1})
```

output - 
```
[
  %{
    "_id" => "3af27707-6169-4455-b344-9f7d8e20dcb2",
    "key" => "value",
    "key-d" => 1.1,
    "key-i" => 1
  }
]
```

Select specific [keys] -
```
ExNoSQL.select(%{"key" => "value"}, ["key"])
```
output - 
```
[%{"_id" => "3af27707-6169-4455-b344-9f7d8e20dcb2", "key" => "value"}]
```

### Delete matching records
```
ExNoSQL.delete(%{"key" => "value"})
```

## Installation

```elixir
def deps do
  [
    {:ex_nosql, "~> 0.1.0"}
  ]
end
```
