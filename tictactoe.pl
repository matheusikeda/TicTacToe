% Matheus Ikeda, Gildomar
% adiciona um elemento na lista
add_elem(E,L,[E|L]).

% cria uma lista de Length elementos zerados
row_builder(Length,L,L):-length(L,Length).
row_builder(Length,L1,R):- add_elem(.,L1,L2),
                           row_builder(Length,L2,R).

% cria uma representacao de matriz NxN (Ex. N = 3 [[0,0,0],[0,0,0],[0,0,0]]) USA ESSA PRA GERAR TABULEIRO
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

win_rows(E,[H|L],R):-win_row(E,H,R);
                     win_rows(E,L,R).

% pega o elemento da posicao passada
get_elem(1,[H|L],H).
get_elem(Position,[H|L],X):-Position2 is Position -1,
                            get_elem(Position2,L,X).

get_column(Position,[],L,L).
get_column(Position,[H|L],L2,R):-get_elem(Position,H,X),
                                 add_elem(X,L2,Y),
                                 get_column(Position,L,Y,R).

% verifica se elementos da coluna sao iguais (retorna 1 se sim)                                 
win_column(Position,E,L,R):-get_column(Position,L,[],X),
                            win_row(E,X,R).

win_columns(E,L,N,R):-win_column(N,E,L,R);
                      N2 is N + 1,
                      length(L,X),
                      N2 < X +1,
                      win_columns(E,L,N2,R).

% verifica se elementos da diagonal principal sao iguais (retorna 1 se sim)
win_diagonal1(E,L,R):-get_diagonal1(L,[],1,X),
                      win_row(E,X,R).

% retorna em uma lista a diagonal principal passa 1 como Length
get_diagonal1([],L,Length,L).
get_diagonal1([H|L],L1,Length0,R):-get_elem(Length0,H,Y),
                                   add_elem(Y,L1,L2),
                                   Z is Length0+1,
                                   get_diagonal1(L,L2,Z,R).

% verifica se elementos da diagonal secundaria sao iguais (retorna 1 se sim)
win_diagonal2(E,L,R):-length(L,Y),
                      get_diagonal2(L,[],Y,X),
                      win_row(E,X,R).

% retorna em uma lista a diagonal secundaria passa o tamanho como Length
get_diagonal2(_,L,0,L).
get_diagonal2([H|L],L1,Length,R):-get_elem(Length,H,Y),
                                  add_elem(Y,L1,L2),
                                  Z is Length-1,
                                  get_diagonal2(L,L2,Z,R).

% verifica se deu velha, retorna true caso nao tenha mais nenhum espaco vazio. Retorna 1 se tabuleiro cheio
draw([],1).
draw([H|L],R):-not(member('.',H)),
               draw(L,R).

% verifica vitoria
% retorna 1 se vitoria, 0 se empate USA ESSA PARA VERIFICAR SITUACAO DO TABULEIRO
win(E,L,R):-win_rows(E,L,R);
            win_diagonal1(E,L,R);
            win_diagonal2(E,L,R);
            win_columns(E,L,1,R);
            draw(L,R),
            write('Game over'),!,fail.
win(_,_,0).


% pessoa contra pessoa

% faz a jogada (muda um valor da matriz)                                 
% recebe uma lista e retorna uma lista de lista 
% ex: group([9,8,7,6,5,4,3,2,1],3,3,[],[],X). retorna X = [[1,2,3],[4,5,6],[7,8,9]]
group([],N2,N2,_,Acc2,Acc2).
group(L,0,N2,Acc,Acc2,R):-add_elem(Acc,Acc2,Z),
                                 group(L,N2,N2,[],Z,R).
group([H|L],N,N2,Acc,Acc2,R):-add_elem(H,Acc,X),
                                Y is N-1,
                                group(L,Y,N2,X,Acc2,R).

% modifica um elemento de uma lista dado a posicao 
replace_list([_|T],1,E,[E|T]).
replace_list([H|T],P,E,[H|R]):-P > 1, 
                               NP is P-1, 
                               replace_list(T,NP,E,R).

% modifica a matriz na posicao informada USA ESSA PARA FAZER A JOGADA 
% ex: replace_matrix([[1,1,1],[1,1,1],[1,1,1]],4,0,NL). retorna NL = [[1,1,1],[0,1,1],[1,1,1]]
replace_matrix(L,Pos,E,NL):-length(L,T),
                            append(L,X),
                            replace_list(X,Pos,E,Y),
                            reverse(Y,Z),
                            group(Z,T,T,[],[],NL).

% interface com o usuario

cls:-write('\e[H\e[2J'). % limpa a tela

inicio:-board_length(N),
        inicialize(N),!.  

board_length(N):-repeat, 
                 get_length,
                 read(N), N>2, !. % repete enquanto N > 2

get_length:-write('Jogo da Velha NxN, Informe o tamanho do tabuleiro:'), nl.

inicialize(N):-board_builder(N,[],M),
               printBoard(M),
               state(M,N).
                   
                                  
state(M,N):-get_position1(Pos1,N),
            replace_matrix(M,Pos1,'X',NM),
            printBoard(NM),
            win('X',NM,R),
            end(R),
            get_position2(Pos2,N),
            replace_matrix(NM,Pos2,'O',NM2),
            printBoard(NM2),
            win('O',NM2,R2),
            end(R2),
            state(NM2,N).

get_position1(Pos,N):-repeat,
                      position1(N),
                      read(Pos),
                      Pos < N*N + 1. 

position1(N):-write('Informe a posicao: 1~'),
              R is N*N,
              write(R),nl.

get_position2(Pos,N):-repeat,
                      position2(N),
                      read(Pos),
                      Pos < N*N + 1. 

position2(N):-write('Informe a posicao: 1~'),
              R is N*N,
              write(R),nl.

end(1):-write('Game over!'),
        nl,
        nl,
        inicio.
end(0):-write('Proximo jogador!'),nl.

% contra o computador
% pessoa comeca
% check_board(M,NM):-