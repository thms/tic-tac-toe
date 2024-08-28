## Tic-Tac-Toe AI

This repository contains a collection of different AI players for the game Tic-Tac-Toe, implemented in Ruby. The players are designed to learn and improve their strategies through various techniques, including:

* **Tabular Q-Learning:** The `TQPlayer` uses a hash table to store the Q-values for each board state and action. It learns by updating the Q-values based on the outcome of each game.
* **Minimax Algorithm:** The `MinMaxPlayer` uses the classic minimax algorithm to evaluate all possible future moves and select the best one. It can be configured with an error rate to introduce randomness into its decision-making.
* **Neural Networks:** The `NNPlayer` and `NN2Player` use neural networks to learn the Q-function. They are trained on the outcomes of games and can adjust their strategies over time.

### API

The codebase provides a simple API for interacting with the AI players and the game:

* **`Board` class:** Represents the Tic-Tac-Toe board.
    * `state`: An array of 9 elements representing the board state. 0 for empty, 1 for X, -1 for O.
    * `is_win?(value)`: Checks if the current board state is a win for the given player (value).
    * `possible_moves`: Returns an array of possible moves for the current board state.
    * `is_draw?`: Checks if the current board state is a draw.
    * `draw`: Prints the board to the console.
* **`Game` class:** Represents a Tic-Tac-Toe game.
    * `player_one`: The first player.
    * `player_two`: The second player.
    * `play`: Plays a game between the two players and returns the game log and the outcome.
* **Player classes:**
    * `TQPlayer`, `MinMaxPlayer`, `NNPlayer`, `NN2Player`, `RandomPlayer`: Each player class implements a different strategy for selecting moves.

### Data Model

The data model is simple and consists of the following:

* **Board state:** An array of 9 elements representing the board state.
* **Player value:** 1.0 for X, -1.0 for O.
* **Move:** An integer representing the position on the board where a player places their stone.
* **Game log:** An array of arrays, where each inner array represents a move and contains the board state before the move and the move itself.
* **Outcome:** 1.0 for X win, -1.0 for O win, 0.0 for a draw.

### Business Logic

The business logic is implemented in the `Game` class and involves the following steps:

1. Initialize the game with two players.
2. Play the game until a win or draw occurs.
3. For each move:
    * Get the current player's move using the player's strategy.
    * Update the board state.
    * Update the game log.
4. Determine the winner or draw based on the final board state.

### Events Consumed and Published

The codebase does not consume or publish any external events. The AI players learn and improve their strategies based on the outcomes of games played within the codebase.

### Repository

This codebase is available on GitHub at [https://github.com/thms/tic-tac-toe](https://github.com/thms/tic-tac-toe).

**Timestamp:** 2023-10-27 11:00:00 UTC
