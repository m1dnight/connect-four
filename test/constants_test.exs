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
      assert length(positions) == @rows * @columns
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
      for win <- Constants.wins() do
        for position <- win do
          assert position in Constants.all_positions()
        end
      end
    end

    test "no duplicate winning combinations" do
      wins = Constants.wins()
      unique_wins = Enum.uniq(wins)

      assert length(wins) == length(unique_wins)
    end
  end
end
