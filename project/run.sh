export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/opt/lib:~/opt/lib64:~/opt/share

for s in "Alford" "Bolden" "Hamilton" "Parker" "Powell"
do
    echo Starting Server $s
    python chat.py $s &
done
