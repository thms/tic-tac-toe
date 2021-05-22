require 'test_helper'
require 'ruby-fann'

class TrainingTest < ActiveSupport::TestCase

  test "Should train the model" do

    inputs = [[1.0, 1.0, -1.0, -1.0, 1.0, 0, -1.0, -1.0, 0, 0,0,0,0,0,0,0,0,1.0],
    [1.0, 1.0, -1.0, -1.0, 1.0, 0, -1.0, -1.0, 0, 0,0,0,0,0,1.0,0,0,0]
    ]
    outputs = [[1.0], [-1.0]]
    train = RubyFann::TrainData.new(:inputs=>inputs, :desired_outputs=>outputs)
    fann = RubyFann::Standard.new(:num_inputs=>18, :hidden_neurons=>[12], :num_outputs=>1)
    fann.set_activation_function_hidden(:sigmoid_symmetric)
    fann.set_activation_function_output(:sigmoid_symmetric)
    fann.train_on_data(train, 1000, 10, 0.1)

    # Winning move
    output = fann.run [1.0, 1.0, -1.0, -1.0, 1.0, 0, -1.0, -1.0, 0, 0,0,0,0,0,0,0,0,1.0]
    puts output

    # losing final move
    output = fann.run [1.0, 1.0, -1.0, -1.0, 1.0, 0, -1.0, -1.0, 0, 0,0,0,0,0,1.0,0,0,0]
    puts output
    #assert_in_delta 1, output.first, 0.2

    # early move - indifferent
    output = fann.run [1.0, 0, 0, 0, -1.0, 0, 0, 0, 0, 0,0,0,0,0,1.0,0,0,0]
    puts output
    #assert_in_delta 0, output.first, 0.1

    # early move - indifferent
    output = fann.run [1.0, 0, 0, 0, -1.0, 0, 0, 0, 0, 0,0,0,0,0,1.0,0,0,0]
    puts output
    #assert_in_delta 0, output.first, 0.1
  end


end
