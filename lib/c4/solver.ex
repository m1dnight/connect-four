defmodule C4.Solver do
  @moduledoc """
  Functionality to manipulate a board and dtermine winners.
  """
  use TypedStruct
  use C4.Types
  alias C4.Board
  alias C4.Heuristic

  @depth 5

  typedstruct module: Move do
    use C4.Types
    field(:position, position())
    field(:score, number(), default: 0.0)
  end

  @doc """
  Given a list of positions, picks the best one.

  The best one is the one with the highest score, and closest to the center.
  """
  @spec sort_options([Move.t()]) :: [Move.t()]
  def sort_options(moves) do
    moves
    |> Enum.group_by(& &1.score)
    |> Enum.sort_by(&elem(&1, 0), :desc)
    |> Enum.map(fn {_score, moves} ->
      Enum.sort_by(moves, &center_distance/1)
    end)
    |> Enum.concat()
  end

  @doc """
  Distance from the center column.
  """
  @spec center_distance(Move.t()) :: float()
  def center_distance(%{position: {col, _}}) do
    abs(col - 3.5)
  end

  @spec minimax(Board.t(), player()) :: Move.t() | {:winner, player()}
  def minimax(board, player) do
    minimax(board, @depth, player)
  end

  @spec minimax(Board.t(), depth(), player()) :: Move.t() | {:winner, player()}
  def minimax(board, 0, player) do
    score = Heuristic.score_board(board, player)
    %Move{score: score}
  end

  def minimax(board, depth, player) do
    worst? = player == :red

    # list all the possible moves the player can make.
    moves =
      board
      |> Board.playable


      _positions()
      |> Enum.sort()
      |> Enum.take(1)
      |> Enum.map(&minimax_score_move(board, depth, player, &1))
      |> sort_options()

    choice = if worst?, do: List.last(moves), else: hd(moves)

    if depth == @depth do
      IO.puts("#{player} can pick following moves:")

      for move <- moves do
        %{position: {col, row}, score: score} = move
        IO.puts("(#{col}, #{row}) :: #{score}")
      end

      IO.puts("Chose #{inspect(choice)}")
    end

    choice
  end

  @doc """
  Given a board, and a move, returns the score for this board if the player makes that move.
  If the player wins, the score is returned. If the player does not win, the score is computed using minimax.
  """
  @spec minimax_score_move(Board.t(), non_neg_integer(), token(), position()) :: Move.t()
  def minimax_score_move(board, depth, player, position) do
    opponent = if player == :yellow, do: :red, else: :yellow

    board = Board.put(board, position, player)

    score =
      if Board.winner?(board) do
        Heuristic.score_board(board, player)
      else
        %{score: score} = minimax(board, depth - 1, opponent)
        score
      end

    %Move{score: score, position: position}
  end
end
