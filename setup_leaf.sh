set -x
set -e

# USAGE: bash setup_leaf.sh [leaf_hostname]
# 
# Needs privileges to create and configure a 
# wireguard device.

echo creating temporary file...
TMPFILE=$(mktemp) || exit 1

trap 'rm -f "$TMPFILE"' EXIT

echo reading leaf config...
source leaf.cfg

echo setting up wireguard device "$device"...
ip link delete wg0
ip link add wg0 type wireguard
ip addr add $(bash string_to_ip.sh $1)/8 dev wg0
./ezvpn $(cat private) $1 > $TMPFILE
wg set wg0 private-key $TMPFILE
ip link set wg0 up

root_private=$(./ezvpn $(cat private) $root_hostname)
root_public=$(echo $root_private | wg pubkey)
root_ip=$(bash string_to_ip.sh "$root_hostname")

wg set wg0 peer $root_public endpoint $root_endpoint persistent-keepalive 10 allowed-ips 10.0.0.0/8

