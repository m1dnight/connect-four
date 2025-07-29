defmodule C4.Solver do
  @moduledoc """
  Functionality to manipulate a board and dtermine winners.
  """
  use TypedStruct
  use C4.Types

  alias C4.Board
  alias C4.Heuristic

  import C4.Constants

  @depth 5

  typedstruct module: Move do
    use C4.Types
    field(:position, position())
    field(:score, number(), default: 0.0)
  end

  @doc """
  Distance from the center column.
  """
  @spec center_distance(Move.t()) :: float()
  def center_distance(%{position: {col, _}}) do
    abs(col - columns() / 2)
  end

  @doc """
  Compare two moves with eachtoerh.
  The move with the higher score is better than low score.
  """
  @spec move_compare(Move.t(), Move.t()) :: boolean()
  def move_compare(move_a, move_b) do
    if move_a.score == move_b.score do
      center_distance(move_a) > center_distance(move_b)
    else
      move_a.score > move_b.score
    end
  end

  @spec minimax(Board.t(), player()) :: Move.t() | {:winner, player()}
  def minimax(board, player, depth \\ @depth) do
    minimax(board, depth, player, false)
  end

  @spec minimax(Board.t(), depth(), player(), boolean()) :: Move.t() | {:winner, player()}
  def minimax(board, 0, player, opponent?) do
    player = if opponent?, do: Board.opponent(player), else: player
    score = Heuristic.score_board(board, player)

    %Move{score: score}
  end

  def minimax(board, depth, player, opponent?) do
    # list all the possible moves the player can make.
    board
    |> Board.playable_positions()
    |> Enum.sort()
    |> Enum.map(&minimax_score_move(board, depth, player, opponent?, &1))
    |> Enum.sort(&move_compare/2)
    |> if(opponent?, do: &Enum.reverse/1, else: & &1).()
    |> hd()
  end

  @doc """
  Given a board, and a move, returns the score for this board if the player makes that move.
  If the player wins, the score is returned. If the player does not win, the score is computed using minimax.
  """
  @spec minimax_score_move(Board.t(), non_neg_integer(), player(), boolean(), position()) ::
          Move.t()
  def minimax_score_move(board, depth, player, opponent?, position) do
    move_maker = if opponent?, do: Board.opponent(player), else: player
    opponent = Board.opponent(player)

    board = Board.put(board, position, move_maker)

    cond do
      # if this moves allows the player to win, give it the highest score.
      Board.winner?(board) == player ->
        %Move{score: 1_000_000, position: position}

      # if this move allows the opponent to win, do not make the move.
      Enum.count(Heuristic.direct_wins(board, opponent)) > 0 ->
        %Move{score: -1_000_000, position: position}

      # figure out score for other moves. Give them a lower score than direct
      # win/losses to make sure these moves are prioritized over the recursive
      # scoring.
      true ->
        %{score: score} = minimax(board, depth - 1, player, not opponent?)
        %Move{score: score * 0.9, position: position}
    end
  end
end
