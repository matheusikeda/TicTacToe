% adiciona um elemento na lista
add_elem(E,L,[E|L]).

% cria uma lista de Length elementos zerados
row_builder(Length,L,L):-length(L,Length).
row_builder(Length,L1,R):- add_elem(0,L1,L2),
                           row_builder(Length,L2,R).

% cria uma representacao de matriz NxN (Ex. N = 3 [[0,0,0],[0,0,0],[0,0,0]])
board_builder(N,L,L):-length(L,N).
board_builder(N,L,R):-row_builder(N,[],X),
                      add_elem(X,L,Y),
                      board_builder(N,Y,R).    

% imprimi a matriz (Como passar o resultado de board_builder para ela???)
printBoard([Head|Tail]):-printRow(Head),
                         printBoard(Tail).
printBoard([]).
printRow([Head|Tail]):-write(Head),
                       write('  '),
                       printRow(Tail).
printRow([]) :- nl.

% verifica se ganhou
% verifica se elementos da lista sao iguais (retorna 1 se sim)
win_row(E,[E],1).
win_row(E,[H|L],X):-win_row(E,L,X),
                    H == E.

% verifica se elementos da coluna sao iguais (retorna 1 se sim) 
% pega o elemento da posicao passada
get_elem(1,[H|L],H).
get_elem(Position,[H|L],X):-Position2 is Position -1,
                            get_elem(Position2,L,X).
get_column(Position,[],L,L).
get_column(Position,[H|L],L2,R):-get_elem(Position,H,X),
                                 add_elem(X,L2,Y),
                                 get_column(Position,L,Y,R).

% verifica se elementos da diagonal principal sao iguais (retorna 1 se sim)
get_diagonal1([H|L],)
get_diagonal1([H|L],L1):-length(H,X),
                         get_elem(X,H,Y),
                         add_elem(Y,L1,L2),
                         get_diagonal1(L,L2).

% verifica se elementos da diagonal secundaria sao iguais (retorna 1 se sim)

% verifica vitoria