defmodule UpdatesModelTest do
  alias TelegramBot.Models.Updates
  alias TelegramBot.Models.Update
  use ExUnit.Case, async: true

  test "returns nil when input is empty" do
    assert Updates.new(nil) == nil
    assert Updates.new([]) == nil
  end

  test "mapping" do
    input = [%{"update_id" => 1}, %{"update_id" => 2}]

    updates = Updates.new(input)
    assert updates.last_update_id == 2
    assert updates.updates == [%Update{update_id: 1}, %Update{update_id: 2}]
  end
end
