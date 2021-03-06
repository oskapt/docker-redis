#!/bin/bash

D_VERBOSE=false
D_FOREGROUND=false
D_WORKSPACE=/workspace/docker-redis/docker_files/run/db
D_IP=10.66.8.110/26
D_SHELL=false
D_BRIDGE=br1

PIPEWORK=$(pwd)/pipework
IMAGE="monachus/redis"
MOUNT=/var/lib/redis

function usage() {
cat <<EOF

usage: $0 options

OPTIONS: 
  -v    verbose output [${D_VERBOSE}]
  -f    foreground [${D_FOREGROUND}]
  -w    workspace [${D_WORKSPACE}]
  -i    ip [${D_IP}] 
  -s    start shell [${D_SHELL}]
  -b    bridge interface [${D_BRIDGE}]  

EOF
}

function get_ip() {
    LOCAL_IP=$( ip a sh dev $1 | grep inet | grep -v inet6 | awk '{ print $2 }' | awk -F/ '{ print $1 }' )
}

if [[ $(whoami) != "root" ]]; then
    echo "Please run this with root privileges."
    exit 1
fi

while getopts "hvfw:i:sb" OPTION
do
    case $OPTION in
        h)
            usage
            exit
            ;;
        v)
            VERBOSE=0
            ;;
        f)
            OPT_FOREGROUND=0
            ;;
        w)
            OPT_WORKSPACE=$OPTARG
            ;;
        i)
            OPT_IP=$OPTARG
            ;;
        s)
            OPT_SHELL=/bin/bash
            INTERACTIVE="-i -t"
            ;;
        b)
            OPT_BRIDGE=$OPTARG
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

WORKSPACE=${OPT_WORKSPACE:-$D_WORKSPACE}
SHELL=${OPT_SHELL:-''}
BRIDGE=${OPT_BRIDGE:-$D_BRIDGE}
IP=${OPT_IP:-$D_IP}

ENVVARS="-e MOUNT=${MOUNT} -e IP=$( echo ${IP} | awk -F/ '{ print $1 }' )"

# Figure out a local IP to attach apache redirects to
for DEV in eth1 eth2; do
    get_ip ${DEV}
    if [[ ${LOCAL_IP} =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]];  then
        break
    fi
    LOCAL_IP=
done

# Add any extra environment variables here
ENVVARS="${ENVVARS}"

CMD="docker run ${ENVVARS} -d -v ${WORKSPACE}:${MOUNT} ${INTERACTIVE} ${IMAGE} ${SHELL}" 

if [[ ${VERBOSE} ]]; then
	echo "Starting container with command:"
	echo "    ${CMD}"
fi

CID=$($CMD)

if [[ ! -e ${PIPEWORK} ]]; then
	echo "Unable to execute ${PIPEWORK}" 1>&2
elif [ ! -z ${CID} ]; then
    sleep 1
    ${PIPEWORK} ${BRIDGE} ${CID} ${IP}
    if [[ $? -eq 0 ]]; then
    	if [[ ${VERBOSE} ]]; then
        	echo "Pipework IP running on ${IP}"
    	fi 
    else
        echo "Error setting up pipework." 1>&2
    fi
else
    echo "Error setting up pipework." 1>&2
fi        

if [[ ${OPT_FOREGROUND} ]]; then
    echo "Press enter to activate your session."
    docker attach ${CID}
    echo
else
    echo ${CID}
fi


