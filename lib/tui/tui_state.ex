defmodule C4.Tui.State do
  @moduledoc """
  Defines the state and its operations for the TUI.
  """

  use TypedStruct
  use C4.Types

  alias C4.Board
  alias C4.Solver
  alias C4.Solver.Move
  alias C4.Tui.State

  import C4.Constants

  typedstruct do
    field(:board, Board.t(), default: Board.new())
    field(:player, player(), default: :red)
    field(:moves, [{position(), player()}], default: [])
    field(:game_over, boolean(), default: false)
    field(:selected_column, non_neg_integer(), default: 1)
    field(:waiting, boolean(), default: false)
    field(:debug, [String.t()], default: [])
    field(:debugging, boolean(), default: false)
    field(:highlights, [position()], default: [])
  end

  @doc """
  Enable debug logs
  """
  @spec debugging(State.t()) :: State.t()
  def debugging(state) do
    %{state | debugging: not state.debugging}
  end

  @doc """
  Select the column on the right.
  """
  @spec next_column(State.t()) :: State.t()
  def next_column(state) when state.waiting or state.game_over, do: state

  def next_column(state) do
    current = state.selected_column
    new = min(columns(), current + 1)
    %{state | selected_column: new}
  end

  @doc """
  Select the column on the left.
  """
  @spec previous_column(State.t()) :: State.t()
  def previous_column(state) when state.waiting or state.game_over, do: state

  def previous_column(state) do
    current = state.selected_column
    new = max(1, current - 1)
    %{state | selected_column: new}
  end

  @spec ai_moved(State.t(), Move.t()) :: State.t()
  def ai_moved(state, move) do
    board = state.board |> Board.put(move.position, :yellow)
    moves = state.moves ++ [{move.position, :yellow}]

    # remove the highlight after half a second
    Process.send_after(self(), {:unhighlight, move.position}, 500)

    %{
      state
      | board: board,
        player: :red,
        waiting: false,
        moves: moves,
        highlights: [move.position]
    }
    |> game_over?()
  end

  @doc """
  Makes a move as the human player.
  """
  @spec make_move(State.t()) :: State.t() | {State.t(), term()}
  def make_move(state) when state.waiting or state.game_over, do: state

  def make_move(state) do
    state
    |> place()
    |> ai_move()
  end

  @doc """
  Insert player on current position.
  """
  @spec place(State.t()) :: State.t()
  def place(state) when state.waiting or state.game_over, do: state

  def place(state) do
    case select_position(state) do
      nil ->
        state

      position ->
        move_entry = {position, state.player}

        %{
          state
          | board: Board.put(state.board, position, :red),
            moves: state.moves ++ [move_entry]
        }
    end
    |> game_over?()
  end

  @spec ai_move(State.t()) :: State.t()
  def ai_move(state) when state.waiting, do: state

  def ai_move(state) do
    this = self()

    Task.start(fn ->
      # sleep is here or sometimes the tui does not update
      Process.sleep(100)
      move = Solver.minimax(state.board, :yellow)
      send(this, {:ai_move, move})
    end)

    %{state | waiting: true, player: :yellow}
  end

  # ----------------------------------------------------------------------------
  # Helpers

  @spec select_position(State.t()) :: position() | nil
  defp select_position(state) do
    board = state.board
    column = state.selected_column

    Board.playable_positions(board)
    |> Enum.filter(fn {col, _row} -> col == column end)
    |> List.first()
  end

  defp game_over?(state) do
    if Board.winner?(state.board) do
      {_player, positions} = Board.winner(state.board)
      %{state | game_over: true, highlights: positions}
    else
      state
    end
  end
end
