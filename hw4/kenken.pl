% ================================= kenken/3 ==================================

% -------------------------------- Performance --------------------------------

/* 
 * Time taken for 'kenken(3, [], T)' to get all possible answers
 * user time: 0.004 sec,  system time: 0.000 sec,  cpu time: 0.004 sec
 *
 * Time taken for 'kenken(4, [], T)' to get all possible answers
 * user time: 0.108 sec,  system time: 0.004 sec,  cpu time: 0.112 sec
 */

% -------------------------------- Performance --------------------------------

% Checks validity of a list L of length N
% A list is legal if it contains exactly one instance of 1 to N

legal_list(N, L) :- length(L, N), fd_domain(L, 1, N), fd_all_different(L).

% Checks validity all rows & columns (lists) of an NxN table T

legal_table(N, T) :- length(T, N),
                     maplist(legal_list(N), T),
                     transpose(T, TT),
                     maplist(legal_list(N), TT).

kenken(N, C, T) :- legal_table(N, T),
                   maplist(cons(T), C),
                   maplist(fd_labeling, T).

% ================================= kenken/3 ==================================

% ============================== plain_kenken/3 ===============================

% -------------------------------- Performance --------------------------------

/*
 * Time taken for 'plain_kenken(3, [], T)' to get all possible answers
 * user time: 0.004 sec,  system time: 0.008 sec,  cpu time: 0.012 sec
 *
 * Time taken for 'plain_kenken(4, [], T)' to get all possible answers
 * user time: 2.440 sec,  system time: 0.020 sec,  cpu time: 2.460 sec
 */

% -------------------------------- Performance --------------------------------

% Checks that list contains exactly one instance of 1 to N

check_list(0, []).
check_list(N, [N|T]) :- N > 0, M is N-1, check_list(M, T).

% Check that all rows & columns are legal
% Uses check_list from above to check each row/column

plain_legal_list(N, L) :- check_list(N, PL), permutation(PL, L).

% Check that all rows are legal

plain_legal_rows([], 0, _).
plain_legal_rows([HT|TT], I, N) :- I > 0, M is I-1,
                                   plain_legal_list(N, HT),
                                   plain_legal_rows(TT, M, N).

% Check that all rows & columns are legal

plain_legal_table(T, N) :- plain_legal_rows(T, N, N),
                           transpose(T, TT),
                           plain_legal_rows(TT, N, N).

% Check constraints

apply_constraints([], _).
apply_constraints([Hc|Tc], T) :- cons(T, Hc), apply_constraints(Tc, T).

plain_kenken(N, C, T) :- plain_legal_table(T, N),
                         apply_constraints(C, T).

% ============================== plain_kenken/3 ===============================

% ================================ Constraints ================================

% nth(N, List, Element) : succeeds if the Nth argument of List is Element.
% table(Coord, T, E) : succeeds if element at Coord in T is E.

table(Coord, T, E) :- Coord = R-C, nth(R, T, Row), nth(C, Row, E).

table_sum([], _, 0).
table_sum([Head|Tail], T, Sum) :- table(Head, T, E),
                                  table_sum(Tail, T, Sum2),
                                  Sum #= Sum2 + E.

table_prod([], _, 1).
table_prod([Head|Tail], T, Product) :- table(Head, T, E),
                                       table_prod(Tail, T, Product2),
                                       Product #= Product2 * E.

table_diff(Coord1, Coord2, T, Diff) :- table(Coord1, T, E1),
                                       table(Coord2, T, E2),
                                       (Diff #= E1 - E2 ; Diff #= E2 - E1).

table_div(Coord1, Coord2, T, Div) :- table(Coord1, T, E1),
                                     table(Coord2, T, E2),
                                     (E1 #= Div * E2 ; E2 #= Div *E1).

% Constraints

cons(T, C) :- C = +(Sum, Coords), table_sum(Coords, T, Sum).
cons(T, C) :- C = *(Prod, Coords), table_prod(Coords, T, Prod).
cons(T, C) :- C = -(Diff, Coord1, Coord2), table_diff(Coord1, Coord2, T, Diff).
cons(T, C) :- C = /(Div, Coord1, Coord2), table_div(Coord1, Coord2, T, Div).

% ================================ Constraints ================================

% ================================= transpose =================================

% Predicates used to transpose matrices

transpose([[]|_], []).
transpose(M, [X|T]) :- row(M, X, M1), transpose(M1, T).
row([], [], []).
row([[X|Xs]|Ys], [X|R], [Xs|Z]) :- row(Ys, R, Z).

% ================================= transpose =================================

% ============================== noop-kenken/3 ================================

/*
 * Since noop-kenken does not provide operator constraints, we should manually
 * set that as a parameter for passing into the predicate. Suppose we call this
 * parameter 'O'. This parameter should hold an array containing elements
 * selected from +, -, *, /. Thus our new predicate becomes
 *
 *     noop_kenken(N, C, O, T)
 * 
 * where 'N' is the size of the table, 'C' is the constraints without operators,
 * 'O' is the list of operators, 'T' is the solved table.
 *
 * So when the predicate returns with an answer, we should have something like
 *
 *     O = ......
 *     T = ......
 * 
 * If we ask for more solutions with ';', gprolog should say 'no'.
 * If the solution cannot be found, gprolog should say 'no'.
 */

% ============================== noop-kenken/3 ================================
