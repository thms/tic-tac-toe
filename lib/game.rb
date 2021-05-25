require_relative './board'
class Game

  attr_accessor :board
  attr_accessor :player_one
  attr_accessor :player_two
  attr_accessor :winner

  STONES = {1.0 => 'x', -1.0 => 'o', 0 => ' '}
  def initialize(player_one, player_two, params = {display_output: false})
    @board = Board.new
    @player_one = player_one
    @player_one.stone = 'x'
    @player_one.value = 1.0
    @player_two = player_two
    @player_two.stone = 'o'
    @player_two.value = -1.0
    @current_player = @player_one
    @winner = nil
    @display_output = params[:display_output]
  end

  # returns all the board positions and moves as one array of arrays, and the final outcome (which can be a tie)
  def play
    log = []
    round = 1
    while round <= 9 && @winner.nil?
      log << make_move(@current_player)
      @winner = has_winner?
      puts "Win for #{@winner.stone}" if @winner && @display_output
      round += 1
      @current_player = @current_player == @player_one? @player_two : @player_one
    end
    outcome = has_winner? ? @winner.value : 0.0
    # append the outcome to each row of the log
    return log, outcome
  end

  # use a random strategy to place a stone
  def make_move(player)
    # clone the board state, becuase the training data must have the state before the  move and the move.
    previous_state = @board.state.clone
    position = player.select_move(@board)
    @board.state[position] = player.value
    player.moves << position
    puts "#{player.stone} set on #{position}" if @display_output
    move = [0] * 9
    move[position] = player.value
    return [previous_state, move].flatten
  end

  # determine if the current board presents a win, and for whom
  def has_winner?
    result = nil
    if @board.is_win?(1.0)
      result = @player_one
    elsif @board.is_win?(-1.0)
      result = @player_two
    end
    return result
  end

end
