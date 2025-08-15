import Config

config :connect_four,
  garnish: [
    system_dir: to_charlist("ssh_keys"),
    ssh_cli: {Garnish, app: C4.Tui},
    no_auth_needed: true
  ],
  ssh_port: String.to_integer(System.get_env("SSH_PORT", "2222")),
  ssh_host: {0, 0, 0, 0},
  ssh: System.get_env("SSH") != "false"
