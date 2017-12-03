defmodule Formex.BuilderType.Ecto do
  @moduledoc false
  defstruct [:form]
end

defimpl Formex.BuilderProtocol, for: Formex.BuilderType.Ecto do
  alias Formex.Form
  alias Formex.Field
  alias Formex.FormNested
  alias Formex.FormCollection
  require Ecto.Query

  @repo Application.get_env(:formex, :repo)

  @spec create_form(Map.t) :: Map.t
  def create_form(args) do
    form = args.form.type.build_form(args.form)

    method = if form.struct.id, do: :put, else: :post

    form = form
    |> Map.put(:struct, preload_assocs(form))
    |> Map.put(:method, method)
    |> Form.finish_creating

    # form = form
    # |> Map.put(:data,   Keyword.put(form.data, :original_struct, form.struct))
    # |> Map.put(:struct, copy_preloads_to_struct(form))

    Map.put(args, :form, form)
  end

  @spec create_struct_info(Map.t) :: Map.t
  def create_struct_info(args) do
    form   = args.form
    struct = struct(form.struct_module)

    struct_info = struct
    |> Map.from_struct
    |> Enum.filter(&(elem(&1, 0) !== :__meta__))
    |> Enum.map(fn {k, _v} ->
      v = case get_assoc_or_embed(form, k) do
        %{cardinality: :many, related: module} ->
          {:collection, module}

        %{cardinality: :one, related: module} ->
          {:nested, module}

        _ -> :any
      end

      {k, v}
    end)

    form = Map.put(form, :struct_info, struct_info)
    Map.put(args, :form, form)
  end

  #

  defp preload_assocs(form) do
    # TODO - creating a new struct for nested when it is nil,
    # or handle that empty form and do not displaying it

    form.items
    |> Enum.filter(fn item ->
      case item do
        %FormNested{}     -> true
        %FormCollection{} -> true
        %Field{}          -> item.type == :multiple_select
        _                 -> false
      end
    end)
    |> Enum.reduce(form.struct, fn item, struct ->

      if is_assoc(form, item.name) do
        queryable = struct.__struct__.__schema__(:association, item.name).queryable

        struct
        |> @repo.preload([
          {item.name, Ecto.Query.from(e in queryable, order_by: e.id)}
        ])
      else
        struct
      end
    end)
  end

  # written for 0.1.5 and never used. maybe it will be useful some day
  # defp copy_preloads_to_struct(form) do
  #   struct = form.items
  #   |> Enum.filter(fn item ->
  #     case item do
  #       %FormNested{}     -> true
  #       %FormCollection{} -> true
  #       _                 -> false
  #     end
  #   end)
  #   |> Enum.reduce(form.struct, fn item, struct ->

  #     if is_assoc(form, item.name) do
  #       {key, val} = case item do
  #         %FormNested{} ->
  #           {item.name, copy_preloads_to_struct(item.form)}

  #         %FormCollection{} ->
  #           {item.name, Enum.map(item.forms, fn nested ->
  #             copy_preloads_to_struct(nested.form)
  #           end)}
  #       end

  #       Map.put(struct, key, val)
  #     else
  #       struct
  #     end

  #   end)
  # end

  @doc false
  @spec get_assoc_or_embed(form :: Form.t, name :: Atom.t) :: any
  defp get_assoc_or_embed(form, name) do
    if is_assoc(form, name) do
      form.struct_module.__schema__(:association, name)
    else
      form.struct_module.__schema__(:embed, name)
    end
  end

  @doc false
  @spec is_assoc(form :: Form.t, name :: Atom.t) :: boolean
  defp is_assoc(form, name) do
    form.struct_module.__schema__(:association, name) != nil
  end
end
