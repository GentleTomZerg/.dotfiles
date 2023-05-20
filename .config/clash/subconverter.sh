#!/bin/bash

# Check if three arguments were provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 target url config"
    echo "target: the software you are using"
    echo "url: the url provided by your server"
    echo "config: not necessary"
    exit 1
fi

# Assign the arguments to variables
target="$1"
url="$2"
config="NULL"

if [ "$#" -eq 3 ]; then
    config="$3"
fi


# Set container name or ID
CONTAINER_NAME_OR_ID="subconverter"

# Check if container is already running
if docker ps --filter "name=$CONTAINER_NAME_OR_ID" | grep -q $CONTAINER_NAME_OR_ID ; then
    echo "Container is running"
else
    echo "Container is not running, use the command below"
    echo "sudo docker run -d --restart=always -p 25500:25500 --name subconverter tindy2013/subconverter:latest"
    exit 1
fi

# Execute curl command
curl http://localhost:25500
curl "http://127.0.0.1:25500/sub?target=${target}&url=${url}&config=${config}"
