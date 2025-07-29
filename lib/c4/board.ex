defmodule C4.Board do
  @moduledoc """
  Defines the board and operations that can be performed on the board.
  """
  use TypedStruct
  use C4.Types

  alias C4.Board

  import C4.Constants

  typedstruct do
    @typedoc """
    Represents a board, the player, and the opponent.
    """
    field(:board, %{position() => player()})
    field(:player, player(), default: :yellow)
    field(:opponent, player(), default: :red)
  end

  typedstruct module: Position do
    @typedoc """
    Represents a position on the board.
    """
    field(:column, non_neg_integer())
    field(:row, non_neg_integer())
  end

  @doc """
  Create a new board.
  """
  @spec new :: Board.t()
  def new do
    board =
      for column <- 1..columns() do
        for row <- 1..rows() do
          {{column, row}, :empty}
        end
      end
      |> Enum.concat()
      |> Enum.into(%{})

    %Board{board: board}
  end

  @doc """
  Generates a random board.
  """
  @spec random(non_neg_integer()) :: Board.t()
  def random(players \\ 5) do
    Enum.reduce(1..players, new(), fn _, board ->
      player = Enum.shuffle([:red, :yellow]) |> hd()
      position = board |> playable_positions() |> Enum.shuffle() |> hd()
      put(board, position, player)
    end)
  end

  @doc """
  Put a player on the given position.
  """
  @spec put(Board.t(), position(), player()) :: Board.t()
  def put(board, position, player) do
    new_grid = Map.put(board.board, position, player)
    %{board | board: new_grid}
  end

  @doc """
  Put a player on the given position.
  """
  @spec get(Board.t(), position()) :: player()
  def get(board, position) do
    Map.get(board.board, position)
  end

  @doc """
  Returns true if a position is empty.
  """
  @spec empty?(Board.t(), position()) :: boolean()
  def empty?(board, position) do
    get(board, position) == :empty
  end

  @doc "Returns the opponent of the given player's name."
  @spec opponent(player()) :: player()
  def opponent(:yellow), do: :red
  def opponent(:red), do: :yellow

  @doc """
  Returns a list of positions a player can be placed.
  """
  @spec playable_positions(Board.t()) :: [position()]
  def playable_positions(board) do
    1..columns()
    |> Enum.map(&playable_position(board, &1))
    |> Enum.reject(&(&1 == nil))
  end

  @doc """
  Returns the first free row in the given column.
  """
  @spec playable_position(Board.t(), non_neg_integer()) :: position() | nil
  def playable_position(board, column) do
    1..rows()
    |> Enum.reduce_while(nil, fn row, _ ->
      if empty?(board, {column, row}) do
        {:halt, {column, row}}
      else
        {:cont, nil}
      end
    end)
  end

  @doc """
  Checks the board if there is a winner.
  Returns the color of the winning player, or false if nobody won.
  """
  @spec winner?(Board.t()) :: :yellow | :red | false
  def winner?(board) do
    wins()
    |> Enum.reduce_while(false, fn positions, _ ->
      positions
      |> same_player?(board)
      |> case do
        false ->
          {:cont, false}

        :empty ->
          {:cont, false}

        player ->
          {:halt, player}
      end
    end)
  end

  @doc """
  Given a series of positions, checks if theyre all the same player. Returns
  false, or the player in case theyre all the same.
  """
  @spec same_player?([position()], Board.t()) :: false | player()
  def same_player?(positions, board) do
    positions
    |> Enum.map(&get(board, &1))
    |> Enum.dedup()
    |> case do
      [player] ->
        player

      _ ->
        false
    end
  end

  @doc """
  Checks if the move to be made results in the player winning.
  """
  @spec winning_move?(Board.t(), position(), player()) :: boolean()
  def winning_move?(board, position, player) do
    board = put(board, position, player)

    wins()
    |> Enum.filter(&(Enum.member?(&1, position) and player == same_player?(&1, board)))
    |> Enum.empty?()
    |> Kernel.not()
  end

  @doc """
  Checks if the move to be made results in the opponent winning.
  """
  @spec losing_move?(Board.t(), position(), player()) :: boolean()
  def losing_move?(board, position, player) do
    board = put(board, position, player)

    # check all the moves the opponent can make, and see if they are winning
    # moves.
    board
    |> playable_positions()
    |> Enum.map(&winning_move?(board, &1, opponent(player)))
    |> Enum.any?()
  end

  @doc """
  Pretty prints a board to the console.
  """
  @spec pretty_print(Board.t(), [position()]) :: Board.t()
  def pretty_print(%Board{} = board, _highlights \\ []) do
    IO.puts("   " <> Enum.map_join(1..columns(), " ", &to_string/1) <> "")

    player = "■"

    # board = Enum.reduce(highlights, board, fn pos, board -> put(board, pos, :highlight) end)

    for row <- rows()..1//-1 do
      row_cells =
        for column <- 1..columns() do
          case Map.get(board.board, {column, row}) do
            :empty -> IO.ANSI.white() <> " " <> IO.ANSI.reset()
            :yellow -> IO.ANSI.yellow() <> player <> IO.ANSI.reset()
            :red -> IO.ANSI.red() <> player <> IO.ANSI.reset()
            # :highlight -> IO.ANSI.bright() <> player <> IO.ANSI.reset()
          end
        end

      IO.puts(to_string(row) <> " |" <> Enum.join(row_cells, "|") <> "|")
    end

    board
  end

  @doc """
  Sigil to create a bord from a string.
  """
  @spec sigil_b(String.t(), term()) :: Board.t()
  def sigil_b(str, _) do
    board =
      str
      |> String.trim()
      |> String.split("\n")
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {line, row} ->
        line
        |> String.trim()
        |> String.split("|")
        |> Enum.reject(&(String.length(&1) < 1))
        |> Enum.with_index(1)
        |> Enum.map(fn {char, column} ->
          case char do
            " " -> {{column, row}, :empty}
            "y" -> {{column, row}, :yellow}
            "r" -> {{column, row}, :red}
          end
        end)
      end)
      |> Enum.concat()
      |> Enum.into(%{})

    %Board{board: board}
  end
end
