:- use_module(library(format)).
:- use_module(library(lists)).
:- use_module(library(time)).

writeln(T) :- write(T), nl.

% See https://www.swi-prolog.org/pldoc/doc_for?object=current_functor/2
% This is used in 'wn_load.pl' apparently just to detect that the
% predicate has been written, but more essentially in 'wn_valid.pl'
% to determine the arity of relations, so that asymmetries may be
% detected.  Not knowing how to examine the database to determine
% presence and arity of predicates, I'll simply assert the facts
% of what the relevant relation arities are.
current_functor(Name, Arity) :-
    (   symrels(Symrels),      % These are the relations checked for symmetry,
        member(Name, Symrels), % and so for which this predicate is needed.
        wnrelation_arity(Name, Arity)
    ;   Arity = '?' % A do-nothing alternative for inessential use in 'wn_load.pl'.
    ).

wnrelation_arity(R, 2) :- member(R, [sim]).
wnrelation_arity(R, 4) :- member(R, [ant,der,vgp]).

apply(P, [X]) :- call(P, X).
apply(P, [X1,X2]) :- call(P, X1, X2).
apply(P, [X1,X2,X3]) :- call(P, X1, X2, X3).
apply(P, [X1,X2,X3,X4]) :- call(P, X1, X2, X3, X4).
apply(P, [X1,X2,X3,X4,X5]) :- call(P, X1, X2, X3, X4, X5).
apply(P, [X1,X2,X3,X4,X5,X6]) :- call(P, X1, X2, X3, X4, X5, X6).
