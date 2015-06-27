defmodule TelegramBot.Models.Sticker do
  use TelegramBot.Models.BaseModel

  defstruct file_id: nil, width: nil, height: nil, thumb: nil, file_size: nil
end
