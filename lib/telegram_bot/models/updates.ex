defmodule TelegramBot.Models.Updates do
  defstruct last_update_id: nil, updates: nil

  def new(nil), do: nil
  def new([]), do: nil
  def new(updates) do
    updates = updates |> Enum.map(&(TelegramBot.Models.Update.new(&1)))
    last_update = updates |> List.last
    %__MODULE__{updates: updates, last_update_id: last_update.update_id}
  end
end
