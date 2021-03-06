defmodule TelegramBot.API do
  use HTTPoison.Base

  @post_headers %{"Content-type" => "application/x-www-form-urlencoded"}

  def process_url(url) do
    "https://api.telegram.org/bot" <> token <> "/" <> url
  end

  defp token, do: Application.get_env(:telegram_bot, :bot_token)

  def get_updates(offset \\ nil, limit \\ 100, timeout \\ 30) do
    {:ok, response} = post("getUpdates", {:form, [offset: offset, limit: limit, timeout: timeout]}, @post_headers)
    %{"ok" => true, "result" => result} = response.body
    TelegramBot.Models.Updates.new(result)
  end

  def send_message(chat_id, text) do
    post("sendMessage", {:form, [chat_id: chat_id, text: text]}, @post_headers)
  end

  def send_sticker(chat_id, sticker) do
    post("sendSticker", {:form, [chat_id: chat_id, sticker: sticker]}, @post_headers)
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end
end
