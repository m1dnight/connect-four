defmodule C4.BoardTest do
  use ExUnit.Case
  doctest C4.Board

  alias C4.Board

  import C4.Constants
  import C4.Board

  describe "new/0" do
    test "creates an empty board with correct dimensions" do
      board = Board.new()

      assert board.player == :yellow
      assert board.opponent == :red
      # 6 columns × 7 rows
      assert map_size(board.board) == 42

      # Check all positions are empty
      for column <- 1..columns(), row <- 1..rows() do
        assert Board.get(board, {column, row}) == :empty
      end
    end
  end

  describe "put/3 and get/2" do
    test "puts and gets a player at a position" do
      for row <- 1..rows(), column <- 1..columns() do
        board = Board.new()
        board = Board.put(board, {column, row}, :yellow)
        assert Board.get(board, {column, row}) == :yellow
      end
    end

    test "overwrites existing player" do
      board = Board.new()

      for row <- 1..rows(), column <- 1..columns() do
        board = Board.put(board, {column, row}, :yellow)
        assert Board.get(board, {column, row}) == :yellow
      end

      for row <- 1..rows(), column <- 1..columns() do
        board = Board.put(board, {column, row}, :red)
        assert Board.get(board, {column, row}) == :red
      end
    end

    test "all positions are present in the grid" do
      board =
        Enum.reduce(all_positions(), Board.new(), fn position, board ->
          Board.put(board, position, :yellow)
        end)

      board.board
      |> Enum.each(fn {_, v} -> assert v == :yellow end)
    end
  end

  describe "empty?/2" do
    test "returns true for empty positions" do
      all_positions()
      |> Enum.each(fn position ->
        assert Board.empty?(Board.new(), position)
      end)
    end

    test "returns false for occupied positions" do
      board =
        Enum.reduce(all_positions(), Board.new(), fn position, board ->
          Board.put(board, position, :yellow)
        end)

      all_positions()
      |> Enum.each(fn position ->
        refute Board.empty?(board, position)
      end)
    end
  end

  describe "playable_positions/1" do
    test "returns all columns for empty board" do
      board = Board.new()
      positions = Board.playable_positions(board)

      expected = for column <- 1..columns(), do: {column, 1}
      assert Enum.sort(positions) == Enum.sort(expected)
    end

    test "returns correct positions when some columns have players" do
      board = Board.new()
      board = Board.put(board, {1, 1}, :yellow)
      board = Board.put(board, {1, 2}, :red)

      positions = Board.playable_positions(board)

      expected = [{1, 3}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}]
      assert Enum.sort(positions) == Enum.sort(expected)
    end

    test "excludes full columns" do
      board = Board.new()

      # Fill column 1 completely
      board =
        Enum.reduce(1..rows(), board, fn row, acc ->
          Board.put(acc, {1, row}, :yellow)
        end)

      positions = Board.playable_positions(board)

      expected = [{2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}]
      assert Enum.sort(positions) == Enum.sort(expected)
    end
  end

  describe "playable_position/2" do
    test "returns lowest row for empty column" do
      board = Board.new()
      assert Board.playable_position(board, 1) == {1, 1}
    end

    test "returns next available row when column has players" do
      board = Board.new()
      board = Board.put(board, {1, 1}, :yellow)
      board = Board.put(board, {1, 2}, :red)

      assert Board.playable_position(board, 1) == {1, 3}
    end

    test "returns nil for full column" do
      board = Board.new()

      # Fill column 1 completely
      board =
        Enum.reduce(1..rows(), board, fn row, acc ->
          Board.put(acc, {1, row}, :yellow)
        end)

      assert Board.playable_position(board, 1) == nil
    end
  end

  describe "winner?/1" do
    test "returns false for empty board" do
      board = Board.new()
      assert Board.winner?(board) == false
    end

    test "detects horizontal win" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  |y|y|y|y| | | |
                  /

      assert Board.winner?(board) == :yellow
    end

    test "detects vertical win" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  |y| | | | | | |
                  |y| | | | | | |
                  |y| | | | | | |
                  |y| | | | | | |
                  /

      assert Board.winner?(board) == :yellow
    end

    test "detects diagonal win (ascending)" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  |y| | | | | | |
                  |r|y| | | | | |
                  |r|r|y| | | | |
                  |r|r|r|y| | | |
                  /

      assert Board.winner?(board) == :yellow
    end

    test "detects diagonal win (descending)" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | |y| | | |
                  | | |y|r| | | |
                  | |y|r|r| | | |
                  |y|r|r|r| | | |
                  /

      assert Board.winner?(board) == :yellow
    end

    test "returns false when no winner" do
      board = ~b/
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  | | | | | | | |
                  |y|r|y| | | | |
                  |r|y|r| | | | |
                  /

      assert Board.winner?(board) == false
    end
  end

  describe "same_player?/2" do
    test "returns player when all positions have same player" do
      board = Board.new()
      board = Board.put(board, {1, 1}, :yellow)
      board = Board.put(board, {2, 1}, :yellow)
      board = Board.put(board, {3, 1}, :yellow)

      positions = [{1, 1}, {2, 1}, {3, 1}]
      assert Board.same_player?(positions, board) == :yellow
    end

    test "returns false when positions have different players" do
      board = Board.new()
      board = Board.put(board, {1, 1}, :yellow)
      board = Board.put(board, {2, 1}, :red)

      positions = [{1, 1}, {2, 1}]
      assert Board.same_player?(positions, board) == false
    end

    test "returns :empty when all positions are empty" do
      board = Board.new()

      positions = [{1, 1}, {2, 1}, {3, 1}]
      assert Board.same_player?(positions, board) == :empty
    end
  end

  describe "winning_move?/3" do
    test "returns true for move that creates horizontal win" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y|y|y| | | | |
                /

      assert Board.winning_move?(board, {4, 1}, :yellow) == true
    end

    test "returns true for move that creates vertical win" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y| | | | | | |
                |y| | | | | | |
                |y| | | | | | |
                /

      assert Board.winning_move?(board, {1, 4}, :yellow) == true
    end

    test "returns false for move that doesn't create win" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |y|y| | | | | |
                /

      assert Board.winning_move?(board, {3, 1}, :yellow) == false
    end
  end

  describe "sigil_b/2" do
    test "creates board from string representation" do
      board = ~b/
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                | | | | | | | |
                |r|y| | | | | |
                |y|r|y| | | | |
                /

      assert Board.get(board, {1, 1}) == :yellow
      assert Board.get(board, {2, 1}) == :red
      assert Board.get(board, {3, 1}) == :yellow
      assert Board.get(board, {1, 2}) == :red
      assert Board.get(board, {2, 2}) == :yellow
      assert Board.get(board, {4, 1}) == :empty
    end
  end

  describe "random/1" do
    test "creates board with specified number of players" do
      board = Board.random(5)

      player_count =
        board.board
        |> Map.values()
        |> Enum.count(&(&1 != :empty))

      assert player_count == 5
    end

    test "creates board with default 5 players" do
      board = Board.random()

      player_count =
        board.board
        |> Map.values()
        |> Enum.count(&(&1 != :empty))

      assert player_count == 5
    end
  end
end
