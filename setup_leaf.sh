set -e

# USAGE: bash setup_leaf.sh [leaf_hostname]
# 
# Needs privileges to create and configure a 
# wireguard device.

echo Creating temporary file...
TMPFILE=$(mktemp) || exit 1

trap 'rm -f "$TMPFILE"' EXIT

echo Reading leaf config...
source leaf.cfg

echo Setting up wireguard device "$device"...
echo Removing old device: $(ip link delete wg0)
ip link add wg0 type wireguard

leaf_ip=$(bash string_to_ip.sh "$1")
echo Leaf IP: "$leaf_ip"

ip addr add "$leaf_ip" dev wg0
./0vpn-tool mixin $(cat private) "$1" > $TMPFILE
wg set wg0 private-key $TMPFILE
ip link set wg0 up

echo Deriving root keys...

root_private=$(./0vpn-tool mixin $(cat private) $root_wg_hostname)
root_public=$(echo $root_private | wg pubkey)
root_ip=$(bash string_to_ip.sh "$root_wg_hostname")

echo Root public key: "$root_public"
echo Root leaf IP: "$root_ip"

echo Setting up root node endpoint...
wg set wg0 peer $root_public endpoint $root_endpoint persistent-keepalive 10 allowed-ips 10.0.0.0/8

echo Final wireguard config:
wg show wg0

echo Entering leaf announcement loop...
while true; do 
	bash announce_leaf.sh "$1"
	sleep "$announce_interval"
done
