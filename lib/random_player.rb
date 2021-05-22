class RandomPlayer

  attr_accessor :value
  attr_accessor :moves
  attr_accessor :stone

  def initialize
    @value = nil
    @stone = nil
    @moves = []
  end

  def select_move(board)
    board.possible_moves.sample
  end
end
