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
    player.temperature = 0.001
    result = player.softmax(input)
    assert_in_delta 1, result[0], 0.001
    assert_in_delta 0, result[1], 0.001
    assert_in_delta 0, result[2], 0.001
  end

  test "softmax should be very similar for an array where only one value is set and high temerature" do
    player = NNPlayer.new
    input = [0.5, 0, 0]
    player.temperature = 1000
    result = player.softmax(input)
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
    # this gets to about 95% wins
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
    #assert_operator 10, :>, stats[-1.0]
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the random player when going second" do
    # this gets to about 80% wins with and without experience replay ...
    skip
    puts 'Random : NN'
    player_one = NNPlayer.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    player_one.epsilon = 1.1
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
    player_one.epsilon = 1.0
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
    # so this gets to about 100% draws after 10k games
    player_one = NNPlayer.new
    player_two = MinMaxPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
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
    #assert_equal 100, stats[0.0]
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the min max player when going second" do
    skip
    # best we can hope for is that NN learns how to get to a draw
    # after about 1 million training games, which takes about 3 minutes to train, he gets to 100% draws
    player_one = NNPlayer.new
    player_two = MinMaxPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
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

  test "should learn from a number of games against random and min max player when going first and second" do
    skip
    # best we can hope for is that NN learns how to get to a draw
    # after about 1 million training games, which takes about 3 minutes to train, he gets to 100% draws
    player_one = NNPlayer.new
    player_two = MinMaxPlayer.new
    player_three = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    player_one.temperature = 1.0
    50000.times do
      log, outcome = Game.new(player_one, player_two).play
      player_one.update_neural_network(outcome)
      stats[outcome] += 1
      log, outcome = Game.new(player_two, player_one).play
      player_one.update_neural_network(outcome)
      stats[outcome] += 1
      # log, outcome = Game.new(player_one, player_three).play
      # player_one.update_neural_network(outcome)
      # stats[outcome] += 1
      # log, outcome = Game.new(player_three, player_one).play
      # player_one.update_neural_network(outcome)
      # stats[outcome] += 1
    end
    puts "Training stats #{stats}"
    # should be very likely to win the next games
    stats_1_2 = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    stats_2_1 = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    stats_1_3 = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    stats_3_1 = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    player_one.temperature = 0.1
    100.times do
      log, outcome = Game.new(player_one, player_two).play
      stats_1_2[outcome] += 1
      log, outcome = Game.new(player_two, player_one).play
      stats_2_1[outcome] += 1
      log, outcome = Game.new(player_one, player_three).play
      stats_1_3[outcome] += 1
      log, outcome = Game.new(player_three, player_one).play
      stats_3_1[outcome] += 1
    end
    puts "Testing stats NN:MinMax #{stats_1_2}"
    puts "Testing stats MinMax:NN #{stats_2_1}"
    puts "Testing stats NN:Random #{stats_1_3}"
    puts "Testing stats Random:NN #{stats_3_1}"
  end

end
