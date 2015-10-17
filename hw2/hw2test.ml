(* tests for convert_grammar *)

type awksub_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num

let awksub_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];
    Num, [T"1"];
    Num, [T"2"];
    Num, [T"3"];
    Num, [T"4"];
    Num, [T"5"];
    Num, [T"6"];
    Num, [T"7"];
    Num, [T"8"];
    Num, [T"9"]]

let awksub_grammar = Expr, awksub_rules

let awkish_grammar = 
    Expr,
    function
    | Expr -> [ [T"("; N Expr; T")"];
                [N Num];
                [N Expr; N Binop; N Expr];
                [N Lvalue];
                [N Incrop; N Lvalue];
                [N Lvalue; N Incrop];
            ];
    | Lvalue -> [ [T"$"; N Expr]; ];
    | Incrop -> [ [T"++"]; [T"--"]; ];
    | Binop -> [ [T"+"]; [T"-"]; ];
    | Num -> [  [T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"]; 
                [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"];
            ]

let awk_grammar_2 = convert_grammar awksub_grammar

let my_convert_grammar_test_0 = snd(awk_grammar_2) Num = snd(awkish_grammar) Num
let my_convert_grammar_test_1 = snd(awk_grammar_2) Expr = snd(awkish_grammar) Expr
let my_convert_grammar_test_2 = snd(awk_grammar_2) Lvalue = snd(awkish_grammar) Lvalue
let my_convert_grammar_test_3 = snd(awk_grammar_2) Incrop = snd(awkish_grammar) Incrop
let my_convert_grammar_test_4 = snd(awk_grammar_2) Binop = snd(awkish_grammar) Binop

(* tests for parse_prefix *)

type new_awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let accept_all derivation string = Some (derivation, string)

let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
          [N Term]]
     | Term ->
     [[N Num];
      [N Lvalue];
      [N Incrop; N Lvalue];
      [N Lvalue; N Incrop];
      [T"("; N Expr; T")"]]
     | Lvalue ->
     [[T"$"; N Expr]]
     | Incrop ->
     [[T"++"];
      [T"--"]]
     | Binop ->
     [[T"+"];
      [T"-"]]
     | Num ->
     [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
      [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])

let test_1 =
    ((parse_prefix awkish_grammar accept_all 
        ["$"; "5"; "+"; "$"; "3"; "+"; "$"; "5"; "-"; "6"])
    = Some
   ([(Expr, [N Term; N Binop; N Expr]); (Term, [N Lvalue]);
     (Lvalue, [T "$"; N Expr]); (Expr, [N Term; N Binop; N Expr]);
     (Term, [N Num]); (Num, [T "5"]); (Binop, [T "+"]);
     (Expr, [N Term; N Binop; N Expr]); (Term, [N Lvalue]);
     (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Num]);
     (Num, [T "3"]); (Binop, [T "+"]); (Expr, [N Term]); (Term, [N Lvalue]);
     (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Num]);
     (Num, [T "5"]); (Binop, [T "-"]); (Expr, [N Term]); (Term, [N Num]);
     (Num, [T "6"])], []));;

(* define symbols for personal grammar *)

type sentence_symbols =
  | Sentence | Subject | Predicate | Article | Noun | Verb | DirectObject

let sentence_grammar = 
  (Sentence, function
    | Sentence -> [[N Subject; N Predicate]]
    | Subject -> [[N Article; N Noun]]
    | Predicate -> [[N Verb; N DirectObject]]
    | DirectObject -> [[N Article; N Noun]]
    | Article -> [[T"THE"]; [T"A"]]
    | Noun -> [[T"DOG"]; [T"MAN"]; [T"WOMAN"]]
    | Verb -> [[T"BITES"]]
  )

let test_2 =
  ((parse_prefix sentence_grammar accept_all 
    ["THE"; "DOG"; "BITES"; "A"; "MAN"])
  = Some
  ([(Sentence, [N Subject; N Predicate]); (Subject, [N Article; N Noun]);
  (Article, [T "THE"]); (Noun, [T "DOG"]);
  (Predicate, [N Verb; N DirectObject]); (Verb, [T "BITES"]);
  (DirectObject, [N Article; N Noun]); (Article, [T "A"]);
  (Noun, [T "MAN"])], []));;
