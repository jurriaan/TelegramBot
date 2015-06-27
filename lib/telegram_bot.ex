defmodule TelegramBot do
  use Application
  require Logger
  @task_supervisor_name TelegramBot.PollUpdatesTask.Supervisor
  @task_name TelegramBot.PollUpdatesTask
  @manager_name TelegramBot.EventManager
  @registry_name TelegramBot.ChatRegistry
  @chat_supervisor_name TelegramBot.Chat.Supervisor

  def start(_type, []) do
    import Supervisor.Spec

    children = [
      worker(GenEvent, [[name: @manager_name]]),
      supervisor(Task.Supervisor, [[name: @task_supervisor_name, restart: :permanent]]),
      supervisor(TelegramBot.Chat.Supervisor, [[name: @chat_supervisor_name]]),
      worker(TelegramBot.ChatRegistry, [@manager_name, @chat_supervisor_name, [name: @registry_name]])
    ]
    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]

    Logger.info "Starting main Supervisor.."
    {:ok, spid} = Supervisor.start_link(children, opts)

    Logger.info "Polling for updates.."
    Task.Supervisor.start_child(@task_supervisor_name, @task_name, :poll, [@registry_name])

    {:ok, spid}
  end
end
