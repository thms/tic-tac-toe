# Tic Tac Toe
A simple game implementation to work on reinforcement learning
Contains the basic game, board and logic to run all kinds of simulations
Simulations all use the test framework and guard :)
Inspired by https://medium.com/@carsten.friedrich/part-1-computer-tic-tac-toe-basics-35964f92fa03

## RandomPlayer
Pick's a random move from the possible ones

## MinMaxPlayer
Implementation of classic min max algorithm to simulate every possible future and back propagate best move possible
Unless introducing an error rate, this player never looses.
So there is an error rate that can be passed into the player

## TQPlayer
Implementation of classic tabular Q function. The quality function expresses the discounted reward for a given action in a given state.
The player learns it by playing and observing the outcome of each game - see the test code for feedback loops.
Depending on initialisation of the Q table,  player can learn get to perfect draws against itself (init with 0.3), or to never loose against itself and often win if it goes first
