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
    one_round(board, @value).keys.first
  end

  # returns best outcome move and value for the current player
  # {4 => 1.0}
  def one_round(board, value)
    possible_moves = board.possible_moves
    puts "#{value}, #{possible_moves}"
    moves = {}
    possible_moves.each do |move|
      puts "Evaluating move #{move} for player #{value}"
      # make the move, test for a win / draw, if so, mark move as win/draw and return reward, otherwise run one round from here and propagate result back up.
      new_board = deep_clone(board)
      new_board.state[move] = value
      if is_win?(new_board.state, value)
        # mark a win (for the current mover, might be the opponent)
        moves[move] = value
      elsif is_draw?(new_board.state)
        # mark a draw
        moves[move] = 0
      else
        # iterate into the future for the other player
        moves[move] = one_round(new_board, -1.0 * value).values.first
      end
      puts moves
    end
    # evaluate moves to determine the best possible move and only return that
    puts "moves: #{moves}"
    if moves.size > 1
      return [moves.sort_by {|k, v| v}.last].to_h if value == 1.0
      return [moves.sort_by {|k, v| v}.first].to_h if value == -1.0
    else
      return moves
    end
  end

  def is_win?(board, value)
    WINNING_POSITIONS.any? {|p| (board[p[0]] + board[p[1]] + board[p[2]]) == value * 3}
  end

  def is_draw?(board)
    board.none?(0) && !is_win?(board, 1.0) && !is_win?(board, -1.0)
  end

  def deep_clone(object)
    Marshal.load(Marshal.dump(object))
  end
end
