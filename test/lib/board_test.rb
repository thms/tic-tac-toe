require 'test_helper'
require 'ruby-fann'
require_relative './../../lib/board'

class BoardTest < ActiveSupport::TestCase

  test "should initialize state to zero" do
    board = Board.new
    assert_equal [0] * 9,  board.state
  end

  test "should recognize winning position" do
    board = Board.new
    board.state[0] = 1.0
    board.state[1] = 1.0
    board.state[2] = 1.0
    assert_equal true, board.is_win?(1.0)
  end

  test "should draw the board" do
    board = Board.new
    board.state[0] = 1.0
    board.state[1] = 1.0
    board.state[2] = 1.0
    board.draw
  end

  test "should return possible moves" do
    board = Board.new
    board.state[0] = 1.0
    board.state[1] = 1.0
    board.state[2] = 1.0
    possible_moves = board.possible_moves
    assert_equal [3,4,5,6,7,8], possible_moves
  end

  test "should recognize a draw" do
    board = Board.new
    board.state = [1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0]
    board.draw
    assert_equal true, board.is_draw?
  end


  test "neural network should be able to learn the winning positions" do
    skip
    # generate training data by randomly placing stones unitl either a draw or win results
    inputs = []
    outputs = []
    1000.times do
      board = Board.new
      value = 1.0
      index = 0
      while index < 9 && !board.is_win?(1.0) && !board.is_win?(-1.0)
        board.state[board.possible_moves.sample] = value
        value = -value
        index += 1
      end
      inputs << board.state
      outputs << [board.is_win?(1.0) ? 1.0 : 0.0, board.is_win?(-1.0) ? 1.0 : 0.0, board.is_draw? ? 1.0 : 0.0]
    end
    train = RubyFann::TrainData.new(:inputs=>inputs, :desired_outputs=>outputs)
    # setup of the network: each winning position is a straight forward linear combination of the
    # state of the board, so with the number of hidden neurons == number of winning positions
    # we should be able to train this to be accurate
    fann = RubyFann::Standard.new(:num_inputs=>9, :hidden_neurons=>[8], :num_outputs=>3)
    fann.set_activation_function_hidden(:sigmoid)
    fann.train_on_data(train, 1000, 10, 0.01)

    # We are setting the activation function on the output to threshold after training, cannot train with it
    # Because the three outcomes are mutually exclusive
    fann.set_activation_function_output(:threshold)

    # test if this worked correctly:
    10.times do
      board = Board.new
      value = 1.0
      index = 0
      while index < 9 && !board.is_win?(1.0) && !board.is_win?(-1.0)
        board.state[board.possible_moves.sample] = value
        value = -value
        index += 1
      end
      board.state
      output = [board.is_win?(1.0) ? 1.0 : 0.0, board.is_win?(-1.0) ? 1.0 : 0.0, board.is_draw? ? 1.0 : 0.0]
      result = fann.run board.state
      board.draw
      puts result
      puts output
      puts '------'
      assert_equal output, result
    end
  end
end
