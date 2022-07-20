set -xv
set -e

echo creating temporary file...
TMPFILE=$(mktemp) || exit 1
trap 'rm -f "$TMPFILE"' EXIT

echo reading root configuration...
source root.cfg

root_wg_ip=$(bash string_to_ip.sh $root_wg_hostname)/8

device=wg0

echo setting up wireguard device "$device"...
ip link delete $device
ip link add $device type wireguard
ip addr add $root_wg_ip dev $device
./ezvpn $(cat private) $root_wg_hostname > "$TMPFILE"
wg set $device private-key "$TMPFILE"
wg set $device listen-port $root_port
ip link set $device up


echo setting up static leafs...
for leaf in $static_leaf_hostnames; do
	leaf_private=$(go run main.go $(cat private) $leaf)
	leaf_public=$(echo $leaf_private | wg pubkey)
	leaf_wg_ip=$(bash string_to_ip.sh "$leaf")
	wg set $device peer $leaf_public persistent-keepalive 10 allowed-ips $leaf_wg_ip
	# wg set $device peer $leaf_public persistent-keepalive 10 allowed-ips 10.0.0.0/8

    echo creating qr code for static leaf "$leaf"...
    echo '[Interface]' > "$leaf.conf"
    echo "PrivateKey = $leaf_private" >> "$leaf.conf"
    echo "Address = $leaf_wg_ip" >> "$leaf.conf"
    echo '[Peer]' >> "$leaf.conf"
    echo "PublicKey = $(cat $TMPFILE | wg pubkey)" >> "$leaf.conf"
    echo "AllowedIps = 0.0.0.0/0" >> "$leaf.conf"
    echo "Endpoint = $root_endpoint" >> "$leaf_leaf.cfg"
done

