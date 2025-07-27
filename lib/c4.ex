defmodule C4 do
  @moduledoc false

  alias C4.Board
  alias C4.Solver
  import C4.Board

  defmacro __using__(_opts) do
    quote do
    end
  end

  def test do
    board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | |y|y|y| | | |
              /

    Board.playable_positions(board)
    |> Enum.each(fn position ->
      score =
        board
        |> Board.put(position, :yellow)
        |> C4.Heuristic.score_board(:yellow)

      IO.inspect {score, position}
    end)

    # # C4.Constants.wins()
    # # |> Enum.map(fn win ->
    # win = [{1, 1}, {2, 1}, {3, 1}, {4, 1}]
    # C4.Heuristic.rate_series(board, win, :yellow)
    # # end)
  end
end
