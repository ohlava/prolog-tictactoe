% START everything using start.


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
        format('--- ~w WINS!!! ---~n', [Player]), true;
    draw_state(Board) ->
        format('--- It\'s a DRAW ---~n'), true;
    fail).

% Check if list L contains N consecutive elements E.
consecutive(L, N, E) :-
    length(Sub, N),
    maplist(=(E), Sub),
    append([_, Sub, _], L).

% Draw state.
draw_state(Board) :-
    flatten(Board, FlatBoard),
    \+ member(empty, FlatBoard).
    
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

board_element(Board, Row, Column, Element) :-
    nth1(Row, Board, BoardRow),
    nth1(Column, BoardRow, Element).

diagonal(Board, DiagonalIndex, Diagonal) :-
    findall(Element, (between(1, DiagonalIndex, I), J is DiagonalIndex - I + 1, board_element(Board, I, J, Element)), Diagonal).

reverse_rows([], []).
reverse_rows([Row|Rows], [ReversedRow|ReversedRows]) :-
    reverse(Row, ReversedRow),
    reverse_rows(Rows, ReversedRows).

diags(Board, Diags) :-
    length(Board, Length),
    MaxDiagonalIndex is Length * 2,
    findall(Diags, (between(1, MaxDiagonalIndex, I), diagonal(Board, I, Diags)), Diags).

diagsAnti(Board, AntiDiags) :-
    length(Board, Length),
    MaxDiagonalIndex is Length * 2,
    reverse_rows(Board, TrBoard),
    findall(AntiDiags, (between(1, MaxDiagonalIndex, I), diagonal(TrBoard, I, AntiDiags)), AntiDiags).







% AI makes a move.
ai_move(Board, AI, NewBoard, WinNum) :-
    length(Board, BoardSize),
    (winning_move(Board, BoardSize, AI, NewBoard, WinNum);
    blocking_move(Board, BoardSize, AI, NewBoard, WinNum);
    random_move(Board, BoardSize, AI, NewBoard)).

% helper function to make a winning move
winning_move(Board, BoardSize, AI, NewBoard, WinNum) :-
    between(1, BoardSize, X),
    between(1, BoardSize, Y),
    valid_move(Board, X, Y),
    make_move(Board, AI, X, Y, TempBoard),
    winning_state(TempBoard, AI, WinNum),
    NewBoard = TempBoard.

% helper function to block Player's winning move
blocking_move(Board, BoardSize, AI, NewBoard, WinNum) :-
    switch_player(AI, Player),
    between(1, BoardSize, X),
    between(1, BoardSize, Y),
    valid_move(Board, X, Y),
    make_move(Board, Player, X, Y, TempBoard),
    winning_state(TempBoard, Player, WinNum),
    make_move(Board, AI, X, Y, NewBoard).

% helper function to make a best random move
random_move(Board, BoardSize, AI, NewBoard) :-
    % Find all valid moves.
    findall([X, Y], (between(1, BoardSize, X), between(1, BoardSize, Y),
                     valid_move(Board, X, Y)),
            Moves),
    % Calculate the number of filled neighbors for each valid move.
    findall(Count-Move, (member(Move, Moves), Move = [X, Y],
                         count_neighbors(Board, X, Y, Count)),
            CountsMoves),
    % Find the move with the most filled neighbors.
    max_member(_-MaxMove, CountsMoves),
    MaxMove = [MaxX, MaxY],
    % Make the move.
    make_move(Board, AI, MaxX, MaxY, NewBoard).

count_neighbors(Board, X, Y, Count) :-
    X1 is X - 1, X2 is X + 1,
    Y1 is Y - 1, Y2 is Y + 1,
    findall(_, (between(X1, X2, I), between(Y1, Y2, J),
                not((I = X, J = Y)),
                nth1(I, Board, Row), nth1(J, Row, Cell),
                Cell \= empty),
            Neighbors),
    length(Neighbors, Count).




ai_move2(Board, Player, NewBoard, _) :-
    choose_move(Board, 1, 1, Player, NewBoard).

% just choose first avaible space
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
    ai_move(NewBoard, NextPlayer, NextBoard, WinNum),
    print_board(NextBoard),
    nl,
    (game_state(NextBoard, NextPlayer, WinNum) ->
        print_board(NextBoard);
    game_loop(NextBoard, Player, WinNum))).


switch_player(x, o).
switch_player(o, x).

% Start the game.
start :-
    write('WELCOME, LET\'s PLAY'), nl,
    write('- remember, put a period . after every input and before you press ENTER'), nl,
    write('like so:    x.ENTER'), nl, nl,

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