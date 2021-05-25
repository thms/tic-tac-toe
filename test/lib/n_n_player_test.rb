require 'test_helper'
require_relative './../../lib/t_q_player'
require_relative './../../lib/random_player'
require_relative './../../lib/min_max_player'
require_relative './../../lib/n_n_player'
require_relative './../../lib/board'
require_relative './../../lib/game'

class NNPlayerTest < ActiveSupport::TestCase

  test "softmax should be 1 and all zeros for an array where only one value is set at low temperature" do
    player = NNPlayer.new
    input = [0.5, 0, 0]
    result = player.softmax(input, 0.001)
    assert_in_delta 1, result[0], 0.001
    assert_in_delta 0, result[1], 0.001
    assert_in_delta 0, result[2], 0.001
  end

  test "softmax should be very similar for an array where only one value is set and high temerature" do
    player = NNPlayer.new
    input = [0.5, 0, 0]
    result = player.softmax(input, 1000)
    assert_in_delta 0.333, result[0], 0.001
    assert_in_delta 0.333, result[1], 0.001
    assert_in_delta 0.333, result[2], 0.001
  end

  test "board_to_nn_inputs should map states correctly - all ones" do
    player = NNPlayer.new
    state = [1.0] * 9
    result = player.board_to_nn_inputs(state)
    assert_equal [0,0,1] * 9, result
  end

  test "board_to_nn_inputs should map states correctly - all minus ones" do
    player = NNPlayer.new
    state = [- 1.0] * 9
    result = player.board_to_nn_inputs(state)
    assert_equal [1,0,0] * 9, result
  end

  test "board_to_nn_inputs should map states correctly - mixed" do
    player = NNPlayer.new
    state = [- 1.0, 0, 1.0, 0,0,0,0,0,0]
    result = player.board_to_nn_inputs(state)
    assert_equal [1,0,0,0,1,0,0,0,1,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0], result
  end

  test "should select random move if no learning yet" do
    player = NNPlayer.new
    player.value = 1.0
    board = Board.new [0, 0, 0 ,0, 0,0,0,0,0]
    result = player.select_move(board)
    assert_includes 0..8, result
  end

  test "should select only available move if no learning yet" do
    player = NNPlayer.new
    player.value = 1.0
    board = Board.new [0, 1.0, -1.0 ,1.0, -1.0,1.0,-1.0,1.0, -1.0]
    result = player.select_move(board)
    assert_equal 0, result
  end


  test "NNPlayer should adjust network after each game" do
    player_one = NNPlayer.new
    player_two = RandomPlayer.new
    game = Game.new player_one, player_two
    log, outcome = game.play
    player_one.update_neural_network(outcome)
  end

  test "should learn from a number of games against the random player when going first" do
    skip
    puts 'NN : Random'
    player_one = NNPlayer.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_one, player_two
      log, outcome = game.play
      stats[outcome] += 1
      # use players own log to train the table
      player_one.update_neural_network(outcome)
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
    assert_operator 10, :>, stats[-1.0]
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the random player when going second" do
    skip
    puts 'Random : NN'
    player_one = NNPlayer.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
      # use players own log to train
      player_one.update_neural_network(outcome)
    end
    puts "Training stats #{stats}"
    # should be very likely to win the next games
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
    end
    #assert_operator 10, :>, stats[-1.0]
    puts "Testing stats #{stats}"
    #puts [player_one.q_values_log.inspect]
  end

  test "should learn from a number of games against the min max player when going first" do
    skip
    # so this gets to about 200% draws after 10k games
    player_one = NNPlayer.new
    player_two = MinMaxPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_one, player_two
      log, outcome = game.play
      stats[outcome] += 1
      # use players own log to train the table
      player_one.update_neural_network(outcome)
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
    assert_equal 100, stats[0.0]
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the min max player when going second" do
    #skip
    # best we can hope for is that NN learns how to get to a draw (and he does after about 1 million games)
    player_one = NNPlayer.new
    player_two = MinMaxPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000000.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
      # use players own log to train the table
      player_one.update_neural_network(outcome)
    end
    puts "Training stats #{stats}"
    # should be very likely to win the next games
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
    end
    #assert_equal 100, stats[0.0]
    puts "Testing stats #{stats}"
  end

end
