type ('terminal, 'nonterminal) symbol =
	| T of 'terminal
	| N of 'nonterminal;;

(* Write function convert_grammar gram1 that returns a hw2-style
gammar comverted from the hw1-style grammar gram1. *)

let rec find_rules nonterm rules =
	match rules with
	| [] -> []
	| (lhs, rhs)::t -> if (lhs = nonterm)
	then rhs::(find_rules nonterm t)
	else find_rules nonterm t;;

let convert_grammar gram1 =
	match gram1 with
	| start, rules -> (start, fun nonterm -> (find_rules nonterm rules));;

(* Write function parse_prefix gram that returns matcher for grammar 'gram'.
When applied to an acceptor accept and a fragment frag, the matcher must
return the first acceptable match of a prefix of frag, by trying the
grammar rules in order *)

let rec and_match rules rule accpt deriv frag =
	if rule = [] then accpt deriv frag
	else match frag with
		(* fragment is empty but rule is not, fail nad return None *)
		| [] -> None
		| h::t -> match rule with
			| [] -> None
			| (T ts)::tail -> if h = ts then (and_match rules tail accpt deriv t) else None
			| (N ns)::tail -> (or_match rules ns (rules ns) (and_match rules tail accpt) deriv frag)

and or_match rules symbol rules_symbol accpt deriv frag =
	match rules_symbol with
	| [] -> None
	| top_rule::end_rules ->
		match (and_match rules top_rule accpt (deriv@[(symbol, top_rule)]) frag) with
		| None -> (or_match rules symbol end_rules accpt deriv frag)
		| any -> any

let parse_prefix grammar accpt frag =
	match grammar with
	| (start, rules) -> or_match rules start (rules start) accpt [] frag;;
