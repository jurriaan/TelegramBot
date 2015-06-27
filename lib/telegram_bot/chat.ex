defmodule TelegramBot.Chat do
  alias TelegramBot.Models.Update
  alias TelegramBot.Models.Message
  alias TelegramBot.API

  use GenServer
  require Logger

  defmodule State, do: defstruct chat: nil

  @vsn "0"

  def start_link(chat_id) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, chat_id)
  end

  def update(chat, %Update{} = update) do
    GenServer.cast chat, {:update, update}
  end

  def get_state(chat), do: GenServer.call(chat, :get_state)

  #### GenServer implementation

  def init(chat_id), do: {:ok, %State{chat: %{id: chat_id}}}

  def handle_cast({:update, %Update{} = update}, state) do
    Logger.debug inspect(update)
    state = %State{state | chat: update.message.chat}
    handle_message(update.message, state)
    {:noreply, state}
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_message(%Message{text: "/momo"}, %State{chat: chat}) do
    API.sendSticker(chat.id, sticker)
  end
  def handle_message(%Message{text: "/hello", from: user}, %State{chat: chat}) do
    API.sendMessage(chat.id, "Greetings, #{user.first_name}")
  end
  def handle_message(_,_), do: true

  defp sticker, do: Application.get_env(:telegram_bot, :sticker_id)
end
