require 'test_helper'
require_relative './../../lib/t_q_player'
require_relative './../../lib/random_player'
require_relative './../../lib/board'
require_relative './../../lib/game'

class TQPlayerTest < ActiveSupport::TestCase

  test "should select random move if no learning yet" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 0, 0 ,0, 0,0,0,0,0]
    result = player.select_move(board)
    assert_includes 0..8, result
  end

  test "should select only available move if no learning yet" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 1.0, -1.0 ,1.0, -1.0,1.0,-1.0,1.0, -1.0]
    result = player.select_move(board)
    assert_equal 0, result
  end

  test "should select best move with forced training" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 0, 0 ,0, 0,0,0,0,0]
    player.q_table[board.hash_value] = [0,0,0,1,0,0,0,0,0]
    result = player.select_move(board)
    assert_equal 3, result
  end

  test "should select randomly best move with forced training" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 0, 0 ,0, 0,0,0,0,0]
    player.q_table[board.hash_value] = [0,0,0.5,0,0,0.5,0,0,0]
    result = player.select_move(board)
    assert_includes [2,5], result
  end

  test "should update q_table after one game" do
    player = TQPlayer.new
    player.value = 1.0
    log = []
    board = Board.new [0,0,0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 0]
    board.state = [1.0,0,0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, -1.0, 1]
    board.state = [1.0,-1.0,0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 2]
    board.state = [1.0,-1.0,1.0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, -1.0, 3]
    board.state = [1.0,-1.0,1.0,-1.0,0,0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 4]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,0,0,0,0]
    log << [board.hash_value, board.state, -1.0, 5]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,-1.0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 6]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,0,0]
    log << [board.hash_value, board.state, -1.0, 7]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,0]
    log << [board.hash_value, board.state, 1.0, 8]
    player.update_q_table(log, 1.0)
    assert_equal 0.96, player.q_table[board.hash_value][8]
  end

  test "should learn from a number of games against the random player when going first" do
    skip
    player_one = TQPlayer.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_one, player_two
      log, outcome = game.play
      stats[outcome] += 1
      # use players own log to train the table
      player_one.update_q_table(player_one.log, (outcome + 1.0)/2.0)
      # game.board.draw
    end
    puts "Training stats #{stats}"
    # should be very likely to win the next games
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_one, player_two
      log, outcome = game.play
      stats[outcome] += 1
    end
    assert_operator 15, :>, stats[-1.0]
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the random player when going second" do
    player_one = TQPlayer.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    # seems going second it needs more training to get good at the game
    5000.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
      # use players own log to train the table
      player_one.update_q_table(player_one.log, ( 1.0 - outcome)/2.0)
      #game.board.draw
    end
    puts "Training stats #{stats}"
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
    end
    assert_operator 15, :>, stats[1.0]
    puts "Testing stats #{stats}"
  end
end
