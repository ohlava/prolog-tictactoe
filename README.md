# Tic Tac Toe Game

This is a Tic Tac Toe game that you can play with an AI. The game is written in Prolog, which uses a declarative paradigm, in contrast to more common procedural languages.

## How to Use

Open file tictactoe_final.pl using swipl in terminal.

### Starting the Game
To start the actual game, use the following command:

```prolog
start.
```

Upon starting the game, you'll be welcomed with a prompt. Please remember to put a period (.) after every input before you press ENTER. This is necessary as it's part of the Prolog syntax. For example, to play as 'x', you would enter 'x.' (without the quotes).

You will then be asked for three inputs:

- The size of the board (enter a number between 1 and 15)
- The line length condition for win (enter a number between 1 and the chosen board size)
- The player you want to play as (enter 'x' or 'o')

An example interaction might look like:

```prolog
Enter board size: 3.
Enter line length condition for win: 3.
Choose player (x/o): x.
```

### Playing the Game
Once the game starts, you'll see an empty board. You will be asked to enter the row and column of the move you want to make. Each of these inputs should be a number between 1 and the size of the board. For example, for a 3x3 board, if you wanted to move to the center of the board, you would enter:

```prolog
Enter row (1-3): 2.
Enter column (1-3): 2.
```

### Game Over
The game ends when either you or the AI has won or the board is filled resulting in a draw. The game will notify you of the result.

## Project Structure

The project consists of the following key predicates:

- start/0: Begins the game.
- init_board/2: Initializes an empty board of size N x N.
- player_move/3: Allows the player to make a move.
- ai_move/4: The AI makes its move.
- game_loop/3: The main game loop, which switches turns between the player and the AI.
- game_state/3: Checks the game state to see if anyone has won or if it's a draw.
- winning_state/3 Checks if a winning condition has been met for the current player.

## Contributions

Contributions, bug reports, and improvements are all welcome. Please feel free to open an issue or create a pull request.
