defmodule C4.SolverTest do
  use ExUnit.Case
  doctest C4.Heuristic

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

      move = Solver.minimax(board, :yellow)
      assert move.position in [{4, 1}, {1, 4}]
    end

    test "identifies vertical blocking move" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |r| | | | | | |
                |r| | | | | | |
                |r| | | | | | |
                /

      move = Solver.minimax(board, :yellow)
      assert move.position == {1, 4}
    end

    test "identifies best move" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |r| |y| | | | |
                |r| |y| | | | |
                /

      move = Solver.minimax(board, :yellow)
      assert move.position == {3, 3}
    end

    test "identifies best move for win" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | |y| | | | |
                |r| |y| | | | |
                |r| |y| | | | |
                /

      move = Solver.minimax(board, :yellow)
      assert move.position == {3, 4}
    end
  end
end
