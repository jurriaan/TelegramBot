defmodule TelegramBot.ChatRegistry do
  alias TelegramBot.Models.Updates
  alias TelegramBot.Models.Update
  alias TelegramBot.Chat
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(event_manager, chats, opts \\ []) do
    GenServer.start_link(__MODULE__, {event_manager, chats}, opts)
  end

  def chat(registry, chat_id) do
    GenServer.call(registry, {:lookup, chat_id})
  end

  def update(registry, %Update{} = update) do
    GenServer.cast(registry, {:update, update})
  end

  def broadcast_updates(registry, %Updates{updates: updates}) do
    updates |> Enum.map(fn (update) -> update(registry, update) end)
  end

  ## Server callbacks

  def init({events, chats}) do
    ids = HashDict.new
    refs  = HashDict.new
    {:ok, %{ids: ids, refs: refs, events: events, chats: chats}}
  end

  def handle_call({:lookup, id}, _from, state) do
    state = create_unless_exists(id, state)
    {:reply, HashDict.fetch(state.ids, id), state}
  end

  def handle_cast({:update, %Update{} = update}, state) do
    id = update.message.chat.id
    state = create_unless_exists(id, state)
    {:ok, pid}= HashDict.fetch(state.ids, id)
    Chat.update(pid, update)
    {:noreply, state}
  end

  def create_unless_exists(id, state) do
    if HashDict.get(state.ids, id) do
      state
    else
      {:ok, pid} = Chat.Supervisor.start_chat(state.chats, id)

      ref = Process.monitor(pid)
      refs = HashDict.put(state.refs, ref, id)
      ids = HashDict.put(state.ids, id, pid)

      GenEvent.sync_notify(state.events, {:create, id, pid})
      %{state | ids: ids, refs: refs}
    end
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    {id, refs} = HashDict.pop(state.refs, ref)
    ids = HashDict.delete(state.ids, id)

    GenEvent.sync_notify(state.events, {:exit, id, pid})
    {:noreply, %{state | ids: ids, refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
