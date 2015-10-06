(* subset: returns true iff a is subset of b *)
let rec subset a b =
	match a, b with
	| [], _ -> true
	| _, [] -> false
	| [a], [b] -> if a = b then true else false
	| h1::t1, h2::t2 -> if (if h1 = h2 then true else subset [h1] t2) then subset t1 b else false;;

(* equal_sets: returns true iff the sets are equal *)
let equal_sets a b = subset a b && subset b a;;

(* set_union: returns a list of the union of two sets *)
let rec set_union a b = 
	match a, b with
	| [], [] -> []
	| h1::t1, [] -> if subset [h1] t1 then set_union [] t1 else (set_union [] t1) @ [h1]
	| [], h2::t2 -> if subset [h2] t2 then set_union [] t2 else (set_union [] t2) @ [h2]
	| h1::t1, h2::t2 -> 
	if not (h1 = h2) && not (subset [h1] t1) && not (subset [h1] t2) && not (subset [h2] t1) && not (subset [h2] t2) then (set_union t1 t2) @ [h1] @ [h2] 
	else if not (h1 = h2) && not (subset [h1] t1) && not (subset [h1] t2) then (set_union t1 t2) @ [h1]
	else if not (h1 = h2) && not (subset [h2] t1) && not (subset [h2] t2) then (set_union t1 t2) @ [h2]
	else if not (h1 = h2) then set_union t1 t2
	else if not (subset [h1] t1) && not (subset [h1] t2) then (set_union t1 t2) @ [h1]
	else set_union t1 t2;;

(* set_intersection: returns a list of the intersection of two sets *)
let rec set_intersection a b =
	match a, b with
	| _, [] -> []
	| [], _ -> []
	| h1::t1, b ->
	if subset [h1] b then set_union (set_intersection t1 b) [h1] 
	else set_intersection t1 b;;

(* set_diff: returns a list of the set of all members in a but not in b *)
let rec set_diff a b = 
	match a, b with
	| [], _ -> []
	| _, [] -> a
	| h1::t1, b -> if (subset [h1] b) then set_diff t1 b 
	else h1::(set_diff t1 b);;

(* computed_fixed_point: returns computed fixed point for f w/ respect to x *)
let rec computed_fixed_point eq f x =
	if eq (f x) x then x
	else computed_fixed_point eq f (f x);;

(* computed_periodic_point: returns computed periodic point for f w/ respect to
period p w/ respect to x assuming that eq dertmines equality for f's domain *)
let rec computed_periodic_point eq f p x = 
	match p with
	| 0 -> x
	| _ -> if eq x (f (computed_periodic_point eq f (p-1) (f x))) then x
	else (computed_periodic_point eq f p (f x));;


(* filter_blind_alleys *)

(* define the symbol type, symbol can either be nonterminal or terminal *)
type ('nonterminal, 'terminal) symbol = 
	| N of 'nonterminal
	| T of 'terminal;;

(* returns true if 'symbol' exists in 'symbols' or if 'symbol' is terminal *)
let rec is_symbol_good symbols symbol =
	match symbol with
	| T _ -> true
	| N n -> subset [n] symbols;;

(* check if the 'symbols' in rhs are all good *)
let rec is_rhs_good symbols rhs =
	match rhs with
	| [] -> true
	| h::t -> if (is_symbol_good symbols h) 
	then is_rhs_good symbols t 
	else false;;

let rec get_terminal_symbols symbols rules =
	match rules with
	| [] -> symbols
	| (a, b)::t ->
	if (is_rhs_good symbols b) 
		then ( if (subset [a] symbols) then get_terminal_symbols symbols t 
			  else get_terminal_symbols (a::symbols) t )
	else get_terminal_symbols symbols t;;

(* returns tuple of terminal symbols and the original rules *)
(* this function is used for finding good symbols using computed_fixed_point *)
let get_symbols_tuple (good_symbols, rules) =
	( (get_terminal_symbols good_symbols rules), rules );;

let symbols_are_same computed_symbols rules =
	match computed_symbols, rules with
	| (a, _), (b, _) -> equal_sets a b;;

let get_good_symbols_tuple (good_symbols, rules) =
	computed_fixed_point symbols_are_same get_symbols_tuple ([], rules);;

let get_good_symbols (good_symbols, rules) =
	fst (get_good_symbols_tuple (good_symbols, rules));;

let rec get_good_rules good_symbols rules =
	match rules with
	| [] -> []
	| (a, b)::t -> if (is_rhs_good good_symbols b)
	then (a, b)::(get_good_rules good_symbols t)
	else get_good_rules good_symbols t;;

let filter_blind_alleys grammar =
	match grammar with
	| (start, rules) ->
		(start, get_good_rules (get_good_symbols ([], rules)) rules);;
