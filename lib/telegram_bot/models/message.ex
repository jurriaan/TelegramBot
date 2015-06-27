defmodule TelegramBot.Models.Message do
  alias TelegramBot.Models
  use Models.BaseModel

  defstruct message_id: nil, from: nil, date: nil, chat: nil, text: nil, sticker: nil

  map :from, Models.User
  map :chat, %{"title" => _}, Models.GroupChat
  map :chat, Models.User
  map :sticker, Models.Sticker
end
