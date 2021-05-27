require 'test_helper'
require_relative './../../lib/t_q_player'
require_relative './../../lib/random_player'
require_relative './../../lib/min_max_player'
require_relative './../../lib/board'
require_relative './../../lib/game'

class TQPlayerTest < ActiveSupport::TestCase

  test "should select random move if no learning yet" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 0, 0 ,0, 0,0,0,0,0]
    result = player.select_move(board)
    assert_includes 0..8, result
  end

  test "should select only available move if no learning yet" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 1.0, -1.0 ,1.0, -1.0,1.0,-1.0,1.0, -1.0]
    result = player.select_move(board)
    assert_equal 0, result
  end

  test "should select best move with forced training" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 0, 0 ,0, 0,0,0,0,0]
    player.q_table[board.hash_value] = [0,0,0,1,0,0,0,0,0]
    result = player.select_move(board)
    assert_equal 3, result
  end

  test "should select randomly best move with forced training" do
    player = TQPlayer.new
    player.value = 1.0
    board = Board.new [0, 0, 0 ,0, 0,0,0,0,0]
    player.q_table[board.hash_value] = [0,0,0.5,0,0,0.5,0,0,0]
    result = player.select_move(board)
    assert_includes [2,5], result
  end

  test "should update q_table after one game" do
    player = TQPlayer.new
    player.value = 1.0
    log = []
    board = Board.new [0,0,0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 0]
    board.state = [1.0,0,0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, -1.0, 1]
    board.state = [1.0,-1.0,0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 2]
    board.state = [1.0,-1.0,1.0,0,0,0,0,0,0]
    log << [board.hash_value, board.state, -1.0, 3]
    board.state = [1.0,-1.0,1.0,-1.0,0,0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 4]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,0,0,0,0]
    log << [board.hash_value, board.state, -1.0, 5]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,-1.0,0,0,0]
    log << [board.hash_value, board.state, 1.0, 6]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,0,0]
    log << [board.hash_value, board.state, -1.0, 7]
    board.state = [1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,0]
    log << [board.hash_value, board.state, 1.0, 8]
    player.log = log
    player.update_q_table(1.0)
    assert_in_delta 1.0, player.q_table[board.hash_value][8], 0.01
  end

  test "should learn from a number of games against the random player when going first" do
    #skip
    puts 'TQ : Random'
    player_one = TQPlayer.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
    end
    puts "Training stats #{stats}"
    # should be very likely to win the next games
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
    end
    assert_operator 15, :>, stats[-1.0]
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the random player when going second" do
    skip
    puts 'Random : TQ'
    player_one = TQPlayer.new
    player_two = RandomPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    # seems going second it needs more training to get good at the game
    10000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
    end
    puts "Training stats #{stats}"
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
      end
    assert_operator 15, :>, stats[1.0]
    puts "Testing stats #{stats}"
  end

  test "should learn from a number of games against the min max player when going first" do
    skip
    # the best we can hope for is that TQ gets a fair number of draws
    player_one = TQPlayer.new
    player_two = MinMaxPlayer.new

    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
    end
    puts "Untrained stats #{stats}"
    # Typically 25 draws to 75 losses

    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
    end
    puts "Training stats #{stats}"

    # cannot win, but should get quite a few draws
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
    end
    #assert_in_delta stats[0.0], stats[-1.0], 10
    puts "Testing stats #{stats}"
    # after 100 training games: about 50/50, does not seem to improve even after 10k games of training
  end

  test "should learn from a number of games against the min max player when going second" do
    skip
    # the best we can hope for is that TQ gets a fair number of draws - getting to about 6%
    # only if we introduce an error rate in the MinMax player, does this change and
    # the TQ actually gets to win and get more draws
    # if the error rate gets to ten percent - so the minMax player make a mistake in every game, the TQ player crushes him
    player_one = TQPlayer.new
    player_two = MinMaxPlayer.new(false, 0.0)

    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
    end
    puts "Untrained stats #{stats}"
    # Typically 25 draws to 75 losses

    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    100000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
    end
    puts "Training stats #{stats}"

    # cannot win, but should get quite a few draws (but since we introduced an error rate in the minmax this guy also wins)
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
    end
    #assert_in_delta stats[0.0], stats[-1.0], 10
    puts "Testing stats #{stats}"
    # after 100 training games: about 50/50, does not seem to improve even after 10k games of training
  end

  test "should learn from a number of games against the min max player when going first / second alternating" do
    skip
    # the best we can hope for is that TQ gets a fair number of draws
    player_one = TQPlayer.new
    player_two = MinMaxPlayer.new
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
    end
    10000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
    end
    puts "Training stats #{stats}"

    # cannot win, but should get quite a few draws
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
    end
    #assert_in_delta stats[0.0], stats[-1.0], 10
    puts "Testing stats TQ first #{stats}"
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
    end
    #assert_in_delta stats[0.0], stats[-1.0], 10
    puts "Testing stats TQ second #{stats}"
    # after 100 training games: about 50/50, does not seem to improve even after 10k games of training
    # with initialziation of 0.3, the TQ player becomes as good as the mina max player and every game ends in a draw!!
  end

  test "should learn from a number of games against the tq player when going first" do
    skip
    # we'll need to train both players during the training phase
    # when we train them symmetrically, and initialize the q_tables with 0.3 they learn how to play perfectly well against each other and produce only draws
    # when training symmetrically with initialization of 0.6, whichever player starts the game wins most of the time, the second player never wins and we have 5% - 10% draws
    player_one = TQPlayer.new
    player_two = TQPlayer.new

    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
    end
    puts "Untrained stats #{stats}"

    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
      player_two.update_q_table(outcome)
    end
    puts "Training stats #{stats}"
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    10000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
      player_one.update_q_table(outcome)
      player_two.update_q_table(outcome)
    end
    puts "Training stats #{stats}"

    # cannot win, but should get quite a few draws
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_two, player_one).play
      stats[outcome] += 1
    end
    #assert_in_delta stats[0.0], stats[-1.0], 10
    puts "Testing stats #{stats}"
    # cannot win, but should get quite a few draws
    stats = {1.0 => 0, 0.0 => 0, -1.0 => 0}
    1000.times do
      log, outcome = Game.new(player_one, player_two).play
      stats[outcome] += 1
    end
    #assert_in_delta stats[0.0], stats[-1.0], 10
    puts "Testing stats #{stats}"
  end

end
