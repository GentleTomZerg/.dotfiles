#!/bin/bash

#**********************************************************
# Convert url link to clash config
# rely on docker container: subconverter
# Usage: subconverter.sh <targer> <url> <config>
# target: proxy software you are using, eg: clash | surge
# url: the subscribe url link of your proxy service provider
# config: not necessary
#**********************************************************
SUBCONVERTER_ADDR="localhost:25500"
CONTAINER_NAME_OR_ID="subconverter"

# encode url link, replace characters like white space
urlencode() {
	python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

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

# Check the health of subconverter
curl $SUBCONVERTER_ADDR/version ||
	{
		echo "$CONTAINER_NAME_OR_ID is not running, use the command below" &&
			echo "sudo docker run -d --restart=always -p 25500:25500 --name subconverter tindy2013/subconverter:latest" &&
			exit 1
	}

# Specify the filename which the configration will be stored
echo "File to store the configration: ~/.config/clash/"
read -r filename

# convert url to yaml proxy file
echo "$SUBCONVERTER_ADDR/sub?target=${target}&url=$(urlencode "$url")&config=${config}"
curl "$SUBCONVERTER_ADDR/sub?target=${target}&url=$(urlencode "$url")&config=${config}" >~/.config/clash/"${filename}".yaml

if [[ $(wc -l <~/.config/clash/"${filename}".yaml) -lt 4 ]]; then
	echo "Error: ~/.config/clash/${filename}.yaml are less than 4 lines"
	echo "Try to update proxy again"
	exit 1
fi
# Preprocess the clash config

# Comment out the mode: Rule line
sed -i 's/mode: Rule/#mode: Rule/' ~/.config/clash/"${filename}".yaml

# Add the external-ui: clash-dashboard line
sed -i '/external-controller/ i external-ui: clash-dashboard' ~/.config/clash/"${filename}".yaml
# Add the secret password to use the clash-dashboard
sed -i '/external-controller/ i secret: 707399' ~/.config/clash/"${filename}".yaml
