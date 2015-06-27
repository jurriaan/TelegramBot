defmodule TelegramBot.Models.BaseModel do
  @doc false
  defmacro __using__(_) do
    quote do
      import TelegramBot.Models.BaseModel
      @mappings %{}
      @before_compile TelegramBot.Models.BaseModel
    end
  end

  @doc false
  defmacro __before_compile__(_) do
    quote do
      def mapping(_, _), do: nil

      def new(nil), do: nil
      def new(value) do
        struct = __MODULE__.__struct__
        Enum.into(Map.from_struct(struct), %{}, fn {key, default} ->
          value = Map.get(value, Atom.to_string(key), default)
          model = apply(__MODULE__, :mapping, [key, value])
          if model, do: value = model.new(value)
          {key, value}
        end)
        |> Map.put(:__struct__, struct.__struct__)
      end
    end
  end

  defmacro map(key, value \\ nil, model) do
    unless value, do: value = quote do: _
    quote bind_quoted: [key: key,
                        model: model,
                        value: Macro.escape(value)] do
      def mapping(unquote(key), unquote(value)), do: unquote(model)
    end
  end
end
