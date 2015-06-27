defmodule TelegramBot.Models.User do
  use TelegramBot.Models.BaseModel

  defstruct id: nil, first_name: nil, last_name: nil, username: nil
end
