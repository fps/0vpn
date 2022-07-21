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
./ezvpn $(cat private) "$1" > $TMPFILE
wg set wg0 private-key $TMPFILE
ip link set wg0 up

root_private=$(./ezvpn $(cat private) $root_hostname)
root_public=$(echo $root_private | wg pubkey)
root_ip=$(bash string_to_ip.sh "$root_hostname")

wg set wg0 peer $root_public endpoint $root_endpoint persistent-keepalive 10 allowed-ips 10.0.0.0/8

echo Entering leaf announcement loop
while true; do 
	bash announce_leaf.sh "$1"
	sleep "$announce_interval"
done
