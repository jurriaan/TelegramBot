defmodule TelegramBot.Models.Update do
  use TelegramBot.Models.BaseModel

  map :message, TelegramBot.Models.Message

  defstruct update_id: nil, message: nil
end
