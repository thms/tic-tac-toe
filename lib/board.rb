# Represents a board,
# understand what a win looks like and can draw itself.
# stored as a linear array from 0..8
# empty position are 0
# players are +1 / -1
class Board

  WINNING_POSITIONS = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
  STONES = {1.0 => 'x', -1.0 => 'o', 0 => ' '}

  attr_accessor :state

  def initialize(state = nil)
    @state = state.nil? ? [0] * 9 : state
  end

  def is_win?(value)
    WINNING_POSITIONS.any? {|p| (@state[p[0]] + @state[p[1]] + @state[p[2]]) == value * 3}
  end

  # returns array of possible moves [2,4,7]
  def possible_moves
    @state.each_index.select {|i| @state[i] == 0}
  end

  def is_draw?
    @state.none?(0) && !is_win?(1.0) && !is_win?(-1.0)
  end

  def draw
    puts "#{STONES[@state[0]]} | #{STONES[@state[1]]} | #{STONES[@state[2]]}"
    puts "----------"
    puts "#{STONES[@state[3]]} | #{STONES[@state[4]]} | #{STONES[@state[5]]}"
    puts "----------"
    puts "#{STONES[@state[6]]} | #{STONES[@state[7]]} | #{STONES[@state[8]]}"
  end


end
