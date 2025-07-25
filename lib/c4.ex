defmodule C4 do
  @moduledoc false

  alias C4.Board
  alias C4.Solver

  defmacro __using__(_opts) do
    quote do
    end
  end

  def test do
    1..42
    |> Enum.reduce(Board.new(), fn n, board ->
      player = if rem(n, 2) == 0, do: :red, else: :yellow
      color = if player == :red, do: &IO.ANSI.red/0, else: &IO.ANSI.yellow/0

      IO.puts(color.() <> "##############################################" <> IO.ANSI.reset())
      IO.puts("Before")
      Board.pretty_print(board)

      # yellow starts
      move = Solver.minimax(board, player)

      board = Board.put(board, move.position, player)
      IO.puts("After")
      Board.pretty_print(board)
    end)
  end
end
