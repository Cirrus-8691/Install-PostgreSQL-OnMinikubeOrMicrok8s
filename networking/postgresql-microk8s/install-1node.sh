#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
red=$(tput setaf 1)
white=$(tput setaf 7)
if ! [ $# -eq 3 ]; then
  echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "┃${white} 🔥FATAL ERROR: No arguments supplied for ${bold}${underline}STORAGE_CLASS, PROJECT_NAME, EXTERNAL_IP${normal}"
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

STORAGE_CLASS=$1
PROJECT_NAME=$2
EXTERNAL_IP=$3

INFOS=$(ip a | grep 'inet ' | grep /24)
IFS=' /' read -r -a INFO_ITEMS <<< "$INFOS"
MICROK8S_SERVER_IP=${INFO_ITEMS[1]}

APP_INSTALLED="PostgreSql"
PACKAGE_NAME="postgresql"
NAMESPACE="$PACKAGE_NAME-$PROJECT_NAME"

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

        echo "✨  Install StorageClass"
        microk8s kubectl apply -f ../postgresql-microk8s/hostpath-storageclass.yaml
        if ! [ $? -eq 0 ]; then
            echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "┃${white} 🔥FATAL ERROR: Installing $APP_INSTALLED ${bold}${underline}StorageClass${normal}"
            echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
            exit 1
        fi

    # Check "pv-prestgresql.yaml"
    STORAGE_FOLDER="/srv/storage"
    PV_NAME=$PACKAGE_NAME"-"$STORAGE_CLASS
    PV_PATH=$STORAGE_FOLDER"/data-"$PV_NAME
    echo "✨  Install PersistentVolume"
    microk8s kubectl apply -f ../values/$MICROK8S_SERVER_IP/$STORAGE_CLASS-$PACKAGE_NAME.yaml
    if ! [ $? -eq 0 ]; then
        echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃${white} 🔥FATAL ERROR: Installing $APP_INSTALLED ${bold}${underline}PersistentVolume${normal} "
        echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
        exit 1
    fi
    echo "✨  Creating "$STORAGE_FOLDER
    mkdir $STORAGE_FOLDER
    echo "✨  Creating "$PV_PATH
    mkdir $PV_PATH
    chown -R 1001:1001 $PV_PATH
    chmod -R a+rwx $PV_PATH

    echo "✨  Install $APP_INSTALLED"
    microk8s helm -n $NAMESPACE install $PACKAGE_NAME bitnami/$PACKAGE_NAME -f ../values/$MICROK8S_SERVER_IP/$PACKAGE_NAME.yaml
    if ! [ $? -eq 0 ]; then
        echo "${red}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃${white} 🔥FATAL ERROR: Installing $APP_INSTALLED ${bold}${underline}$PACKAGE_NAME${normal} "
        echo "${red}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${white}"
        exit 1
    fi

    ./patch-externalIP.sh $NAMESPACE $EXTERNAL_IP
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
