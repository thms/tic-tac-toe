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

## NNPlayer
A fairly simple neural network with one hidden layer that can learn while playing from the other players or against itself. With the right amount of training it will get to all draws against min max and TQ

## Using the code base
This is exploratory code only, not of production quality or with a hint of anything final.
To run the tests, make sure you have ruby, and bundler installed.
Start guard to run tests continuously:

    bundle exec guard

## Resources
http://leenissen.dk/fann/wp/
https://github.com/tangledpath/ruby-fann

https://github.com/giuse/simple_ga/blob/master/ga.rb
https://github.com/giuse/machine_learning_workbench/tree/master/lib/machine_learning_workbench/optimizer/natural_evolution_strategies

https://www.tensorflow.org/install/
https://awjuliani.medium.com/simple-reinforcement-learning-with-tensorflow-part-4-deep-q-networks-and-beyond-8438a3e2b8df
https://mitpress.mit.edu/books/reinforcement-learning
