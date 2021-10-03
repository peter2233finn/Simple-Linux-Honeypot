# Author: Peter Finn
# Github: https://github.com/peter2233finn

# Load the configuration file in
confFile="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/listenerHoneypot.conf"
echo "Using configuration file: $confFile"
chmod +x ${confFile}
. ${confFile}

# Listen function. This will neep it going indefenitely
function listen(){
        while true; do
		p=$1
          	      cat "$responce"/"$p"".txt"| nc -nlvcp $p > "$log"/"$p""-"$(date +'%F_%T') 2>&1
          	      sleep 0.8;
          	      echo "Got request..."
        done
}

# This will kill services running on honeypot ports, restart ports if they are not already open
# and restart the netcat listener if the port is not open. This is checked every one minuite.
function lManager(){
        p=$1
        kill -9 $(netstat -antp|grep $p|tr "/" " "|awk '{print $7}'|tr "\n" " ")
        sleep 5
        while true;do
                if [[ "$(netstat -antp | grep $p|grep LISTEN)" == "" ]]; then
                        kill -9 $! $(netstat -antp|grep $p|tr "/" " "|awk '{print $7}'|tr "\n" " ")
                        listen "$p" &
                        echo "Restarted as port $p not open"
                else
                        echo "Not restarting $p as nc is running"
                fi
                sleep 1m
        done &


}

# This will run through all ports and check if they are configured to be open.
# If they are configured to be open, the lManager is called.
for p in {8000..25000}; do
	# check if default is changed
	if [ "$(grep "This is" "$responce""/""$p"".txt")" == "" ]; then
	        lManager $p &
		sleep 1
	fi
done
