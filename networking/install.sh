#!/bin/bash
if ! [ $# -eq 2 ]; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "FATAL ERROR: No arguments supplied for project, externalIp"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    exit 1
fi
PROJECT_NAME=$1
EXTERNAL_IP=$2
APP_INSTALLED="PostgreSql"
PACKAGE_NAME="postgresql"
echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 🔵  Install $APP_INSTALLED for project $PROJECT_NAME"
echo "┃────────────────────────────────────────────"
echo "┃ 🔷  Parameters"
echo "┃────────────────────────────────────────────"
NAMESPACE="$PROJECT_NAME-$PACKAGE_NAME"
echo "┃ 🔹 package    = "$PACKAGE_NAME
echo "┃ 🔹 namespace  = "$NAMESPACE
echo "┃ 🔹 externalIp = "$EXTERNAL_IP

NAMESPACE_FOUND=$(kubectl get namespace | grep $NAMESPACE)
if [[ "$NAMESPACE_FOUND" == *"$NAMESPACE"* ]]; then

    echo "┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "┃ 🟢  $APP_INSTALLED already installed"
    echo "┃────────────────────────────────────────────"
    echo "┃ 🟢 You do not have to restore data"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

else
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    PV_NAME=$PACKAGE_NAME"-pv-0"
    echo "🛂  Check PersistentVolume $PV_NAME"
    kubectl get pv $PV_NAME
    if ! [ $? -eq 0 ]; then

        echo "✨  Install StorageClass"
        kubectl apply -f storageclass.yaml
        if ! [ $? -eq 0 ]; then
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            echo "🔥FATAL ERROR: 🔴  INSTALL $APP_INSTALLED: storageclass"
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            exit 1
        fi

        echo "✨  Install PersistentVolume"
        kubectl apply -f values/$PROJECT_NAME/pv-$PACKAGE_NAME.yaml
        if ! [ $? -eq 0 ]; then
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            echo "🔥FATAL ERROR: 🔴  INSTALL $APP_INSTALLED: PersistentVolume"
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            exit 1
        fi
        echo "✨  Create /storage"
        mkdir /storage
        echo "✨  /storage/data-$PV_NAME"
        mkdir /storage/data-$PV_NAME
        chown -R 1001:1001 /storage/data-$PV_NAME
        chmod -R a+rwx /storage/data-$PV_NAME

    else
        echo "♻️  Recycle existing PersistentVolume"
        kubectl patch pv $PV_NAME -p '{"spec":{"claimRef": null}}'
        if ! [ $? -eq 0 ]; then
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            echo "🔥FATAL ERROR: 🔴  RECYCLE $APP_INSTALLED: PersistentVolume"
            echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
            exit 1
        fi
    fi

    echo "✨  Create Namespace "$NAMESPACE
    kubectl create ns $NAMESPACE
    if ! [ $? -eq 0 ]; then
        echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        echo "🔥FATAL ERROR: 🔴  INSTALL $APP_INSTALLED: Namespace"
        echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        exit 1
    fi

    echo "✨  Install $APP_INSTALLED"
    helm -n $NAMESPACE install $PACKAGE_NAME bitnami/$PACKAGE_NAME -f values/$PROJECT_NAME/$PACKAGE_NAME.yaml
    if ! [ $? -eq 0 ]; then
        echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        echo "🔥FATAL ERROR: 🔴  INSTALL $APP_INSTALLED: "$PACKAGE_NAME
        echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        exit 1
    fi
    patch-externalIP.sh $NAMESPACE $EXTERNAL_IP
    if ! [ $? -eq 0 ]; then
        echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
        echo "🔥FATAL ERROR: 🔴  INSTALL  $APP_INSTALLED: patch service externalIP"
        echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    exit 1
    fi
fi

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 🟢 $APP_INSTALLED ready 😀 "
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
