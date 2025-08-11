defmodule C4.Tui do
  @moduledoc """
  Logic to render the game in a terminal.
  """
  @behaviour Garnish.App

  import Garnish.View
  import C4.Constants

  alias C4.Board
  alias C4.Tui.State

  use C4.Types

  @left :kcuf1
  @right :kcub1
  @drop 32
  @debug 100

  def init(_context) do
    {:ok, %State{}}
  end

  def handle_key(%{key: key}, state) do
    new_state =
      case key do
        @left -> State.next_column(state)
        @right -> State.previous_column(state)
        @drop -> State.make_move(state)
        @debug -> State.debugging(state)
        {:ai_move, move} -> State.ai_moved(state, move)
        _ -> %{state | debug: [inspect(key) | state.debug]}
      end

    {:ok, new_state}
  end

  def handle_info({:ai_move, move}, state) do
    {:ok, State.ai_moved(state, move)}
  end

  def render(state) do
    view do
      row do
        column size: 4 do
          # Board Panel
          panel title: "Board" do
            label do
              move_message(state)
            end

            board(state)
          end
        end

        # Move history panel
        column size: 8 do
          panel title: "Moves" do
            for move <- state.moves do
              move(move)
            end
          end
        end
      end

      if state.debugging do
        row do
          debug(state)
        end
      end
    end
  end

  # ----------------------------------------------------------------------------
  # Helpers

  defp debug(state) do
    column size: 12 do
      panel title: "Debugging" do
        table do
          for d <- state.debug do
            table_row do
              table_cell(content: d <> "\n")
            end
          end
        end
      end
    end
  end

  @spec move({position(), player()}) :: Garnish.Renderer.Element.t()
  defp move({position, player}) do
    color =
      case player do
        :red -> :red
        :yellow -> :yellow
      end

    {col, row} = position

    label do
      text(content: "(#{col}, #{row})", color: color)
    end
  end

  @spec move_message(State.t()) :: Garnish.Renderer.Element.t()
  defp move_message(state) when state.game_over do
    text(content: "Game Over!")
  end

  defp move_message(state) do
    text(content: "#{String.capitalize("#{state.player}")}'s move", color: state.player)
  end

  @spec board(State.t()) :: Garnish.Renderer.Element.t()
  defp board(state) do
    table do
      # column numbers row
      table_row do
        table_cell(content: " ")

        for i <- 1..columns() do
          table_cell(content: "#{i}")
        end
      end

      # column selector row
      # if waiting, dont show position selector
      table_row do
        table_cell(content: " ")

        if state.waiting do
          for _ <- 1..columns() do
            table_cell(content: " ")
          end
        else
          for i <- 1..columns() do
            content = if state.selected_column == i, do: "■", else: " "
            table_cell(content: content, color: :red)
          end
        end
      end

      # board rows

      for row <- rows()..1//-1 do
        table_row do
          table_cell(content: "#{row}")

          for col <- 1..columns() do
            player_color =
              case Board.get(state.board, {col, row}) do
                :empty -> :black
                p -> p
              end

            table_cell(content: "■", color: player_color)
          end
        end
      end
    end
  end
end
