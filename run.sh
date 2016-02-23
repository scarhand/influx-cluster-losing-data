#!/bin/bash
BASEDIR=$(dirname $(readlink -f $0))
CONTAINER_NAME=$(basename $BASEDIR)

source $BASEDIR/functions.sh

set -e

build_container

stop_container "influx-node-1"
stop_container "influx-node-2"
stop_container "influx-node-3"

run_node_1
IP1=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-1`
run_node_2
IP2=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-2`
echo -e "Set the hostname of node 2 in node 1"
docker exec -it influx-node-1 /add_node_to_hosts.sh "influx-node-2" "$IP2"
sleep_countdown "Sleep 5 seconds before starting influx-node-3" 5
run_node_3
IP3=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-3`
echo -e "Set the hostname of node 3 in node 1"
docker exec -it influx-node-1 /add_node_to_hosts.sh "influx-node-3" "$IP3"
echo -e "Set the hostname of node 3 in node 2"
docker exec -it influx-node-2 /add_node_to_hosts.sh "influx-node-3" "$IP3"
sleep_countdown "Sleep 10 seconds to allow the cluster to fully start" 10

echo -e ""
echo -e "${GREEN}${BOLD}Cluster is up${NC}"
echo -e ""

echo -e "${BOLD}#############################${NC}"
echo -e "${BOLD}## Output of SHOW SERVERS: ##${NC}"
echo -e "${BOLD}#############################${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "SHOW SERVERS"

echo -e "${BOLD}##############################${NC}"
echo -e "${BOLD}## Output of SHOW DATABASES ##${NC}"
echo -e "${BOLD}##############################${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "SHOW DATABASES"

echo -e "${BOLD}Creating database mydb... ${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "CREATE DATABASE mydb"
echo -e ""

echo -e "${BOLD}##############################${NC}"
echo -e "${BOLD}## Output of SHOW DATABASES ##${NC}"
echo -e "${BOLD}##############################${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "SHOW DATABASES"

echo -e "${BOLD}############################${NC}"
echo -e "${BOLD}## Output of SELECT query ##${NC}"
echo -e "${BOLD}############################${NC}"
curl -G "http://$IP2:8086/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM cpu_load_short"
echo -e ""

echo -e ""
echo -e "${BOLD}Inserting data... ${NC}"
echo -e ""

curl -XPOST "http://$IP1:8086/write?db=mydb" --data-binary 'cpu_load_short,host=server02 value=0.67
cpu_load_short,host=server02,region=us-west value=0.55
cpu_load_short,direction=in,host=server01,region=us-west value=2.0
cpu_load_short,host=server02,region=very-old value=0.0001 1422568543702900257'

echo -e "${BOLD}############################${NC}"
echo -e "${BOLD}## Output of SELECT query ##${NC}"
echo -e "${BOLD}############################${NC}"
RESULT1=`curl -G "http://$IP2:8086/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM cpu_load_short" 2>/dev/null`
echo -e "$RESULT1"
echo -e ""

sleep_countdown "Sleeping 2 minutes." 120
echo -e "Done sleeping, now restarting the cluster"

stop_container "influx-node-1"
stop_container "influx-node-2"
stop_container "influx-node-3"

run_node_1
IP1=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-1`
run_node_2
IP2=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-2`
echo -e "Set the hostname of node 2 in node 1"
docker exec -it influx-node-1 /add_node_to_hosts.sh "influx-node-2" "$IP2"
sleep_countdown "Sleep 5 seconds before starting influx-node-3" 5
run_node_3
IP3=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-3`
echo -e "Set the hostname of node 3 in node 1"
docker exec -it influx-node-1 /add_node_to_hosts.sh "influx-node-3" "$IP3"
echo -e "Set the hostname of node 3 in node 2"
docker exec -it influx-node-2 /add_node_to_hosts.sh "influx-node-3" "$IP3"

sleep_countdown "Sleep 10 seconds to allow the cluster to fully start" 10

echo -e ""
echo -e "${GREEN}${BOLD}Cluster is up${NC}"
echo -e ""

echo -e "${BOLD}############################${NC}"
echo -e "${BOLD}## Output of SHOW SERVERS ##${NC}"
echo -e "${BOLD}############################${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "SHOW SERVERS"

echo -e "${BOLD}##############################${NC}"
echo -e "${BOLD}## Output of SHOW DATABASES ##${NC}"
echo -e "${BOLD}##############################${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "SHOW DATABASES"

echo -e "${BOLD}############################${NC}"
echo -e "${BOLD}## Output of SELECT query ##${NC}"
echo -e "${BOLD}############################${NC}"
curl -G "http://$IP2:8086/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM cpu_load_short"
echo -e ""
echo -e "${RED}${BOLD}I expect the database to exist but instead it says 'database not found error'${NC}"

echo -e "${GREEN}${BOLD}Creating database mydb... ${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "CREATE DATABASE mydb"

echo -e ""
echo -e "${BOLD}##############################${NC}"
echo -e "${BOLD}## Output of SHOW DATABASES ##${NC}"
echo -e "${BOLD}##############################${NC}"
docker exec -it influx-node-1 influx -host influx-node-1 -execute "SHOW DATABASES"

echo -e ""
echo -e "${BOLD}############################${NC}"
echo -e "${BOLD}## Output of SELECT query ##${NC}"
echo -e "${BOLD}############################${NC}"
curl -G "http://$IP2:8086/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM cpu_load_short"
echo -e ""
echo -e "${RED}${BOLD}Empty data in the new database, as expected, but it's no good that our old data was lost.${NC}"

echo -e ""
echo -e "${GREEN}${BOLD}Inserting extra data... ${NC}"
echo -e ""

curl -XPOST "http://$IP1:8086/write?db=mydb" --data-binary 'cpu_load_short,host=server_extra value=0.42'

echo -e "${BOLD}############################${NC}"
echo -e "${BOLD}## Output of SELECT query ##${NC}"
echo -e "${BOLD}############################${NC}"
RESULT2=`curl -G "http://$IP2:8086/query?pretty=true" --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM cpu_load_short" 2>/dev/null`
echo -e "$RESULT2"
echo -e ""
echo -e "${RED}${BOLD}After inserting some data we now suddenly have most of our old data back, except for the point with region 'very-old'.${NC}"