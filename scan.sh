# Author: Peter Finn
# Github: https://github.com/peter2233finn

# Load configuration file
confFile="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/listenerHoneypot.conf"
echo "Using configuration file: $confFile"
chmod +x ${confFile}
. ${confFile}

# This is the configuration for the nmap commands used.
function nmapCommand(){
        ip="$*"
        echo "Date: $(date) IP: ${ip}" >> "${scan}/${ip}.vuln"
        nmap --script vulscan/vulscan.nse,nmap-vulners/vulners.nse --script-args vulscandb=scipvuldb.csv -sV --host-timeout 3h -Pn -p- "$ip" >> "${scan}/${ip}.vuln"
        echo "Date: $(date) IP: ${ip}" >> "${scan}/${ip}.og"
        nmap --host-timeout 3h -Pn -sV ${ip} -oG "${scan}/${ip}.og"
}

function doscan(){
        x="$*"
#       ip=$(echo $x | awk '{print $1}' | xargs)
#       brute=$(echo $x | awk '{print $2}' | xargs)
#       echo "Currently scanning: $ip who tried $brute times"
#       if [[ ! -f "./done/$ip" ]] ; then
#               echo "$date" > "./done/$ip"
#               chmod 777 "./done/$ip"
#               if [[ $(grep "$ip" /home/peter/cowrie/blockCowIps) != "" ]]; then
#                       echo "REMOVING FROM BLOCKLIST"
#                       sudo iptables -w -A INPUT -s $ip -j ACCEPT
#                       sudo iptables -w -A OUTPUT -s $ip -j ACCEPT
#                       nmapCommand $ip
#                       sudo iptables -w -A INPUT -s $ip -j DROP
#                       sudo iptables -w -A OUTPUT -s $ip -j DROP
#                                                                                                                                                                                                                                     else
#                       echo SCANNING UNBLOCKED ADDRESS
                        nmapCommand $x
#               fi
#                       echo "host: $ip" >> "./nmap-results/"$ip".og"
#               else
#                       echo "$ip already scanned. skipping"
#               fi
}

while true; do
        forks=8
        confFile="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/listenerHoneypot.conf"
        echo "Using configuration file: $confFile"
        chmod +x ${confFile}
        . ${confFile}

        strings ${log}/*|grep "Connection from" |awk '{print $3}'|tr ":" " "|awk '{print $1}'|sort|uniq -c|awk "{if(\$1>=$scanThreshhold)print \$2}" > /tmp/active
        ls $scan | tr  "-" " " |awk '{print $1}'|sort|uniq > /tmp/scaned
        comm -13 /tmp/scaned /tmp/active > /tmp/toscan

        cat /tmp/toscan | while read x ; do
        ((pidNum++))
        (doscan $x) &
        PID+=($!)
        if (( $pidNum % $forks == 0 )); then
                # Wait for all processes to finish
                for p in ${PID[@]}; do
                        tail --pid=$p -f /dev/null
                done
                PID=()
                sleep 0.8
        fi
        done
        sleep 1m
break
done
