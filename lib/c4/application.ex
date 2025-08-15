defmodule C4.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # garnish config
    ssh_port = Application.get_env(:connect_four, :ssh_port)
    ssh_host = Application.get_env(:connect_four, :ssh_host)
    ssh_opts = Application.get_env(:connect_four, :garnish)
    # start the ssh daemon
    {:ok, ref} = :ssh.daemon(ssh_host, ssh_port, ssh_opts)

    children = [
      {Registry, [keys: :duplicate, name: C4.Sessions]}
    ]

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
