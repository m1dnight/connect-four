defmodule C4.Board do
  @moduledoc """
  Defines the board and operations that can be performed on the board.
  """
  use TypedStruct
  use C4.Types

  alias C4.Board
  import C4.Constants

  typedstruct do
    field(:board, %{position() => token()})
    field(:player, token(), default: :yellow)
    field(:opponent, token(), default: :red)
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
  Put a token on the given position.
  """
  @spec put(Board.t(), position(), token()) :: Board.t()
  def put(board, position, token) do
    new_grid =
      board.board
      |> Map.put(position, token)

    %{board | board: new_grid}
  end

  @doc """
  Put a token on the given position.
  """
  @spec get(Board.t(), position()) :: token()
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

  @doc """
  Returns a list of positions a token can be placed.
  """
  @spec playable_positions(Board.t()) :: [position()]
  def playable_positions(board) do
    for column <- 1..columns() do
      1..rows()
      |> Enum.reduce_while(nil, fn row, _ ->
        if empty?(board, {column, row}) do
          {:halt, [{column, row}]}
        else
          {:cont, []}
        end
      end)
    end
    |> Enum.concat()
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
      |> same_token?(board)
      |> case do
        false ->
          {:cont, false}

        :empty ->
          {:cont, false}

        token ->
          {:halt, token}
      end
    end)
  end

  @doc """
  Given a series of positions, checks if theyre all the same token. Returns
  false, or the token in case theyre all the same.
  """
  @spec same_token?([position()], Board.t()) :: false | token()
  def same_token?(positions, board) do
    positions
    |> Enum.map(&get(board, &1))
    |> Enum.dedup()
    |> case do
      [token] ->
        token

      _ ->
        false
    end
  end

  @doc """
  Checks if the move to be made results in the player winning.
  """
  @spec winning_move?(Board.t(), position(), token()) :: boolean()
  def winning_move?(board, position, player) do
    board = put(board, position, player)

    wins()
    |> Enum.filter(&(Enum.member?(&1, position) and player == same_token?(&1, board)))
    |> Enum.empty?()
    |> Kernel.not()
  end

  @doc """
  Pretty prints a board to the console.
  """
  @spec pretty_print(Board.t(), [position()]) :: Board.t()
  def pretty_print(%Board{} = board, highlights \\ []) do
    IO.puts("   " <> Enum.map_join(1..columns(), " ", &to_string/1) <> "")

    token = "■"

    board = Enum.reduce(highlights, board, fn pos, board -> put(board, pos, :highlight) end)

    for row <- rows()..1//-1 do
      row_cells =
        for column <- 1..columns() do
          case Map.get(board.board, {column, row}) do
            :empty -> IO.ANSI.white() <> " " <> IO.ANSI.reset()
            :yellow -> IO.ANSI.yellow() <> token <> IO.ANSI.reset()
            :red -> IO.ANSI.red() <> token <> IO.ANSI.reset()
            :highlight -> IO.ANSI.bright() <> token <> IO.ANSI.reset()
          end
        end

      IO.puts(to_string(row) <> " |" <> Enum.join(row_cells, "|") <> "|")
      # IO.puts List.duplicate("-", 15)
    end

    board
  end

  @doc """
  Generates a random board.
  """
  @spec random(non_neg_integer()) :: Board.t()
  def random(tokens \\ 5) do
    Enum.reduce(1..tokens, new(), fn _, board ->
      token = Enum.shuffle([:red, :yellow]) |> hd()
      position = board |> playable_positions() |> Enum.shuffle() |> hd()
      put(board, position, token)
    end)
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
