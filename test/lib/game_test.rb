require 'test_helper'
require_relative './../../lib/game'
require_relative './../../lib/random_player'

class GameTest < ActiveSupport::TestCase

  test "Set up board should result in zeros everywhere" do
    player_one = RandomPlayer.new
    player_two = RandomPlayer.new
    game = Game.new player_one, player_two
    assert_equal [0] * 9, game.board.state
  end

  test 'should recognize winning combination' do
    player_one = RandomPlayer.new
    player_two = RandomPlayer.new
    game = Game.new player_one, player_two
    game.board.state = [1,1,1,0,0,0,0,0,0]
    game.player_one.moves << 0
    game.player_one.moves << 1
    game.player_one.moves << 2

    assert_equal game.player_one, game.has_winner?
  end

  test 'random move should change the board to one 1' do
    player_one = RandomPlayer.new
    player_two = RandomPlayer.new
    game = Game.new player_one, player_two
    game.make_move(game.player_one)
    assert_equal 1, game.board.state.sum
    game.board.draw
  end
end
