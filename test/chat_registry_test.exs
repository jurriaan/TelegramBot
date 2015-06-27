defmodule ChatRegistryTest do
  use ExUnit.Case, async: true
  alias TelegramBot.ChatRegistry
  alias TelegramBot.Chat
  alias TelegramBot.Models

  defmodule Forwarder do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end

  setup do
    {:ok, sup} = Chat.Supervisor.start_link
    {:ok, manager} = GenEvent.start_link
    {:ok, registry} = ChatRegistry.start_link(manager, sup)

    GenEvent.add_mon_handler(manager, Forwarder, self())
    {:ok, registry: registry}
  end

  test "Creates and remembers new Chats", %{registry: registry} do
    sensor = ChatRegistry.chat(registry, 42)
    {:ok, chat} = ChatRegistry.chat(registry, 42)
    assert_receive {:create, 42, ^chat}

    assert sensor == ChatRegistry.chat(registry, 42)
    {:ok, chat} = ChatRegistry.chat(registry, 42)
    refute_receive {:create, 42, ^chat}
  end

  test "Sends events on create and crash", %{registry: registry} do
    {:ok, chat} = ChatRegistry.chat(registry, 42)
    assert_receive {:create, 42, ^chat}

    Agent.stop(chat)
    assert_receive {:exit, 42, ^chat}
  end

  test "removes Chat on crash", %{registry: registry} do
    {:ok, chat} = ChatRegistry.chat(registry, 10)

    # Kill the bucket and wait for the notification
    Process.exit(chat, :shutdown)
    assert_receive {:exit, 10, ^chat}
    assert ChatRegistry.chat(registry, 10) != chat
  end

  test "Updates Chat", %{registry: registry} do
    update = %Models.Update{message: %Models.Message{chat: %Models.GroupChat{id: 11, title: "a"}}}

    ChatRegistry.update(registry, update)

    {:ok, pid} = ChatRegistry.chat(registry, 11)
    assert Chat.get_state(pid) == %Chat.State{chat: %Models.GroupChat{id: 11, title: "a"}}
  end

  test "broadcasts updates to Chats", %{registry: registry} do
    updates = %Models.Updates{updates: [
      %Models.Update{message: %Models.Message{chat: %Models.GroupChat{id: 1, title: "a"}}},
      %Models.Update{message: %Models.Message{chat: %Models.GroupChat{id: 2, title: "b"}}},
      %Models.Update{message: %Models.Message{chat: %Models.GroupChat{id: 3, title: "c"}}}
    ]}

    ChatRegistry.broadcast_updates(registry, updates)

    {:ok, pid} = ChatRegistry.chat(registry, 1)
    assert Chat.get_state(pid) == %Chat.State{chat: %Models.GroupChat{id: 1, title: "a"}}
    {:ok, pid} = ChatRegistry.chat(registry, 2)
    assert Chat.get_state(pid) == %Chat.State{chat: %Models.GroupChat{id: 2, title: "b"}}
    {:ok, pid} = ChatRegistry.chat(registry, 3)
    assert Chat.get_state(pid) == %Chat.State{chat: %Models.GroupChat{id: 3, title: "c"}}
  end
end
