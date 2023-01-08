/* 
# https://github.com/ekaf/wordnet-prolog/raw/master/wn_valid.pl
(c) 2020 Eric Kafe, CC BY 4.0, https://creativecommons.org/licenses/by/4.0/

SWI-prolog program testing for some potential issues in WordNet:

- check_keys: ambiguous sense keys, pointing to more than one synset
- symcheck: missing symmetry in the symmetric relations
- asymcheck: direct loops in the asymmetric relations
- hypself: self-hyponymous word forms
- check_duplicates: find duplicate clauses
*/

ok:-
  write('OK'), nl.

glosspair(A,B,G1,G2):-
  g(A,G1),
  g(B,G2).

/* ------------------------------------------
Ambiguous sense keys
------------------------------------------ */

multikey(K):-
  sk(I,_,K),
  sk(J,_,K),
  I\=J.

check_keys:-
  write('Searching for ambiguous sense keys'), nl,
  findall(X, multikey(X), L),
  list_to_set(L,S),
  member(K,S),
  format("Ambiguous key: ~w\n",[K]),
  findall(I, sk(I,_,K), IL),
  list_to_set(IL,IS),
  member(I,IS),
  g(I,G),
  format("    ->~w (~w)\n",[I,G]),
  false.
check_keys:-
  ok,
  nl.


/* ------------------------------------------
Symmetry Test
------------------------------------------ */

symrels(['sim','ant','der','vgp']).

symrel(2,R):-
  call(R,A,B),
  (call(R,B,A) -> true; format("Missing ~w(~w,~w)\n",[R,B,A])),
  false.
symrel(4,R):-
  call(R,A,B,C,D),
  sk(A,B,K1),
  (call(R,C,D,A,B) -> true; (sk(C,D,K2), format("Missing ~w from ~w to ~w\n",[R,K2,K1]))),
  false.
symrel(_,_):-
  ok.

symcheck:-
  symrels(L),
  format("Symmetric relations: ~w\n",[L]),
  member(R,L),
  format("Checking symmetry in ~w relation (wn_~w.pl):\n",[R,R]),
  wnpred_arity(R,N),
  symrel(N,R),
  false.
symcheck:-
  nl.

/* ------------------------------------------
Asymmetry test:
------------------------------------------ */

asymrels(['hyp','ins','mm','mp','ms','cls']).

asymrel(cls):-
  cls(A,AN,B,BN,T),
  cls(B,BN,A,AN,T),
  glosspair(A,B,G1,G2),
  format("Looping cls-~w:\n  from ~w-~w (~w)\n    to ~w-~w (~w)\n",[T,A,AN,G1,B,BN,G2]),
  false.
asymrel(R):-
  R\=cls,
  call(R,A,B),
  call(R,B,A),
  glosspair(A,B,G1,G2),
  format("Looping ~w:\n  from ~w (~w)\n    to ~w (~w)\n",[R,A,G1,B,G2]),
  false.
asymrel(_):-
  ok.

asymcheck:-
  asymrels(L),
  format("Asymmetric relations: ~w\n",[L]),
  member(R,L),
  format("Checking asymmetry in ~w relation (wn_~w.pl):\n",[R,R]),
  asymrel(R),
  false.
asymcheck:-
  nl.

/* ------------------------------------------
Self-hyponymous words
------------------------------------------ */

hypself:-
  write('Hyponymy between different senses of the same word:'),
% Note: this is usually not a problem, but some senses could need merging
  nl,
  hyp(A,B),
  s(A,N1,W,_,_,_),
  s(B,N2,W,_,_,_),
  glosspair(A,B,G1,G2),
  format("\"~w~\" hyp:\n  from ~w-~w (~w)\n    to ~w-~w (~w)\n",[W,A,N1,G1,B,N2,G2]),
  false.
hypself:-
  ok,
  nl.

/* ------------------------------------------
Find Duplicates
------------------------------------------ */


:- dynamic(duplicate/3).

outdups(N,P):-
  format("Found ~w duplicate ~w:\n",[N,P]),
  listing(duplicate),
  retractall(duplicate(_,_,_)).

check_dup(P,L):-
  apply(P,L),
  findall((P,L), apply(P,L), PL),
  length(PL,N),
  (N>1, \+ duplicate(N,P,L) -> assert(duplicate(N,P,L))),
  false.
check_dup(P,_):-
  findall((A,B,C),duplicate(A,B,C),L),
  length(L,N),
  (N>0 -> outdups(N,P); ok).

check_duplicates:-
  allwn(LR),
  member(P,LR),
  wnpred_arity(P,A), length(L,A),
  format("Checking duplicates in ~w/~w\n",[P,A]),
  check_dup(P,L),
  false.
check_duplicates:-
  nl.

/* ------------------------------------------
WN Validation
------------------------------------------ */

valid:-
  consult('db_version.pl'),
  wn_version(WV),
  atom_concat('output/wn_valid.pl-Output-',WV,F),
  write(F),
  consult('wn_load.pl'),
  time(check_keys), % Takes ~1 hour with Scryer
  symcheck,
  asymcheck,
  check_duplicates.

:- initialization(time(valid)).
