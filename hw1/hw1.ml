(* subset: returns true iff a is subset of b *)
let rec subset a b =
	match a, b with
	| [], _ -> true
	| _, [] -> false
	| [a], [b] -> if a == b then true else false
	| h1::t1, h2::t2 -> 
	if (if h1 == h2 then true else subset [h1] t2) then subset t1 b else false;;

