/* 
# https://github.com/ekaf/wordnet-prolog/raw/master/wn_load.pl
(c) 2020 Eric Kafe, CC BY 4.0, https://creativecommons.org/licenses/by/4.0/

SWI-prolog program to load all WordNet databases
*/

semrels(['at','cs','ent','hyp','ins','mm','mp','ms','sim','vgp']).
lexrels(['ant','der','per','ppl','sa']).
lexinfo(['cls','fr','s','sk','syntax']).
seminfo(['g']).

allwn(L):-
  semrels(L),
  format("\nSemantic Relations: ~w\n", [L]).
allwn(L):-
  lexrels(L),
  format("\nLexical Relations: ~w\n", [L]).
allwn(L):-
  lexinfo(L),
  format("\nLexical Info: ~w\n", [L]).
allwn(L):-
  seminfo(L),
  format("\nSemantic Info: ~w\n", [L]).

% This predicate records arity of each individual WN predicate,
% obviating use of nonstandard SWI predicate current_functor/2.
wnpred_arity(P, 2) :- member(P, [at,cs,ent,hyp,ins,mm,mp,ms,sim,g]).
wnpred_arity(P, 3) :- member(P, [fr,sk,syntax]).
wnpred_arity(P, 4) :- member(P, [vgp,ant,per,ppl,sa]).
wnpred_arity(P, 5) :- member(P, [cls]).
wnpred_arity(P, 6) :- member(P, [s]).

/* ------------------------------------------
Load WN
------------------------------------------ */

loadpred(P):-
  atom_concat('prolog/wn_', P, B), atom_concat(B, '.pl', F),
  consult(F),
  wnpred_arity(P,A),
  format("Loaded ~w (~w/~w)\n",[F,P,A]).

loadwn:-
  allwn(L),
  member(P,L),
  loadpred(P),
  false.
loadwn:-
  nl.

:- initialization(loadwn).
