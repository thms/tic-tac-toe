require 'test_helper'
require_relative './../../lib/min_max_player'

class MinMaxPlayerTest < ActiveSupport::TestCase

  test "should select winning move if only one left" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = [1.0, -1.0, 1.0 ,-1.0, 0,-1.0,1.0,-1.0,1.0]
    result = player.select_move(board)
    assert_equal({4 => 1.0}, result)
  end

  test "should create a draw if only one left" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = [1.0, 1.0, -1.0 ,-1.0, 1.0,1.0,0,-1.0,-1.0]
    result = player.select_move(board)
    assert_equal({6 => 0}, result)
  end

  test "should create a draw with two moves left" do
    player = MinMaxPlayer.new
    player.value = -1.0
    board = [1.0, 1.0, -1.0 ,-1.0, 1.0,1.0,0,0,-1.0]
    result = player.select_move(board)
    assert_equal({6 => 0}, result)
  end
end
