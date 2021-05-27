# Same as N_N but with a different topology
# input: 9x, +1, 0, -1 as inputs
# hidden: 8 (one for each winning / losing combination), linear activation
# output: 9x, one for each move, but connected to both other layers
# ==> Works well for going first, but also does not get better than 80% wins for going second

require 'ruby-fann'

class NN2Player

  DISCOUNT = 0.95
  LEARNING_RATE = 0.1
  attr_accessor :value
  attr_accessor :moves # stores the player's moves (but done from the game so this mae by too late for what we need)
  attr_accessor :stone
  attr_accessor :random # if true, player picks randomly from available equally well performing moves
  attr_accessor :action_log # stores the moves the player makes state
  attr_accessor :state_log # stores the board state
  attr_accessor :q_values_log # stores the q values as calucated by the NN before the move is made
  attr_accessor :next_q_max_log # stores the max Q of the next state, and the final reward
  attr_accessor :log
  attr_accessor :fann

  def initialize(random = false)
    @value = nil
    @stone = nil
    @moves = []
    @action_log = []
    @state_log = []
    @q_values_log = []
    @next_q_max_log = []
    @log = []
    @random = random
    @fann = RubyFann::Shortcut.new(:num_inputs=>9, :hidden_neurons=>[8], :num_outputs=>9)
    @fann.set_learning_rate(0.1) # default value is 0.7
    @fann.set_training_algorithm(:incremental)
    @fann.set_activation_function_hidden(:linear)
  end

  def reset_logs
    @moves = []
    @action_log = []
    @state_log = []
    @q_values_log = []
    @next_q_max_log = []
  end

  # Given a board, pick the next best move
  def select_move(board)
    possible_moves = board.possible_moves

    state = board_to_nn_inputs(board.state)
    # run the network and pass the qvalues through softmax
    q_values = @fann.run(state)
    probabilities = softmax(q_values, 1)
    # reject all moves that are not possible according to the board by setting their value to nil
    probabilities.map!.with_index {|v, i| possible_moves.include?(i) ? v : -100}
    # pick move with highest value that is possible from the moves that are possible
    highest_value = probabilities.max
    # find all moves that have the highest value, and pick one of them
    # TODO: turn into using probability band
    move = probabilities.map.with_index {|v, i| highest_value == v ? i : nil}.compact.sample

    # Log data for training at the end of the game
    @next_q_max_log << q_values[move] unless @action_log.empty?
    @state_log << board.state.clone
    @q_values_log << q_values.clone
    @action_log << move
    return move
  end

  # Update the network with the outcome of a single game
  # For each observation = board state and q_values where only the one of the move actually taken is updated
  # run one iteration of the training
  def update_neural_network(outcome)
    # push the final reward onto the nextmax log from the point of view of the player
    @next_q_max_log << (@value * outcome + 1.0)/2.0
    @log << @next_q_max_log
    @log << ['--']
    index = @moves.size - 1
    while index >= 0
      inputs = board_to_nn_inputs(@state_log[index])
      outputs = @q_values_log[index]
      # replace the q value of the move made with the discounted observation
      outputs[@moves[index]] = DISCOUNT * @next_q_max_log[index]
      # do one training step
      @fann.train(inputs, outputs)
      index -= 1
    end
    # and finally reset the logs after one round of learning (so after each game)
    reset_logs
  end

  # 1;1 passthrough translate compact board state to 9
  def board_to_nn_inputs(state)
    state
  end

  # normalizes the output q-values so they can be used as probabilities
  # temperature: 0..infinity, for high temperatures nearly all probabilities are the same, for low 0+eplsilon, the
  # probability of the highet value approaches 1
  # https://en.wikipedia.org/wiki/Softmax_function
  # Use higher temperature steer how exploratory the player will be by picking from a set of possible actions within a band of probability
  def softmax(values, temperature = 1)
    denominator = values.collect {|v| Math.exp(v / temperature)}.reduce(:+)
    values.collect {|v| Math.exp(v/temperature) / denominator}
  end
end
