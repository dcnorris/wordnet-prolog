time(G) :-
    cpu_time(T0),
    call(G),
    cpu_time(T1),
    CPU is (T1 - T0)/1000.0,
    format("CPU time: ~3f seconds.", [CPU]).

list_to_set(Ls0, Ls) :-
    sort(Ls0, Ls).

apply(P, L) :- G =.. [P|L], G.

/*
The following term_expansion/2 technique suggested by Markus Triska
helps Scryer Prolog to index sk/3 for fast completion of goal [wn_valid].
But it does NOT help gprolog 1.5.1(rc) [cloned and built on 2023-01-08],
apparently because term_expansion/2 is not yet supported outside DCGs;
see http://www.gprolog.org/manual/gprolog.html#expand-term%2F2.

With MAX_ATOM=1000000, GLOBALSZ=1000000 and TRIALSZ=100000, gprolog does
complete the [wn_valid] goal, but spends on the order of 1 hour whereas
SWI and Scryer Prolog need mere fractions of a minute.

TODO: Is there a technique "to call expand_term/2 explicitly" that would
      allow gprolog to benefit from similar indexing assistance?
*/

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
