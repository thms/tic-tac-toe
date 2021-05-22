class MinMaxPlayer

  attr_accessor :value
  attr_accessor :moves
  attr_accessor :stone
  attr_accessor :cache
  WINNING_POSITIONS = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]

  def initialize
    @value = nil
    @stone = nil
    @moves = []
    @cache = {}
  end

  def select_move(board)
    one_round(board, @value)
  end

  def one_round(board, value)
    possible_moves = board.each_index.select {|i| board[i] == 0}
    moves = {}
    possible_moves.each do |move|
      # make the move, test for a win / draw, if so, mark move as win/draw and return reward, otherwise run one round from here and propagate result back up.
      new_board = board.clone
      new_board[move] = value
      if is_win?(new_board, value)
        # mark a win (for the current mover, might be the opponent)
        moves[move] = value
      elsif is_draw?(new_board)
        # mark a draw
        moves[move] = 0
      else
        # iterate into the future for the other player
        moves[move] = one_round(new_board, -value)
      end
      return moves
    end
  end

  def is_win?(board, value)
    WINNING_POSITIONS.any? {|p| (board[p[0]] + board[p[1]] + board[p[2]]) == value * 3}
  end

  def is_draw?(board)
    board.none?(0)
  end

end
