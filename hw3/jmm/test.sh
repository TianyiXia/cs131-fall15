echo ""
echo "  * Testing ..."
echo "    Running on $1 threads, with $2 transitions"
echo ""

run="java"

echo "  * Null Test *"
echo ""
for i in {1..50}
do
	# echo -en "  $i\t"
	$run UnsafeMemory Null $1 $2 100 2 4 6 8 10 10 20 30 40 50 5 6 3 0 3 10 20 30 40 50 | grep -Eow "[0-9.]+"
done
echo ""

echo "  * Synchronized Test *"
echo ""
for i in {1..50}
do
	# echo -en "  $i\t"
	$run UnsafeMemory Synchronized $1 $2 100 2 4 6 8 10 10 20 30 40 50 5 6 3 0 3 10 20 30 40 50 | grep -Eow "[0-9.]+"
done
echo ""

echo "  * Unsynchronized Test"
echo ""
for i in {1..50}
do
	# echo -en "  $i\t"
	$run UnsafeMemory Unsynchronized $1 $2 20 5 6 3 0 3100 2 4 6 8 10 10 20 30 40 50 5 6 3 0 3 10 20 30 40 50 | grep -Eow "[0-9.]+"
done
echo ""

echo "  * GetNSet Test *"
echo ""
for i in {1..50}
do
	# echo -en "  $i\t"
	$run UnsafeMemory GetNSet $1 $2 100 2 4 6 8 10 10 20 30 40 50 5 6 3 0 3 10 20 30 40 50 | grep -Eow "[0-9.]+"
done
echo ""

echo "  * BetterSafe Test *"
echo ""
for i in {1..50}
do
	# echo -en "  $i\t"
	$run UnsafeMemory BetterSafe $1 $2 100 2 4 6 8 10 10 20 30 40 50 5 6 3 0 3 10 20 30 40 50 | grep -Eow "[0-9.]+"
done
echo ""

echo "  * BetterSorry Test *"
echo ""
for i in {1..50}
do
	# echo -en "  $i\t"
	$run UnsafeMemory BetterSorry $1 $2 100 2 4 6 8 10 10 20 30 40 50 5 6 3 0 3 10 20 30 40 50 | grep -Eow "[0-9.]+"
done
echo ""

echo "# TESTS ENDED #"
