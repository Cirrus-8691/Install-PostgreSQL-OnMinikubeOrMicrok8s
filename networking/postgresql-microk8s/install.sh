#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
red=$(tput setaf 1)
white=$(tput setaf 7)
if ! [ $# -eq 2 ]; then
  echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "┃${white} 🔥FATAL ERROR: No arguments supplied for ${bold}${underline}STORAGE_CLASS, PROJECT_NAME${normal}"
  echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
  exit 1
fi
STORAGE_CLASS=$1
PROJECT_NAME=$2

INFOS=$(ip a | grep 'inet ' | grep /24)
IFS=' /' read -r -a INFO_ITEMS <<< "$INFOS"
MICROK8S_SERVER_IP=${INFO_ITEMS[1]}

APP_INSTALLED="PostgreSql"
PACKAGE_NAME="postgresql"
NAMESPACE="$PROJECT_NAME-$PACKAGE_NAME"

# Warning: no PV with STORAGE_CLASS: "ceph-rbd" 

echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 🔵  Install $APP_INSTALLED for project $PROJECT_NAME"
echo "┃────────────────────────────────────────────"
echo "┃ 🔷  Parameters"
echo "┃────────────────────────────────────────────"
echo "┃ 🔹 package    = "$PACKAGE_NAME
echo "┃ 🔹 namespace  = "$NAMESPACE
echo "┃ 🔹 externalIp = "$MICROK8S_SERVER_IP

NAMESPACE_FOUND=$(microk8s kubectl get namespace | grep $NAMESPACE)
if [[ "$NAMESPACE_FOUND" == *"$NAMESPACE"* ]]; then

    echo "┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "┃ 🟢  $APP_INSTALLED already installed for project $PROJECT_NAME"
    echo "┃────────────────────────────────────────────"
    echo "┃ 🟢 You do not have to restore data"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

else
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "✨  Create Namespace "$NAMESPACE
    microk8s kubectl create ns $NAMESPACE
    if ! [ $? -eq 0 ]; then
        echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃${white} 🔥FATAL ERROR: Installing $APP_INSTALLED ${bold}${underline}Namespace${normal} "
        echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
        exit 1
    fi

    echo "✨  Install $APP_INSTALLED"
    microk8s helm -n $NAMESPACE install $PACKAGE_NAME bitnami/$PACKAGE_NAME -f ../values/$MICROK8S_SERVER_IP/$STORAGE_CLASS-microk8s.yaml
    if ! [ $? -eq 0 ]; then
        echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃${white} 🔥FATAL ERROR: Installing $APP_INSTALLED ${bold}${underline}$PACKAGE_NAME${normal} "
        echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
        exit 1
    fi

    ./patch-externalIP.sh $NAMESPACE $MICROK8S_SERVER_IP
    if ! [ $? -eq 0 ]; then
        echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃${white} 🔥FATAL ERROR: Installing $APP_INSTALLED ${bold}${underline}patch-externalIP${normal} "
        echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
        exit 1
    fi

fi

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 🟢 $APP_INSTALLED ready 😀 "
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
