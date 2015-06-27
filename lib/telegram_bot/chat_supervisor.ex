defmodule TelegramBot.Chat.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def start_chat(supervisor, chat_id) do
    Supervisor.start_child(supervisor, [chat_id])
  end

  def init(:ok) do
    children = [
      worker(TelegramBot.Chat, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
