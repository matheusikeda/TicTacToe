% adiciona um elemento na lista
add_elem(E,L,[E|L]).

% cria uma lista de Length elementos zerados
row_builder(Length,L,L):-length(L,Length).
row_builder(Length,L1,R):- add_elem(0,L1,L2),
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

% verifica vitoria
% retorna 1 se vitoria, 0 se empate USA ESSA PARA VERIFICAR SITUACAO DO TABULEIRO
win(E,L,R):-win_rows(E,L,R);
            win_diagonal1(E,L,R);
            win_diagonal2(E,L,R);
            win_columns(E,L,1,R),!,fail.
win(_,_,0).            

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
%------------------interacao com usuario Daqui:
cls:-write('\e[2J'). %limpa a tela
inicio:-tamanho(N),  player(N), !.  %tamanho e nome
tamanho(N):-repeat, inicial, read(N), N>0, !. %Repete a tamanho enquanto o valor do N nao for maior que zero
inicial:- cls, write('Jogo da Velha NxN, digite valor de N:'), nl.
play1(Play):- write('Nome do player 1: '), nl, read(Play).
play2(Play):- write('Nome do player 2: '), nl, read(Play).
playss(Plays, _, _):-Plays=0, !.   %fim de game
playss(Plays, Player1, _):-Plays=1, write('Player '), write(Player1), !.  %mostra quem joga
playss(Plays, _, Player2):-Plays=2, write('Player '), write(Player2).     
player(N):-
    play1(Player1), play2(Player2),    %Nomes dos players
    %cls, matriz_nxn(N, N, Matriz), %matriz vazia de valor 0
    board_builder(N,Y,R), % cria uma representacao de matriz NxN 
    %cls, situacao(N, Matriz, 1, Player1, Player2), 
             game(N, Matriz, Player1, Player2).    %estado inicial %%%%%%%%%%%%%%%%% chamar o game aqui
%Situacao da matriz
situacao(N, Matriz, Plays, Player1, Player2):- cls, nl, 
   write('  '), enumera(N, 1, Posicao), posicoes(Posicao), nl,  %posicoes
   linhas(1,Matriz),                                     %linhas da matriz
   write('  '), enumera(N, 1, Posicao), posicoes(Posicao), nl,  %posicoes
   playss(Plays, Player1, Player2), !.                          %mostra jogador

     game(N, Matriz, Player1, Player2):-
        coordenadas(N, Matriz, Linha1, Coluna1),                    %Solicita a posicao em que o player1 quer jogar
        replace_matrix(L,Pos,E,NL),           % modifica a matriz na posicao informada
        win(E,L,R). %verifica vitoria (1= vitoria, 2=empate)
       % situacao(N, Matriz1, 2, Player1, Player2),    %Imprime o novo estado do game, indicando que a proxima jogada e do player2
        
        coordenadas(N, Matriz1, Linha2, Coluna2),                   %Solicita a posicao em que o player2 quer jogar
        replace_matrix(L,Pos,E,NL),           % modifica a matriz na posicao informada 
        win(E,L,R). %verifica vitoria (1= vitoria, 2=empate)
        %situacao(N, Matriz2, 1, Player1, Player2),    %Imprime o novo estado do game, indicando que a proxima jogada e do player1
        
        game(N, Matriz2, Player1, Player2).                   %Recursao - Chama o game novamente
    
%matriz_nxn(N,Linha,[]):-N>0, Linha=0, !.  %primeira linha da matriz
%matriz_nxn(N,Linha,Matriz):-N>0, Linha>0, Linha1 is Linha-1, 
%    gera_linha(N,Vetor), 
%    poe(Vetor, Mat, Matriz),  
%    matriz_nxn(N, Linha1, Mat).

%coordenadas da matriz
coordenadas(N, Matriz, Linha, Coluna):- repeat, nl,  %repeticao de validacao
    write('Qual linha: '), nl, read(Linha), nl,    
    write('Qual coluna: '), nl, read(Coluna),   
    (Linha>0, Linha<N; Linha=N), (Coluna>0, Coluna<N; Coluna=N),    %intervalo das dimensoes da matriz
    local(Matriz, Linha, Coluna, Objeto), Objeto=0, !.    %posicao do objeto vazia = 0


%enumera posicoes
enumera(N,_,[]):-N=0,!.
enumera(N,Inicio,Vetor):-N>0, N1 is N-1, Inicio1 is Inicio+1, 
    poe(Inicio, Vetor1, Vetor), enumera(N1,Inicio1,Vetor1).                  

%Imprime a sequencia gerada
posicoes([]).
posicoes([Linha|Resto]):-jogada(Linha), posicoes(Resto).
jogada(Gerou):-Gerou<10, write('   '), write(Gerou).
jogada(Gerou):-Gerou=10, write('   '), write(Gerou).
jogada(Gerou):-Gerou>10, write('   '), write(Gerou).

%linhas da matriz
linhas(_,[]).                %checa linhas
linhas(N,[Linha|Resto]):- valorN(N), write(' |'),       %linha atual
    linha(Linha),            %Escreve na linha
    write(' '), write(N), nl, N1 is N+1,  %vai pra proxima linha
	linhas(N1, Resto).       %mostra o restante das linhas

valorN(N):-N<10, write(' '), write(N).
valorN(N):-N=10, write(N).
valorN(N):-N>10, write(N).

%mostra a matriz
linha([]). %lista vazia
linha([Objeto|Resto]):-mostra(Objeto), linha(Resto).     %coloca o valor nas posicoes da matriz

mostra(0):-write('   |').    %matriz vazia
mostra(1):-write(' X |').    %X para player 1
mostra(2):-write(' O |').    %O para player 2

% ------------------------Ate aqui interface-------------------------------------