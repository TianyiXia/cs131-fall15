let my_subset_test0 = subset [2;3;4;7;5;8] [1;2;3;4;5;6;7;8;9]
let my_subset_test1 = subset [10;10;9;9;9;9;9] [1;2;3;4;5;6;7;8;9;10]

let my_equal_sets_test0 = equal_sets [4;5;8] [4;4;4;8;5;5;5;5]
let my_equal_sets_test1 = equal_sets [1;2] [2;2;2;2;2;2;2;2;2;1]

let my_set_union_test0 = equal_sets (set_union [1;2] [1;2;3;5;6]) [1;2;3;5;6]
let my_set_union_test1 = equal_sets (set_union [] []) []

let my_set_intersection_test0 =
  equal_sets (set_intersection [2;3;7;8;9] [1;2;3;9]) [2;3;9]
let my_set_intersection_test1 =
  equal_sets (set_intersection [3;1;3;6;7;7;8;8;8] [1;2;3;1;4;2;3;5]) [3;1]
let my_set_intersection_test2 =
  equal_sets (set_intersection [3;1;3;6;7;7;8;8;8] [2;4;2;5]) []

let my_set_diff_test0 = equal_sets (set_diff [1;3;4;4] [1;4;3;1]) []
let my_set_diff_test1 = equal_sets (set_diff [4;3;1;1;3] [1;3;5;6;8]) [4]

let my_computed_fixed_point_test0 =
  computed_fixed_point (=) (fun x -> x / 3) 1000000000 = 0

let computed_periodic_point_test0 =
  computed_periodic_point (=) (fun x -> x / 2) 10 (-1) = 0

type battle_nonterminals =
	| Start | Weapon | Sword | Bat | Gun | Axe
	| Attack | Defend | Run | Battle;;

let my_filter_blind_alleys_test0 =
filter_blind_alleys (Start,
	[
		Battle, [N Attack];
		Battle, [N Defend];
		Battle, [N Run];
		Attack, [N Weapon; N Weapon];
		Weapon, [N Sword];
		Weapon, [N Bat];
		Weapon, [N Gun];
		Weapon, [N Axe];
		Defend, [T"D"];
		Sword, [T"S1"];
		Sword, [T"S2"];
		Bat, [T"B"];
		Gun, [T"G"];
	]) = (Start,
	[
		Battle, [N Attack];
		Battle, [N Defend];
		Attack, [N Weapon; N Weapon];
		Weapon, [N Sword];
		Weapon, [N Bat];
		Weapon, [N Gun];
		Defend, [T"D"];
		Sword, [T"S1"];
		Sword, [T"S2"];
		Bat, [T"B"];
		Gun, [T"G"];
	]);;
