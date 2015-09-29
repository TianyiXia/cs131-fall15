(* subset: returns true iff a is subset of b *)
let rec subset a b =
	match a, b with
	| [], _ -> true
	| _, [] -> false
	| [a], [b] -> if a == b then true else false
	| h1::t1, h2::t2 -> if (if h1 == h2 then true else subset [h1] t2) then subset t1 b else false;;

(* equal_sets: returns true iff the represented sets are equal *)
let rec equal_sets a b = subset a b && subset b a;;

(* set_union: returns a list representing the union of two sets *)
let rec set_union a b = 
	match a, b with
	| [], [] -> []
	| h1::t1, [] -> set_union [h1] t1
	| [], h2::t2 -> set_union [h2] t2
	| h1::t1, h2::t2 -> 
	if not (subset [h1] t1) && not (subset [h1] t2) && not (subset [h2] t1) && not (subset [h2] t2) then (set_union t1 t2) @ h1 @ h2 
	else if not (subset [h1] t1) && not (subset [h1] t2) then (set_union t1 t2) @ h1
	else if not (subset [h2] t1) && not (subset [h2] t2) then (set_union t1 t2) @ h2
	else set_union t1 t2;;