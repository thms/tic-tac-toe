class Game

  WINNING_MOVES = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
  attr_accessor :board
  attr_accessor :player_one
  attr_accessor :player_two
  attr_accessor :winner

  STONES = {1.0 => 'x', -1.0 => 'o', 0 => ' '}
  def initialize(player_one, player_two, params = {display_output: false})
    #@board = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    @board = [0] * 9
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
    log
    return log, outcome
  end

  # use a random strategy to place a stone
  def make_move(player)
    previous_board = @board.clone
    position = player.select_move(@board)
    @board[position] = player.value
    player.moves << position
    puts "#{player.stone} set on #{position}" if @display_output
    # old version: board, player and move does not perform well
    # return [@board, player[:value], position].flatten
    move = [0] * 9
    move [position] = player.value
    return [previous_board, move].flatten
  end

  # determine if the current board presents a win, and for whom
  def has_winner?
    result = nil
    if WINNING_MOVES.any? {|position| (position - @player_one.moves).empty?}
      result = @player_one
    elsif WINNING_MOVES.any? {|position| (position - @player_two.moves).empty?}
      result = @player_two
    end
    return result
  end

  def draw_board
    puts "#{STONES[@board[0]]} | #{STONES[@board[1]]} | #{STONES[@board[2]]}"
    puts "----------"
    puts "#{STONES[@board[3]]} | #{STONES[@board[4]]} | #{STONES[@board[5]]}"
    puts "----------"
    puts "#{STONES[@board[6]]} | #{STONES[@board[7]]} | #{STONES[@board[8]]}"
  end
end
# Play a game and disaply the output
# game = Game.new(display_out: true)
# game.play
# game.draw_board
