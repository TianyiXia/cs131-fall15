for s in "Alford" "Bolden" "Hamilton" "Parker" "Powell"
do
    echo Killing Server $s
    pkill -f "python chat.py $s" &
done
