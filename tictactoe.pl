% Using lists of lists to represent the board
init_board(N, Board) :-
    length(Board, N),
    maplist(init_row(N), Board).

init_row(N, Row) :-
    length(Row, N),
    maplist(=(empty), Row).

% Choose which player goes first
choose_player(Player) :-
    write('Choose player X or O: '),
    read(Player).

% Player makes a move
player_move(Board, Player) :-
    write('Enter row: '), read(X),
    write('Enter column: '), read(Y),
    valid_move(Board, X, Y),
    make_move(Board, Player, X, Y, NewBoard),
    print_board(NewBoard).

% Check if a move is valid
valid_move(Board, X, Y) :-
    nth1(X, Board, Row),
    nth1(Y, Row, empty).

% Make a move
make_move(Board, Player, X, Y, NewBoard) :-
    nth1(X, Board, Row),
    replace(Row, Y, Player, NewRow),
    replace(Board, X, NewRow, NewBoard).

% Replace an element in a list
replace([_|T], 1, X, [X|T]).
replace([H|T], I, X, [_|T2]) :- 
    I > 1, 
    I1 is I - 1, 
    replace(T, I1, X, T2).

% Check game state
game_state(Board, Player) :-
    (winning_state(Board, Player) ->
        format('~w wins!', [Player]), true;
    draw_state(Board) ->
        write('It\'s a draw.'), true;
    fail).

% AI makes a move
ai_move(Board, Player, Difficulty, NewBoard) :-
    minimax(Board, Player, Difficulty, _, Move),
    make_move(Board, Player, Move, NewBoard),
    print_board(NewBoard).

% Minimax algorithm
minimax(Board, Player, Depth, Score, Move) :-
    Depth > 0,
    findall(M, valid_move(Board, M), Moves),
    best_move(Board, Player, Moves, Depth, Score, Move).

% Main game loop
game_loop(Board, Player, Difficulty) :-
    player_move(Board, Player),
    (game_state(Board, Player) ->
        true;
    ai_move(Board, Player, Difficulty, NewBoard),
    (game_state(NewBoard, Player) ->
        true;
    game_loop(NewBoard, Player, Difficulty))).

