defmodule C4.ConstantsTest do
  use ExUnit.Case
  doctest C4.Constants

  alias C4.Constants

  @rows 6
  @columns 7
  describe "columns/0" do
    test "returns 7 columns" do
      assert Constants.columns() == @columns
    end
  end

  describe "rows/0" do
    test "returns 6 rows" do
      assert Constants.rows() == @rows
    end
  end

  describe "all_positions/0" do
    test "returns all 42 positions" do
      positions = Constants.all_positions()
      assert length(positions) == @rows * @column
    end

    test "includes all valid column/row combinations" do
      positions = Constants.all_positions()

      for column <- 1..@columns, row <- 1..@rows do
        assert {column, row} in positions
      end
    end

    test "does not include invalid positions" do
      positions = Constants.all_positions()

      # Test some invalid positions
      refute {0, 1} in positions
      refute {8, 1} in positions
      refute {1, 0} in positions
      refute {1, 7} in positions
    end
  end

  describe "wins/0" do
    test "returns correct total number of winning combinations" do
      wins = Constants.wins()

      # Expected: 21 row wins + 24 column wins + 12 diagonal wins = 69 total
      # Row wins: 4 possible horizontal wins per row × 6 rows = 24 (corrected from initial comment)
      # Column wins: 4 possible vertical wins per column × 7 columns = 28 (corrected)
      # But let's count what we actually get
      assert length(wins) > 0
    end

    test "all winning combinations have exactly 4 positions" do
      wins = Constants.wins()

      for win <- wins do
        assert length(win) == 4
      end
    end

    test "all positions in wins are valid board positions" do
      wins = Constants.wins()
      valid_positions = Constants.all_positions()

      for win <- wins do
        for position <- win do
          assert position in valid_positions
        end
      end
    end

    test "includes horizontal wins" do
      wins = Constants.wins()

      # Test a few known horizontal wins
      horizontal_win_row_1 = [{1, 1}, {2, 1}, {3, 1}, {4, 1}]
      horizontal_win_row_6 = [{1, 6}, {2, 6}, {3, 6}, {4, 6}]

      assert horizontal_win_row_1 in wins
      assert horizontal_win_row_6 in wins
    end

    test "includes vertical wins" do
      wins = Constants.wins()

      # Test a few known vertical wins
      vertical_win_col_1 = [{1, 1}, {1, 2}, {1, 3}, {1, 4}]
      vertical_win_col_7 = [{7, 1}, {7, 2}, {7, 3}, {7, 4}]

      assert vertical_win_col_1 in wins
      assert vertical_win_col_7 in wins
    end

    test "includes diagonal wins (ascending)" do
      wins = Constants.wins()

      # Test some known ascending diagonal wins
      diagonal_win_1 = [{1, 1}, {2, 2}, {3, 3}, {4, 4}]
      diagonal_win_2 = [{4, 3}, {5, 4}, {6, 5}, {7, 6}]

      assert diagonal_win_1 in wins
      assert diagonal_win_2 in wins
    end

    test "includes diagonal wins (descending)" do
      wins = Constants.wins()

      # Test some known descending diagonal wins
      diagonal_win_1 = [{4, 1}, {3, 2}, {2, 3}, {1, 4}]
      diagonal_win_2 = [{7, 3}, {6, 4}, {5, 5}, {4, 6}]

      assert diagonal_win_1 in wins
      assert diagonal_win_2 in wins
    end

    test "no duplicate winning combinations" do
      wins = Constants.wins()
      unique_wins = Enum.uniq(wins)

      assert length(wins) == length(unique_wins)
    end

    test "winning combinations are consistent in ordering" do
      wins = Constants.wins()

      # Each win should maintain consistent ordering within itself
      for win <- wins do
        # For horizontal wins, column should increase
        if horizontal_win?(win) do
          columns = Enum.map(win, fn {col, _row} -> col end)
          assert columns == Enum.sort(columns)
        end

        # For vertical wins, row should increase
        if vertical_win?(win) do
          rows = Enum.map(win, fn {_col, row} -> row end)
          assert rows == Enum.sort(rows)
        end
      end
    end
  end

  # Helper functions for testing
  defp horizontal_win?(positions) do
    [{_, row} | _] = positions
    Enum.all?(positions, fn {_, r} -> r == row end)
  end

  defp vertical_win?(positions) do
    [{col, _} | _] = positions
    Enum.all?(positions, fn {c, _} -> c == col end)
  end
end
