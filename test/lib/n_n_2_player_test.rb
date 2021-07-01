require 'test_helper'
require_relative './../../lib/t_q_player'
require_relative './../../lib/random_player'
require_relative './../../lib/min_max_player'
require_relative './../../lib/n_n_2_player'
require_relative './../../lib/board'
require_relative './../../lib/game'
require 'ruby_fann/neurotica'

class NN2PlayerTest < ActiveSupport::TestCase


  test "board_to_nn_inputs should map states correctly - all ones" do
    player = NN2Player.new
    state = [1.0] * 9
    result = player.board_to_nn_inputs(state)
    assert_equal [1.0] * 9, result
  end

  test "should learn from a number of games against the random player when going first" do
    # this gets to about 98% wins
    skip
    player_one = NN2Player.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
      player_one.update_neural_network(outcome)
    end
    puts "Training stats NN2:Random #{stats}"
    # should be very likely to win the next games
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
    end
    puts "Testing stats NN2:Random #{stats}"
  end

  test "should learn from a number of games against the random player when going second" do
    # this gets to about 75% of wins
    #skip
    player_one = NN2Player.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
      player_one.update_neural_network(outcome)
    end
    puts "Training stats Random:NN2 #{stats}"
    # should be very likely to win the next games
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
    end
    puts "Testing stats Random:NN2 #{stats}"
  end

end
