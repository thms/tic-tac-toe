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
    board.each_index.select {|i| board[i] == 0}.sample
  end
end
