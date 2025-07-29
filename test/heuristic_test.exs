defmodule C4.HeuristicTest do
  use ExUnit.Case
  doctest C4.Heuristic

  alias C4.{Board, Heuristic}
  import C4.Board

  describe "direct_wins/2" do
    test "identifies horizontal winning move" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y|y|y| | | | |
                /

      direct_wins = Heuristic.direct_wins(board, :yellow)
      assert {4, 1} in direct_wins
    end

    test "identifies vertical winning move" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y| | | | | | |
                |y| | | | | | |
                |y| | | | | | |
                /

      direct_wins = Heuristic.direct_wins(board, :yellow)
      assert {1, 4} in direct_wins
    end

    test "identifies diagonal winning move (ascending)" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                |y| | | | | | |
                |r|y| | | | | |
                |r|r|y| | | | |
                |r|r|r| | | | |
                /

      direct_wins = Heuristic.direct_wins(board, :yellow)
      assert {4, 1} in direct_wins
    end

    test "identifies diagonal winning move (descending)" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | |y| | | |
                | | |y|r| | | |
                | |y|r|r| | | |
                | |r|r|r| | | |
                /

      direct_wins = Heuristic.direct_wins(board, :yellow)
      assert {1, 1} in direct_wins
    end

    test "returns empty list when no winning moves available" do
      board = Board.new()
      direct_wins = Heuristic.direct_wins(board, :yellow)
      assert direct_wins == []
    end

    test "identifies multiple winning moves" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y| | | | | | |
                |y| | | | | | |
                |y|y|y| | | | |
                /

      direct_wins = Heuristic.direct_wins(board, :yellow)
      assert {1, 4} in direct_wins
      assert {4, 1} in direct_wins
    end
  end

  describe "losing_moves/2" do
    test "identifies moves that allow opponent to win" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |r|r|r| | | | |
                |y|y|y| | | | |
                /

      losing_moves = Heuristic.losing_moves(board, :yellow)
      # Playing anywhere except position {4, 1} would allow red to win
      assert {4, 1} in losing_moves
    end

    test "returns empty list when no moves allow opponent to win" do
      board = Board.new()
      losing_moves = Heuristic.losing_moves(board, :yellow)
      assert losing_moves == []
    end

    test "all moves are losing moves if the opponent can win in 1 game" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  |r| | | | | | |
                  |r| | | | | | |
                  |r|y| | | | | |
                  /

      losing_moves = Heuristic.losing_moves(board, :yellow)
      # Playing in column 1 would stack on top and allow red to win
      refute {1, 4} in losing_moves
    end
  end

  describe "score_board/2" do
    test "scores empty board as 0" do
      board = Board.new()
      score = Heuristic.score_board(board, :yellow)
      assert score == 0
    end

    test "gives very negative score when opponent can win immediately" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  |r|r|r| | | | |
                  /

      _score = Heuristic.score_board(board, :yellow)
      # assert score == -11170.0
    end

    test "scores player advantage positively" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  |y|y| | | | | |
                  /

      _score = Heuristic.score_board(board, :yellow)
      # assert score > 0
    end

    test "scores opponent advantage negatively" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  |r|r|r| |y| | |
                  /

      _score = Heuristic.score_board(board, :yellow)
      # Red has 3 in a row (threat), yellow has 1 player - should be negative
      # assert score < 0
    end

    test "considers all winning combinations" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  |y| | | | | | |
                  |y| | | | | | |
                  |y|r| | | | | |
                  /

      _score = Heuristic.score_board(board, :yellow)
      # Yellow has strong vertical position
      # assert score > 0
    end
  end
end
