#!/bin/bash
if ! [ $# -eq 2 ]; then
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
    echo "FATAL ERROR: No arguments supplied for NAMESPACE, EXTERNAL_IP"
    echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
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
