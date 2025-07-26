defmodule C4.Heuristic do
  @moduledoc """
  Contains functionality to rate the state of a board, and to score potential
  moves.
  """
  use C4.Types

  alias C4.Board

  @doc """
  Return all the moves that would allow the opponent to win with 1 move.
  """
  @spec losing_moves(Board.t(), token()) :: [position()]
  def losing_moves(board, player) do
    board
    |> Board.playable_positions()
    |> Enum.filter(fn position ->
      board
      |> Board.put(position, player)
      |> winning_moves(board.opponent)
      |> Enum.empty?()
      |> Kernel.not()
    end)
  end

  @doc """
  For a given player, lists the moves that will cause an instant win.
  """
  @spec winning_moves(Board.t(), token()) :: [position()]
  def winning_moves(board, player) do
    board
    |> Board.playable_positions()
    |> Enum.filter(&Board.winning_move?(board, &1, player))
  end

  @doc """
  Returns a score for the state of this board.

  The score is determined for the given player.
  """
  @spec score_board(Board.t(), token()) :: integer()
  def score_board(board, player) do
    opponent = if player == :yellow, do: :red, else: :yellow

    # check if this board has a winner
    winner = Board.winner?(board)

    score =
      cond do
        winner == false ->
          0

        winner == player ->
          500

        winner == opponent ->
          -500
      end

    # check how many moves the player can make to win directly.
    winning_moves = winning_moves(board, player)
    score = score + Enum.count(winning_moves) * 500

    # check how many moves the player can make that cause the opponent to win directly.
    losing_moves = losing_moves(board, player)
    score = score - Enum.count(losing_moves) * 100

    # return the total score
    score
  end

  @doc """
  Given a board and a move, rates the board after making this move.
  """
  @spec score_move(Board.t(), position(), token()) :: integer()
  def score_move(board, position, player) do
    board
    |> Board.put(position, player)
    |> score_board(player)
  end
end
