% Initializing an empty board of size N x N.
init_board(N, Board) :-
    length(Board, N),
    maplist(init_row(N), Board).

init_row(N, Row) :-
    length(Row, N),
    maplist(=(empty), Row).

% Printing the board.
print_board([]).
print_board([Row|Rest]) :-
    print_row(Row),
    nl,
    print_board(Rest).

print_row([]).
print_row([Cell|Rest]) :-
    (Cell = empty ->
        write('_');
    write(Cell)),
    write(' '),
    print_row(Rest).



% Player makes a move.
player_move(Board, Player, NewBoard) :-
    repeat,
    length(Board, BoardSize),
    format('Enter row (1-~w): ', [BoardSize]), read(X),
    format('Enter column (1-~w): ', [BoardSize]), read(Y),
    (valid_move(Board, X, Y) ->
        make_move(Board, Player, X, Y, NewBoard),!;
    write('Invalid move. Please try again.'), nl, fail).

% Check if a move is valid.
valid_move(Board, X, Y) :-
    length(Board, BoardSize),
    between(1, BoardSize, X),
    between(1, BoardSize, Y),
    nth1(X, Board, Row),
    nth1(Y, Row, empty).

% Make a move.
make_move(Board, Player, X, Y, NewBoard) :-
    nth1(X, Board, Row),
    replace(Row, Y, Player, NewRow),
    replace(Board, X, NewRow, NewBoard).

% Replace an element in a list.
replace([_|T], 1, X, [X|T]).
replace([H|T], I, X, [H|T2]) :-
    I > 1,
    I1 is I - 1,
    replace(T, I1, X, T2).





% Check game state.
game_state(Board, Player, WinNum) :-
    (winning_state(Board, Player, WinNum) ->
        format('///~w wins!!!///~n', [Player]), true;
    draw_state(Board) ->
        write('It\'s a draw.'), true;
    fail).

% Check if list L contains N consecutive elements E.
consecutive(L, N, E) :-
    length(Sub, N),
    maplist(=(E), Sub),
    append([_, Sub, _], L).

% Winning states.
winning_state(Board, Player, WinNum) :-
    row_win(Board, Player, WinNum);
    col_win(Board, Player, WinNum);
    diag_win(Board, Player, WinNum).

% Check row, column, and diagonal wins.
row_win(Board, Player, WinNum) :-
    member(Row, Board),
    consecutive(Row, WinNum, Player).

col_win(Board, Player, WinNum) :-
    transpose(Board, TransposedBoard),
    row_win(TransposedBoard, Player, WinNum).

diag_win(Board, Player, WinNum) :-
    diags(Board, Diags),
    diagsAnti(Board, DiagsAnti),
    append(Diags, DiagsAnti, AllDiags),
    member(Diag, AllDiags),
    length(Diag, Length),
    Length >= WinNum,
    consecutive(Diag, WinNum, Player).

% helper predicates
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).
transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
    lists_firsts_rests(Ms, Ts, Ms1),
    transpose(Rs, Ms1, Tss).
lists_firsts_rests([], [], []).
lists_firsts_rests([[F|R]|Ls], [F|Fs], [R|Rs]) :-
    lists_firsts_rests(Ls, Fs, Rs).


matrix_element(Matrix, Row, Column, Element) :-
    nth1(Row, Matrix, MatrixRow),
    nth1(Column, MatrixRow, Element).

diagonal(Matrix, DiagonalIndex, Diagonal) :-
    findall(Element, (between(1, DiagonalIndex, I), J is DiagonalIndex - I + 1, matrix_element(Matrix, I, J, Element)), Diagonal).

reverse_rows([], []).
reverse_rows([Row|Rows], [ReversedRow|ReversedRows]) :-
    reverse(Row, ReversedRow),
    reverse_rows(Rows, ReversedRows).

diags(Matrix, Diags) :-
    length(Matrix, Length),
    MaxDiagonalIndex is Length * 2,
    findall(Diags, (between(1, MaxDiagonalIndex, I), diagonal(Matrix, I, Diags)), Diags).

diagsAnti(Matrix, AntiDiags) :-
    length(Matrix, Length),
    MaxDiagonalIndex is Length * 2,
    reverse_rows(Matrix, TrMatrix),
    findall(AntiDiags, (between(1, MaxDiagonalIndex, I), diagonal(TrMatrix, I, AntiDiags)), AntiDiags).

% Draw state.
draw_state(Board) :-
    flatten(Board, FlatBoard),
    \+ member(empty, FlatBoard).




% AI makes a move.
ai_move(Board, Player, NewBoard) :-
    choose_move(Board, 1, 1, Player, NewBoard).

choose_move(Board, X, Y, Player, NewBoard) :-
    length(Board, BoardSize),
    (valid_move(Board, X, Y) ->
        make_move(Board, Player, X, Y, NewBoard);
    Y1 is Y + 1,
    (Y1 =< BoardSize ->
        choose_move(Board, X, Y1, Player, NewBoard);
    X1 is X + 1,
    X1 =< BoardSize,
    choose_move(Board, X1, 1, Player, NewBoard))).

% Main game loop.
game_loop(Board, Player, WinNum) :-
    format('~w\'s turn to move.~n', [Player]),
    player_move(Board, Player, NewBoard),
    print_board(NewBoard),
    nl,
    (game_state(NewBoard, Player, WinNum) ->
        print_board(NewBoard);

    switch_player(Player, NextPlayer),
    format('~nAI\'s turn.~n'),
    ai_move(NewBoard, NextPlayer, NextBoard),
    print_board(NextBoard),
    nl,
    (game_state(NextBoard, NextPlayer, WinNum) ->
        print_board(NextBoard);
    game_loop(NextBoard, Player, WinNum))).


switch_player(x, o).
switch_player(o, x).

% Start the game.
start :-
    write('Enter board size: '), read(N),
    between(1,15,N),
    init_board(N, Board),
    print_board(Board),
    nl,
    write('Enter line length condition for win: '), read(WinNum),
    between(1,N,WinNum),
    nl,
    write('Choose player (x/o): '), read(Player),
    (Player = 'x'; Player = 'o'),
    nl,
    game_loop(Board, Player, WinNum).