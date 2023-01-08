:- use_module(library(format)).
:- use_module(library(lists)).
:- use_module(library(time)).

apply(P, L) :- G =.. [P|L], G.

% See https://github.com/mthom/scryer-prolog/issues/1681#issuecomment-1374852413
% and https://github.com/mthom/scryer-prolog/issues/1681#issuecomment-1374853910.
:- discontiguous(sk_1/3).
:- discontiguous(sk_3/3).

term_expansion(sk(X,Y,Z),
               [sk_1(X,Y,Z),
                sk_3(Z,X,Y)]).

sk(X, Y, Z) :-
        (   nonvar(X) ->
            sk_1(X, Y, Z)
        ;   nonvar(Z) ->
            sk_3(Z, X, Y)
        ;   sk_1(X, Y, Z)
        ).
