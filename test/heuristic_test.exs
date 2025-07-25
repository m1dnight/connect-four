defmodule C4.Test.Heuristic do
  use ExUnit.Case
  doctest C4

  alias C4.Board
  import C4.Board
  alias C4.Heuristic

  describe "losing_moves/2" do
    test "no losing moves" do
      board = Board.new()
      assert [] = Heuristic.losing_moves(board, :yellow)
    end

    test "one losing move" do
      board = ~b/
              | | | | | | |
              | | | | | | |
              | | | | | | |
              | | | | | | |
              | | | | | | |
              |r|r| |r| | |
              |y|y| |y| | |
              /

      assert [{3, 1}] = Heuristic.losing_moves(board, :yellow)
    end
  end

  describe "winning_moves/2" do
    test "no winning moves" do
      board = Board.new()
      assert [] = Heuristic.winning_moves(board, :yellow)
    end

    test "one winning move" do
      board = ~b/
              | | | | | | |
              | | | | | | |
              | | | | | | |
              | | | | | | |
              | | | | | | |
              | | | | | | |
              |y|y| |y| | |
              /
      assert [{3, 1}] = Heuristic.winning_moves(board, :yellow)
    end

    test "multiple winning moves" do
      board = ~b/
              | | | | | | |
              | | | | | | |
              | | | | | | |
              | | | | | | |
              |y| | | | |y|
              |y| | | | |y|
              |y|y| |y| |y|
              /
      assert [{1, 4}, {3, 1}, {6, 4}] = Heuristic.winning_moves(board, :yellow)
    end
  end

  describe "score_board/2" do
    test "no score" do
      board = Board.new()
      assert 0 = Heuristic.score_board(board, :yellow)
    end

    test "opponent wins" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |r|r|r|r| | | |
              /
      # losing pennalty, and all 5 possible moves are losing moves
      assert -1100 = Heuristic.score_board(board, :yellow)
    end

    test "player wins" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |y|y|y|y| | | |
              /
      # winnig score, and placing an extra y on the board makes "two" wins.
      assert 1000 = Heuristic.score_board(board, :yellow)
    end

    test "one move away from winning" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |y|y| |y| | | |
              /
      # winnig score, and placing an extra y on the board makes "two" wins.
      assert 500 = Heuristic.score_board(board, :yellow)
    end

    test "two ways to win" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |y| | | | | | |
              |y| | | | | | |
              |y|y| |y| | | |
              /
      # winnig score, and placing an extra y on the board makes "two" wins.
      assert 1000 = Heuristic.score_board(board, :yellow)
    end

    test "five ways to win" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |y| |y|y|y| | |
              |y|r|y|r|y|r| |
              |y|r|y|r|y|r| |
              /
      # winnig score, and placing an extra y on the board makes "two" wins.
      assert 2500 = Heuristic.score_board(board, :yellow)
    end

    @tag :this
    test "figure out best move" do
      board = ~b/
              | | |y|y| | | |
              | | |r|r| | | |
              | | |y|y| | | |
              | | |r|r| | | |
              | |r|r|y| | | |
              | |y|y|y| | | |
              /
      # winnig score, and placing an extra y on the board makes "two" wins.
      assert 1000 = Heuristic.score_board(board, :yellow)
    end
  end

  describe "score_move/3" do
    test "no score" do
      board = Board.new()
      assert 0 = Heuristic.score_move(board, {1, 1}, :yellow)
    end

    test "making two consecutive tokens doesnt improve odds" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |y| | | | | | |
              /
      assert 0 = Heuristic.score_move(board, {2, 1}, :yellow)
    end

    test "making three improves score by 100" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |y|y| | | | | |
              /
      assert 0 = Heuristic.score_move(board, {1, 2}, :yellow)
      assert 0 = Heuristic.score_move(board, {2, 2}, :yellow)
      assert 0 = Heuristic.score_move(board, {5, 1}, :yellow)
      assert 0 = Heuristic.score_move(board, {6, 1}, :yellow)
      # these moves lead to a win the next turn
      assert 500 = Heuristic.score_move(board, {3, 1}, :yellow)
      assert 500 = Heuristic.score_move(board, {4, 1}, :yellow)
    end

    test "making four is winning score" do
      board = ~b/
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              | | | | | | | |
              |y|y|y| | | | |
              /
      assert 1000 = Heuristic.score_move(board, {4, 1}, :yellow)
    end

    @tag :thiss
    test "debug test" do
      board = ~b/
              | | |r|r| | | |
              | | |r|r| | | |
              | | |y|y| | | |
              | | |r|r| | | |
              | |r|r|y| | | |
              | |y|y|y| | | |
              /

      Board.playable_positions(board)
      |> Enum.map(&{&1, Heuristic.score_move(board, &1, :yellow)})
    end
  end
end
