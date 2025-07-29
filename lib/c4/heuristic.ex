defmodule C4.Heuristic do
  @moduledoc """
  Contains functionality to rate the state of a board, and to score potential
  moves.
  """
  use C4.Types

  alias C4.Board
  import C4.Constants

  @doc "Returns the opponent of the given player's name."
  @spec opponent(player()) :: player()
  def opponent(:yellow), do: :red
  def opponent(:red), do: :yellow

  @doc """
  Return all the moves that would allow the opponent to win with 1 move.
  """
  @spec losing_moves(Board.t(), player()) :: [position()]
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
  @spec winning_moves(Board.t(), player()) :: [position()]
  def winning_moves(board, player) do
    board
    |> Board.playable_positions()
    |> Enum.filter(&Board.winning_move?(board, &1, player))
  end

  @doc """
  Returns a score for the state of this board.

  The score is determined for the given player.
  """
  @spec score_board(Board.t(), player()) :: integer()
  def score_board(board, player) do
    opponent = if player == :yellow, do: :red, else: :yellow

    # if the board is winnable by the opponent, give it the worst score.
    score =
      if winning_moves(board, opponent) != [] do
        -10_000
      else
        0
      end

    score =
      wins()
      |> Enum.reduce(score, fn positions, score ->
        # IO.inspect rate_series(board, positions, player), label: "#{inspect positions}"
        score + rate_series(board, positions, player)
      end)

    opponent_score =
      wins()
      |> Enum.reduce(0, fn positions, score ->
        score + rate_series(board, positions, opponent)
      end)

    score - opponent_score
  end

  @spec rate_series(Board.t(), [position()], player()) :: number()
  def rate_series(board, positions, player) do
    positions
    |> Enum.map(&Board.get(board, &1))
    |> Enum.group_by(& &1)
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.into(%{})
    |> case do
      %{^player => 1, :empty => 3} ->
        :math.pow(10, 1)

      %{^player => 2, :empty => 2} ->
        :math.pow(10, 2)

      %{^player => 3, :empty => 1} ->
        :math.pow(10, 3)

      %{^player => 4} ->
        :math.pow(10, 4)

      _ ->
        0
    end
  end

  @doc """
  Given a board and a move, rates the board after making this move.
  """
  @spec score_move(Board.t(), position(), player()) :: integer()
  def score_move(board, position, player) do
    board
    |> Board.put(position, player)
    |> score_board(player)
  end
end
