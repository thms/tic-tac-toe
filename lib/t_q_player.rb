# Tabular quality function player
# uses a hash to build up the quallity function as it plays against others.
# we'll iniitialize the q_table as the player plays, to muach hassle to do it up front
class TQPlayer

  attr_accessor :q_table
  attr_accessor :value
  attr_accessor :moves
  attr_accessor :stone
  attr_accessor :random # if true, player picks randomly from available equally well performing moves
  attr_accessor :log

  def initialize(random = false)
    @value = nil
    @stone = nil
    @moves = []
    @q_table = {}
    @log = []
    @random = random
  end

  def select_move(board)
    possible_moves = board.possible_moves
    # moves according to the q_table, if not yet initiallised, this will return nil
    # so we'll initialize it here
    moves = @q_table[board.hash_value].clone
    if moves.nil?
      @q_table[board.hash_value] = [0.6] * 9
      # and pick a random move from the possible ones
      move = possible_moves.sample
    else
      # reject all moves that are not possible according to the board by setting their value to nil
      moves.map!.with_index {|v, i| possible_moves.include?(i) ? v : -100}
      # pick move with highest value that is possible from the moves that are possible
      highest_value = moves.max
      # find all moves that have the highest value
      move = moves.map.with_index {|v, i| highest_value == v ? i : nil}.compact.sample
    end
    @log << [board.hash_value, board.state, @value, move]
    return move
  end

  # log is an array of shape: [[hash, state before action, player, action]], outcome is 0.0, 0.5 or 1.0
  # distribute reward backwards from the last move with discount and apply learning
  # action is 0..8
  # player = 1.0 or -1.0
  # log does not include the final state of the game, since it is not needed for training
  def update_q_table(log, outcome)
    # TODO: all through the lens of the current player?
    learning_rate = 0.9
    discount = 0.95
    entry = log.pop
    hash_value = entry[0]
    action = entry[3]
    # initialise q_table if not yet done
    @q_table[hash_value] = [0.6] * 9 if @q_table[hash_value].nil?
    # set reward for last action of the game
    @q_table[hash_value][action] = (1.0 - learning_rate) * @q_table[hash_value][action] + learning_rate * outcome
    # Determine max value over all posible actions in that state
    max_a = @q_table[hash_value].max
    while entry = log.pop
      hash_value = entry[0]
      action = entry[3]
      # initialise q_table if not yet done
      @q_table[hash_value] = [0.6] * 9 if @q_table[hash_value].nil?
      # update with dsicount and learning
      @q_table[hash_value][action] = (1.0 - learning_rate) * @q_table[hash_value][action] + learning_rate * discount * max_a
      max_a = @q_table[hash_value].max
    end
  end

end
