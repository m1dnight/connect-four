defmodule C4.Constants do
  @moduledoc """
  Constant values in context of connect four.
  """
  use C4.Types

  @rows 7
  @columns 6

  @row_wins (for row <- 1..@rows do
               for column <- 1..3 do
                 for col <- (0 + column)..(3 + column) do
                   {col, row}
                 end
               end
             end)
            |> Enum.concat()

  # 24 possible wins in columns
  @col_wins (for column <- 1..@columns do
               for row <- 1..4 do
                 for r <- (0 + row)..(3 + row) do
                   {column, r}
                 end
               end
             end)
            |> Enum.concat()

  # 12 diagonal wins
  @diagonal_wins_forward (for column <- 1..3 do
                            for row <- 4..@rows do
                              for i <- 0..3 do
                                {column + i, row - i}
                              end
                            end
                          end)
                         |> Enum.concat()

  @diagonal_wins_backward (for column <- @columns..4//-1 do
                             for row <- 4..@rows do
                               for i <- 0..3 do
                                 {column - i, row - i}
                               end
                             end
                           end)
                          |> Enum.concat()

  @wins @col_wins ++ @diagonal_wins_forward ++ @diagonal_wins_backward ++ @row_wins

  @spec wins :: [[position()]]
  def wins, do: @wins

  @doc """
  Total rows on the board
  """
  @spec columns :: non_neg_integer()
  def columns, do: @columns

  @doc """
  Total rows on the board
  """
  @spec rows :: non_neg_integer()
  def rows, do: @rows
end
