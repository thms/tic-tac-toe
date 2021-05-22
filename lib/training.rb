#
require 'ruby-fann'
require_relative './game'
require_relative './random_player'


class Training
  DISCOUNT = 0.7
  DISCOUNTED_REWARDS = ([1] * 9).map.with_index {|d, i| d * DISCOUNT ** i }

  attr_accessor :inputs
  attr_accessor :outputs
  attr_accessor :iterations
  attr_accessor :train
  attr_accessor :fann
  attr_accessor :player_one
  attr_accessor :player_two

  def initialize(iterations = 100)
    @inputs = []
    @outputs = []
    @iterations = iterations
    @train = nil
    @fann = nil
    @player_one = RandomPlayer.new
    @player_two = RandomPlayer.new
  end

  def train
    iterations.times do
      game = Game.new @player_one, @player_two
      log, outcome = game.play
      # Need to discount the earlier move, and only give the full reward / punishment for the very last move
      output = DISCOUNTED_REWARDS[0..log.size-1].reverse.map{|r| [r * outcome]}
      # need to flip every second row in the log and outcome, so that the data is only from one players view
      log.each_index do |index|
        if index.odd?
          output[index] = [- output[index].first]
          for i in 0..17 do
            log[index][i] = - log[index][i]
          end
        end
      end
      @inputs << log
      @outputs << output
    end
    @inputs.flatten!(1)
    @outputs.flatten!(1)
    # puts @inputs.size
    # puts @outputs.size
    #
    # pp @inputs
    # pp @outputs

    # Prepare training data
    @train = RubyFann::TrainData.new(:inputs=>@inputs, :desired_outputs=>@outputs)

    # Create a model
    @fann = RubyFann::Standard.new(:num_inputs=>18, :hidden_neurons=>[12], :num_outputs=>1)
    @fann.set_activation_function_hidden(:sigmoid_symmetric)
    @fann.set_activation_function_output(:sigmoid_symmetric)

    # Train 1000 max_epochs, 10 errors between reports and 0.1 desired MSE (mean-squared-error)
    @fann.train_on_data(@train, 1000, 10, 0.05)
  end

  def eval(input)
    fann.run(input)
  end
end
