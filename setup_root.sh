# set -x
set -e

echo creating temporary file...
TMPFILE=$(mktemp) || exit 1
trap 'rm -f "$TMPFILE"' EXIT

echo reading root configuration...
source root.cfg

root_wg_ip=$(bash string_to_ip.sh $root_wg_hostname)/8
echo root wg ip: $root_wg_ip

device=wg0

echo setting up wireguard device "$device"...
ip link delete $device
ip link add $device type wireguard
ip addr add $root_wg_ip dev $device
./0vpn $(cat private) $root_wg_hostname > "$TMPFILE"

echo root public key: $(cat "$TMPFILE" | wg pubkey)

wg set $device private-key "$TMPFILE"
wg set $device listen-port $root_port
ip link set $device up


echo setting up static leafs...
for leaf in $static_leaf_wg_hostnames; do
	leaf_private=$(go run main.go $(cat private) $leaf)
	leaf_public=$(echo $leaf_private | wg pubkey)
	leaf_wg_ip=$(bash string_to_ip.sh "$leaf")

    echo $leaf public key: $leaf_public
    echo $leaf wg ip: $leaf_wg_ip

	wg set $device peer $leaf_public persistent-keepalive 10 allowed-ips $leaf_wg_ip
	# wg set $device peer $leaf_public persistent-keepalive 10 allowed-ips 10.0.0.0/8

    leaf_config="$leaf"_leaf.cfg

    echo creating qr code for static leaf "$leaf_config"...
    echo '[Interface]' > "$leaf_config"
    echo "PrivateKey = $leaf_private" >> "$leaf_config"
    echo "Address = $leaf_wg_ip" >> "$leaf_config"
    echo '[Peer]' >> "$leaf_config"
    echo "PublicKey = $(cat $TMPFILE | wg pubkey)" >> "$leaf_config"
    echo "AllowedIps = 10.0.0.0/8" >> "$leaf_config"
    echo "Endpoint = $root_endpoint" >> "$leaf_config"
done

while true; do
	bash handle_leafs.sh
	sleep 10
done
