require 'test_helper'
require_relative './../../lib/min_max_player'
require_relative './../../lib/board'

class MinMaxPlayerTest < ActiveSupport::TestCase

  test "should select winning move if only one left" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = Board.new [1.0, -1.0, 1.0 ,-1.0, 0,-1.0,1.0,-1.0,1.0]
    result = player.one_round(board, player.value)
    assert_equal({4 => 1.0}, result)
  end

  test "should create a draw if only one left" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = Board.new [1.0, 1.0, -1.0 ,-1.0, 1.0,1.0,0,-1.0,-1.0]
    result = player.one_round(board, player.value)
    assert_equal({6 => 0}, result)
  end

  test "should create a draw with two moves left" do
    player = MinMaxPlayer.new
    player.value = -1.0
    board = Board.new [1.0, 1.0, -1.0 ,-1.0, 1.0,1.0,0,0,-1.0]
    result = player.one_round(board, player.value)
    assert_equal({7 => 0}, result)
  end

  test "should create a loss with three moves left" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = Board.new [-1.0, 0, -1.0 ,-1.0, 1.0,1.0,0,0,1.0]
    result = player.one_round(board, player.value)
    assert_equal({7 => -1.0}, result)
  end

  test "should create a draw with three moves left" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = Board.new [1.0, 0, -1.0 ,-1.0, 1.0,1.0,0,0,-1.0]
    result = player.one_round(board, player.value)
    assert_equal({7 => 0}, result)
  end

  test "must block immeditate winning move do" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = Board.new [1.0, 0, 0 ,1.0, -1.0,0,-1.0,0,0]
    result = player.one_round(board, player.value)
    assert_equal({2 => 0}, result)
  end

  test "next move 1" do
    player = MinMaxPlayer.new
    player.value = -1.0
    board = Board.new [1.0, 0, 1.0 ,1.0, -1.0,0,-1.0,0,0]
    result = player.one_round(board, player.value)
    assert_equal({1 => 0}, result)
  end

  test "next move 2" do
    player = MinMaxPlayer.new
    player.value = 1.0
    board = Board.new [1.0, -1.0, 1.0 ,1.0, -1.0,0,-1.0,0,0]
    result = player.one_round(board, player.value)
    assert_equal({7 => 0}, result)
  end

end
