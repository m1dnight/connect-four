defmodule Counter do
  @behaviour Ratatouille.App

  import Ratatouille.View
  alias Ratatouille.Runtime.Command

  alias C4.Board
  alias C4.Solver

  import C4.Constants

  def init(_context), do: %{board: Board.new(), position: 1, waiting: false, game_over: false}

  def update(model, msg) do
    case msg do
      {:ai_move, move} ->
        board = Board.put(model.board, move.position, :yellow)

        if Board.winner?(board) do
          %{model | game_over: true, board: board}
        else
          %{model | board: board, waiting: false}
        end

      {:event, %{key: 65514}} ->
        Map.update!(model, :position, &min(&1 + 1, columns()))

      {:event, %{key: 65515}} ->
        Map.update!(model, :position, &max(0, &1 - 1))

      {:event, %{key: 32}} ->
        # determine column
        position =
          Board.playable_positions(model.board)
          |> Enum.filter(fn {col, _row} -> col == model.position end)
          |> List.first()

        if position != nil and model.waiting == false do
          board = Board.put(model.board, position, :red)

          if Board.winner?(board) do
            %{model | game_over: true, board: board}
          else
            # enemy plays
            cmd =
              Command.new(fn -> Solver.minimax(board, :yellow) end, :ai_move)

            {%{model | board: board, waiting: true}, cmd}
          end
        else
          model
        end

      _ ->
        model
    end
  end

  def render(state) do
    view do
      row do
        column size: 4 do
          panel do
              cond do
                state.game_over -> label(content: "Game Over")
                state.waiting -> label(content: "Thining...")
                true -> label(content: "")
              end
          end
        end
      end

      row do
        column size: 4 do
          panel title: "Board" do
            table do
              table_row do
                table_cell(content: " ")

                for i <- 1..columns() do
                  table_cell(content: "#{i}")
                end
              end

              table_row do
                table_cell(content: " ")
                for i <- 1..columns() do
                  if state.waiting do
                    table_cell(content: " ")
                  else
                    content = if state.position == i, do: "■", else: " "
                    table_cell(content: content, color: :red)
                  end
                end
              end

              for row <- rows()..1//-1 do
                table_row do
                  table_cell(content: "#{row}")

                  for col <- 1..columns() do
                    color =
                      case Board.get(state.board, {col, row}) do
                        :empty -> :black
                        p -> p
                      end

                    table_cell(content: "■", color: color)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
