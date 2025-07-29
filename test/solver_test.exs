defmodule C4.SolverTest do
  use ExUnit.Case
  doctest C4.Heuristic

  alias C4.Board
  alias C4.Heuristic
  alias C4.Solver
  import C4.Board

  describe "minimax/2" do
    test "identifies horizontal winning move" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y|y|y| | | | |
                /

      move = Solver.minimax(board, :yellow)
      assert move.position == {4, 1}
    end

    test "identifies vertical winning move" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y| | | | | | |
                |y| | | | | | |
                |y|y|y| | | | |
                /

      Process.put(:debug, true)
      # Process.put(:move, {4, 1, :yellow})

      move = Solver.minimax(board, :yellow, 2)
      assert move.position in [{4, 1}, {1, 4}]
    end

  end
end
