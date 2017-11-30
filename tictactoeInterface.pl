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

%------------------interacao com usuario Daqui:
cls:-write('\e[2J'). %limpa a tela
inicio:-tamanho(N),  player(N), !.  %tamanho e nome
tamanho(N):-repeat, dados, read(N), N>0, !. %Repete a tamanho enquanto o valor do N nao for maior que zero
dados:- cls, write('Jogo da Velha NxN, digite valor de N:'), nl.
play1(Play):- write('Nome do player 1: '), nl, read(Play).
play2(Play):- write('Nome do player 2: '), nl, read(Play).
playss(Plays, _, _):-Plays=0, !.   %fim de game
playss(Plays, Player1, _):-Plays=1, write('Player '), write(Player1), !.  %mostra quem joga
playss(Plays, _, Player2):-Plays=2, write('Player '), write(Player2).     
player(N):-
     cls, play1(Player1), cls, play2(Player2),    %Nomes dos players
     cls, matriz_nxn(N, N, Matriz), %matriz vazia de valor 0
     cls, situacao(N, Matriz, 1, Player1, Player2), 
              game(N, Matriz, Player1, Player2).    %estado inicial %%%%%%%%%%%%%%%%% chamar o game aqui

matriz_nxn(N,Linha,[]):-N>0, Linha=0, !.  %primeira linha da matriz
matriz_nxn(N,Linha,Matriz):-N>0, Linha>0, Linha1 is Linha-1, 
    gera_linha(N,Vetor), 
    poe(Vetor, Mat, Matriz),  
    matriz_nxn(N, Linha1, Mat).

%coordenadas da matriz
coordenadas(N, Matriz, Linha, Coluna):- repeat, nl,  %repeticao de validacao
    write('Qual linha: '), nl, read(Linha), nl,    
    write('Qual coluna: '), nl, read(Coluna),   
    (Linha>0, Linha<N; Linha=N), (Coluna>0, Coluna<N; Coluna=N),    %intervalo das dimensoes da matriz
    local(Matriz, Linha, Coluna, Objeto), Objeto=0, !.    %posicao do objeto vazia = 0

%Situacao da matriz
situacao(N, Matriz, Plays, Player1, Player2):- cls, nl, 
   write('  '), enumera(N, 1, Posicao), posicoes(Posicao), nl,  %posicoes
   linhas(1,Matriz),                                     %linhas da matriz
   write('  '), enumera(N, 1, Posicao), posicoes(Posicao), nl,  %posicoes
   playss(Plays, Player1, Player2), !.                          %mostra jogador

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