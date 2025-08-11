defmodule C4.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [
      system_dir:
        :code.priv_dir(:connect_four)
        |> Path.join(".keys")
        |> Path.expand()
        |> to_charlist,
      ssh_cli: {Garnish, app: C4.Tui},
      # ssh_cli: {Garnish, app: Counter},
      no_auth_needed: true
    ]

    {:ok, ref} = :ssh.daemon({127, 0, 0, 1}, 2222, opts)

    children = []

    opts = [strategy: :one_for_one, name: C4.Supervisor]

    with {:ok, pid} <- Supervisor.start_link(children, opts) do
      {:ok, pid, ref}
    end
  end

  @impl true
  def stop(ref) do
    :ssh.stop_daemon(ref)
  end
end
