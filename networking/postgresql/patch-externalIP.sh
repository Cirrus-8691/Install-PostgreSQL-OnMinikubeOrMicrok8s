echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 🔵  Patch postgresql service"
echo "┃────────────────────────────────────────────"
echo "┃ 🔷  Parameters"
echo "┃────────────────────────────────────────────"
NAMESPACE=$1
EXTERNAL_IP=$2
PACKAGE_NAME="postgresql"
echo "┃ 🔹 package    = "$PACKAGE_NAME
echo "┃ 🔹 namespace  = "$NAMESPACE
echo "┃ 🔹 externalIp = "$EXTERNAL_IP
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SPEC="{"spec":{"externalIPs":["$EXTERNAL_IP"]}}"
echo "🔷🔷🔷"
kubectl -n $NAMESPACE patch svc postgresql -p "$SPEC"


# kubectl -n $NAMESPACE patch svc postgresql -p '{"spec":{"externalIPs":["192.168.0.24"]}}'
