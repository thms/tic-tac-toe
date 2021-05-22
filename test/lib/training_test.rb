require 'test_helper'
require_relative './../../lib/training'

class TrainingTest < ActiveSupport::TestCase

  test "Should train the model" do
    training = Training.new(1)
    result = training.train
    assert_equal 0, result

    # should recognise the ability to win
    #output = training.eval([1.0, 1.0, -1.0, -1.0, 1.0, 0, -1.0, -1.0, 0, 1.0, 8])
    # Winning final move
    output = training.eval([[1.0, 1.0, -1.0, -1.0, 1.0, 0, -1.0, -1.0, 0], [0,0,0,0,0,0,0,0,1.0]].flatten)
    puts output

    # losing final move
    output = training.eval([[1.0, 1.0, -1.0, -1.0, 1.0, 0, -1.0, -1.0, 0], [0,0,0,0,0,1.0,0,0,0]].flatten)
    puts output
    #assert_in_delta 1, output.first, 0.2

    # another winning move
    output = training.eval([[0, -1.0, 1.0, 0, 1.0, 0, 0, -1.0, 0], [0,0,0,0,0,0,1.0,0,0]].flatten)
    puts output

    # another winning move
    output = training.eval([[0, -1.0, 1.0, 0, 1.0, 0, 0, -1.0, 0], [0,0,0,0,0,0,1.0,0,0]].flatten)
    puts output

    # early move - indifferent
    output = training.eval([[1.0, 0, 0, 0, -1.0, 0, 0, 0, 0], [0,0,0,0,0,1.0,0,0,0]].flatten)
    puts output
    #assert_in_delta 0, output.first, 0.1

    # early move - indifferent
    output = training.eval([[1.0, 0, 0, 0, -1.0, 0, 0, 0, 0], [0,0,0,0,0,1.0,0,0,0]].flatten)
    puts output
    #assert_in_delta 0, output.first, 0.1

    # early move - strong
    output = training.eval([[0, 0, 0, 0, 0, 0, 0, 0, 0], [0,0,0,0,1.0,0,0,0,0]].flatten)
    puts output
    #assert_in_delta 0, output.first, 0.1
  end


end
