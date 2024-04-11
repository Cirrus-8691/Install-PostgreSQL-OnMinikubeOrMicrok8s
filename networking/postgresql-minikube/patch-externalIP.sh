#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
red=$(tput setaf 1)
white=$(tput setaf 7)
if ! [ $# -eq 2 ]; then
  echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "┃${white} 🔥FATAL ERROR: No arguments supplied for ${bold}${underline}NAMESPACE, EXTERNAL_IP${normal}"
  echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
  exit 1
fi
if ! [ $USER == "root" ]; then
  echo "$red┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "┃$white 🔥 FATAL ERROR: USER is not root, it's $red$USER"
  echo "$red┠────────────────────────────────────────────$blue"
  echo "$red┃${white}run ${blue}sudo $0 $1 $2"
  echo "$red┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$white"
  exit 1
fi

PACKAGE_NAME="postgresql"
NAMESPACE=$1
EXTERNAL_IP=$2
echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 🔵  Patch $PACKAGE_NAME service"
echo "┃────────────────────────────────────────────"
echo "┃ 🔷  Parameters"
echo "┃────────────────────────────────────────────"
echo "┃ 🔹 package    = "$PACKAGE_NAME
echo "┃ 🔹 namespace  = "$NAMESPACE
echo "┃ 🔹 externalIp = "$EXTERNAL_IP
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SPEC={\"spec\":{\"externalIPs\":[\"$EXTERNAL_IP\"]}}
kubectl -n $NAMESPACE patch svc $PACKAGE_NAME -p $SPEC
