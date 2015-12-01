for s in "Alford" "Bolden" "Hamilton" "Parker" "Powell"
do
    echo Starting Server $s
    python chat.py $s &
done
