defmodule ExNoSQL do
  @moduledoc """
  Documentation for `ExNoSQL`.
  """

  @doc """
  Insert a given record, _id is inserted implicitly
  """
  def insert(%{} = empty_map) when is_map(empty_map) and map_size(empty_map) == 0,
    do: {:error, :invalid_data}

  def insert(doc) when is_map(doc) do
    record_id = UUID.uuid4()
    doc = Map.put(doc, "_id", record_id)

    with {:ok, encoded_doc} <- Jason.encode(doc),
         :ok <- File.write(doc_path(record_id), encoded_doc) do
      get(record_id)
    end
  end

  def insert(_doc), do: {:error, :invalid_input}

  @doc """
  Selects all the records matching given params
  Returns given keys (if provided)
  """
  def select(params, keys \\ []) when is_map(params) do
    select_keys = Enum.map(keys, fn key -> to_string(key) end)

    params
    |> normalize_map()
    |> get_matching_records()
    |> Enum.map(fn doc_path ->
      filter_keys(get_by_path(doc_path), select_keys)
    end)
  end

  @doc """
  Deletes all matching records
  """
  def delete(params) when is_map(params) do
    params
    |> normalize_map()
    |> get_matching_records()
    |> Enum.each(fn doc_path ->
      File.rm!(doc_path)
    end)
  end

  @doc """
  Gets a record by ID
  """
  def get(record_id) when is_binary(record_id) do
    with doc_path <- doc_path(record_id),
         {:ok, doc} <- File.read(doc_path) do
      Jason.decode!(doc)
    else
      {:error, :enoent} -> {:error, :not_found}
      {:error, _} -> {:error, "error getting record"}
    end
  end

  ## Priv functions

  defp db_path do
    System.get_env("DB_PATH", "./db")
    |> Path.expand()
  end

  defp doc_path(id) do
    db_path() <> "/#{id}.json"
  end

  defp all_doc_paths() do
    Path.wildcard(db_path() <> "/*.json")
  end

  defp get_by_path(doc_path) do
    doc_path
    |> File.read!()
    |> Jason.decode!()
  end

  defp normalize_map(in_map) do
    in_map
    |> Jason.encode!()
    |> Jason.decode!()
  end

  defp get_matching_records(query) do
    all_doc_paths()
    |> Enum.filter(fn doc_path ->
      is_match?(query, get_by_path(doc_path))
    end)
  end

  # Returns true if child_map is subset of parent_map, i.e. [parent_map contains all the child_map properties]
  defp is_match?(child_map, parent_map) when is_map(child_map) and is_map(parent_map) do
    child_map_set = child_map |> Map.to_list() |> MapSet.new()
    parent_map_set = parent_map |> Map.to_list() |> MapSet.new()

    MapSet.subset?(child_map_set, parent_map_set)
  end

  defp filter_keys(doc, select_keys) do
    case select_keys do
      [] -> doc
      _ -> Map.take(doc, ["_id"] ++ select_keys)
    end
  end
end
