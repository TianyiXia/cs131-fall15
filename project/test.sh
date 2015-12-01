./run.sh

sleep 2

{
	sleep 1
	echo IAMAT qingwei.seas.ucla.edu +34.068930-118.445127 1400794645.392014450
	sleep 1
	echo WHATSAT qingwei.seas.ucla.edu 10 6
	sleep 2
} | telnet lnxsrv.seas.ucla.edu 12551 # Bolden

{
	sleep 2
	echo IAMAT anqi.seas.ucla.edu +35.068930-118.445127 1400994645.392014450
	sleep 1
} | telnet lnxsrv.seas.ucla.edu 12550 # Alford

# kill Alford
pkill -f 'python chat.py Alford'

{
	sleep 1
	echo WHATSAT qingweilan.seas.ucla.edu 10 6
	sleep 1
	echo WHATSAT qingwei.seas.ucla.edu 20 5
	sleep 2
} | telnet lnxsrv.seas.ucla.edu 12554 # Powell

# startup Alford
python chat.py Alford

{
	sleep 1
	echo IAMAT qingweipeterlan.seas.ucla.edu +31.068930-118.445127 1400994645.392014450
	sleep 1
	echo WHATSAT qingwei.seas.ucla.edu 20 5
	sleep 2
} | telnet lnxsrv.seas.ucla.edu 12552 # Hamilton

# kill Hamilton
pkill -f 'python chat.py Hamilton'

{
	sleep 1
	echo WHATSAT qingweipeterlan.seas.ucla.edu 20 5
	sleep 1
	echo WHATSAT qingwei.seas.ucla.edu 20 5
	sleep1
} | telnet lnxsrv.seas.ucla.edu 12550 # Alford

# kill all servers
./kill.sh
