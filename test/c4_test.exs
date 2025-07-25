# defmodule C4Test do
#   use ExUnit.Case
#   doctest C4

#   alias C4.Solver
#   alias C4.Board

#   test "score board one winning move away" do
#     board =
#       """
#       | | | | | | |
#       | | | | | | |
#       | | | | | | |
#       | | | | | | |
#       |y| | | | | |
#       |y| | | | | |
#       |y| | | | | |
#       """
#       |> Board.parse()

#     assert 100.0 == Solver.score_board(board, :yellow)
#   end

#   test "score board opponent can win with one move" do
#     board =
#       """
#       | | | | | | |
#       | | | | | | |
#       | | | | | | |
#       | | | | | | |
#       |y| | | | | |
#       |y| | | | | |
#       |y| | | | | |
#       """
#       |> Board.parse()

#     # there are 5 possible moves, but the opponent will win for four moves
#     assert -500.0 == Solver.score_board(board, :red)
#   end

#   # test "winning moves, singular" do
#   #   board =
#   #     """
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     |y| | | | | |
#   #     |y| | | | | |
#   #     |y| | | | | |
#   #     """
#   #     |> Board.parse()

#   #   assert [{1, 4}] == Solver.winning_moves(board, :yellow)
#   # end

#   # test "winning moves, multiple" do
#   #   board =
#   #     """
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     |y|y| | | | |
#   #     |y|y| | | | |
#   #     |y|y| | | | |
#   #     """
#   #     |> Board.parse()

#   #   assert [{1, 4}, {2, 4}] == Solver.winning_moves(board, :yellow)
#   # end

#   # test "losing moves, none" do
#   #   board = Board.new()

#   #   assert [] == Solver.losing_moves(board, :red)
#   # end

#   # test "losing moves, singular" do
#   #   board =
#   #     """
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     |r|r|r| | | |
#   #     |y|y|r| | | |
#   #     """
#   #     |> Board.parse()

#   #   assert [{4, 1}] == Solver.losing_moves(board, :yellow)
#   # end

#   # test "figure out best move" do
#   #   board =
#   #     """
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     |y|y|y| | | |
#   #     """
#   #     |> Board.parse()

#   #   moves_to_make = Board.playable_positions(board) |> tap(&IO.inspect(&1, label: ""))

#   #   # compute the score for each move
#   #   best_move =
#   #     moves_to_make
#   #     |> Enum.map(fn position ->
#   #       score =
#   #         board
#   #         |> Board.put(position, :yellow)
#   #         |> Solver.score_board(:yellow)

#   #       {score, position}
#   #     end)
#   #     |> Enum.sort_by(&elem(&1, 0), :desc)
#   #     |> hd()

#   #   assert {_, {4, 1}} = best_move
#   # end

#   # test "figure out best move 2" do
#   #   board =
#   #     """
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     | | | | | | |
#   #     |r| | | | | |
#   #     |y|y| | | | |
#   #     """
#   #     |> Board.parse()

#   #   moves_to_make = Board.playable_positions(board) |> tap(&IO.inspect(&1, label: ""))

#   #   # compute the score for each move
#   #   best_move =
#   #     moves_to_make
#   #     |> Enum.map(fn position ->
#   #       score =
#   #         board
#   #         |> Board.put(position, :yellow)
#   #         |> Solver.score_board(:yellow)

#   #       {score, position}
#   #     end)
#   #     |> Enum.sort_by(&elem(&1, 0), :desc)
#   #     |> hd()

#   #   assert {_, {3, 1}} = best_move
#   # end
# end
