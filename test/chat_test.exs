defmodule ChatTest do
  use ExUnit.Case, async: true
  import :meck
  alias TelegramBot.Models
  alias TelegramBot.Chat
  alias TelegramBot.API

  setup_all do
    new(API)
    on_exit fn -> unload end
    :ok
  end

  setup do
    {:ok, pid} = Chat.start_link(42)
    {:ok, %{chat: pid}}
  end

  test "it updates the chat state with the latest information", %{chat: chat} do
    update = %Models.Update{message: %Models.Message{chat: %Models.GroupChat{id: 10, title: "Title"}}}
    GenServer.cast(chat, {:update, update})

    assert Chat.get_state(chat) == %Chat.State{chat: %Models.GroupChat{id: 10, title: "Title"}}
  end

  test "it responds to a /hello message", %{chat: chat} do
    update = %Models.Update{message: %Models.Message{chat: %Models.GroupChat{id: 10, title: "Title"}, text: "/hello", from: %Models.User{first_name: "Test"}}}
    expect(API, :sendMessage, fn (10, "Greetings, Test") -> %{} end)
    GenServer.cast(chat, {:update, update})
    assert validate(API)
    assert Chat.get_state(chat) == %Chat.State{chat: %Models.GroupChat{id: 10, title: "Title"}}
  end
end
