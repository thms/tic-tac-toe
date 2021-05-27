# Player that learns to mimic the Q function via a neural network
# with significantly less storage space
# Also learns as it goes along and plays the game.
# since it mimics the Q function the network has as many inputs as the board state
# board state can be represented either as [-1|0|1] *9 like we have used before or
# as 9 inputs for crosses, 9 for naughts, and nine for empty pieces - we'll try both ways.
# and 9 outputs, one for each move
# for the Q values we calculate the updates
require 'ruby-fann'

class NNPlayer

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
  attr_accessor :use_experience_replay
  attr_accessor :experience_replay_log
  attr_accessor :games_played
  attr_accessor :temperature # temparature for softmax

  def initialize(random = false)
    @value = nil
    @stone = nil
    @moves = []
    @action_log = []
    @state_log = []
    @q_values_log = []
    @next_q_max_log = []
    @use_experience_replay = true
    @experience_replay_log = []
    @games_played = 0
    @temperature = 1.0
    @random = random
    @fann = RubyFann::Standard.new(:num_inputs=>27, :hidden_neurons=>[243], :num_outputs=>9)
    @fann.set_learning_rate(0.1) # default value is 0.7
    @fann.set_training_algorithm(:incremental)
    @fann.set_activation_function_layer(:relu, 1)
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
    probabilities = softmax(q_values)
    # reject all moves that are not possible according to the board by setting their probability to 0
    probabilities.map!.with_index {|v, i| possible_moves.include?(i) ? v : 0}
    # pick move with highest value that is possible from the moves that are possible
    max_probability = probabilities.max
    # find all moves that have the highest value, and pick one of them
    # turn into using probability band
    move = probabilities.map.with_index {|v, i| max_probability <= 1.01 * v ? i : nil}.compact.sample

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
    index = @action_log.size - 1
    while index >= 0
      inputs = board_to_nn_inputs(@state_log[index])
      outputs = @q_values_log[index]
      # replace the q value of the move made with the discounted observation
      outputs[@action_log[index]] = DISCOUNT * @next_q_max_log[index]
      # do one training step
      @fann.train(inputs, outputs)
      index -= 1
    end
    # append the logs to the experience replay log and shift out if size is reached.
    @games_played += 1
    @experience_replay_log << {next_q_max: @next_q_max_log, state: @state_log, q_values: @q_values_log, actions: @action_log}
    @experience_replay_log.shift if @experience_replay_log.size > 2000
    # and finally reset the logs after one round of learning (so after each game)
    reset_logs
    experience_replay if @games_played.modulo(1000) == 0 && @use_experience_replay
  end

  # update training based on a random sample of experiences
  def experience_replay
    @experience_replay_log.sample(500).each do |entry|
      @action_log = entry[:actions]
      @next_q_max_log = entry[:next_q_max]
      @state_log = entry[:state]
      @q_values_log = entry[:q_values]
      index = @action_log.size - 1
      while index >= 0
        inputs = board_to_nn_inputs(@state_log[index])
        outputs = @q_values_log[index]
        # replace the q value of the move made with the discounted observation
        outputs[@action_log[index]] = DISCOUNT * @next_q_max_log[index]
        # do one training step
        @fann.train(inputs, outputs)
        index -= 1
      end
    end
  end

  # translate compact board state to 3*9
  # -1 0 +1 for each position come right after each other
  def board_to_nn_inputs(state)
    result = [0] * 27
    state.each.with_index {|v, i| result[3 * i + v + 1] = 1.0}
    result
  end

  # normalizes the output q-values so they can be used as probabilities
  # temperature: 0..infinity, for high temperatures nearly all probabilities are the same, for low 0+eplsilon, the
  # probability of the highet value approaches 1
  # https://en.wikipedia.org/wiki/Softmax_function
  # Use higher temperature steer how exploratory the player will be by picking from a set of possible actions within a band of probability
  def softmax(values)
    denominator = values.collect {|v| Math.exp(v / @temperature)}.reduce(:+)
    values.collect {|v| Math.exp(v / @temperature) / denominator}
  end
end
