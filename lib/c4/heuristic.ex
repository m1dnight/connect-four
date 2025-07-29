defmodule C4.Heuristic do
  @moduledoc """
  Contains functionality to rate the state of a board, and to score potential
  moves.
  """
  use C4.Types

  alias C4.Board

  @doc """
  For a given player, lists the moves that will cause an instant win.
  """
  @spec direct_wins(Board.t(), player()) :: [position()]
  def direct_wins(board, player) do
    board
    |> Board.playable_positions()
    |> Enum.filter(&Board.winning_move?(board, &1, player))
  end

  @doc """
  Return all the moves that would allow the opponent to win with 1 move.
  """
  @spec losing_moves(Board.t(), player()) :: [position()]
  def losing_moves(board, player) do
    board
    |> Board.playable_positions()
    |> Enum.filter(&Board.losing_move?(board, &1, player))
  end

  @doc """
  Returns a score for the state of this board.

  The score is determined for the given player.
  """
  @spec score_board(Board.t(), player()) :: integer()
  def score_board(board, player) do
    opponent = Board.opponent(player)

    cond do
      # if the board is won by the player, give it the highest score.
      Board.winner?(board) == player ->
        1_000_000

      # if the board is won by the opponent, give it the worst score.
      Board.winner?(board) == opponent ->
        -1_000_000

      # if there are direct wins for the opponent, give it a low score.
      not Enum.empty?(direct_wins(board, opponent)) ->
        -10_000

      # if there are direct wins for the player, give it a high score.
      not Enum.empty?(direct_wins(board, player)) ->
        10_000

      # no direct wins for either player, so give it a 0.
      true ->
        0
    end
  end
end
