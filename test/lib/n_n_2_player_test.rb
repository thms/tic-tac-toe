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
    # this gets to about 95% wins
    skip
    puts 'NN2 : Random'
    player_one = NN2Player.new
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
    RubyFann::Neurotica.new.graph(player_one.fann, './../../network.png')
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
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the random player when going second" do
    # this does not seem to learn well at all
    #skip
    puts 'NN2 : Random'
    player_one = NN2Player.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
      # use players own log to train the table
      player_one.update_neural_network(outcome)
      # game.board.draw
    end
    puts "Training stats #{stats}"
    #RubyFann::Neurotica.new.graph(player_one.fann, './../../network.png')
    # should be very likely to win the next games
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      player_one.moves = []
      player_two.moves = []
      game = Game.new player_two, player_one
      log, outcome = game.play
      stats[outcome] += 1
    end
    puts "Testing stats #{stats}"
  end

end
