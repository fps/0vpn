set -x

source root.cfg

# root_hostname=contabo
# root_port=4242
root_wg_ip=$(bash string_to_ip.sh $root_hostname)/8

# leafs="nixos physalis"

device=wg0

ip link add $device type wireguard
ip addr add $root_wg_ip dev $device
./ezvpn $(cat private) $root_hostname > private_derived
wg set $device private-key private_derived
wg set $device listen-port $root_port
ip link set $device up

for leaf in $leafs; do
	leaf_private=$(go run main.go $(cat private) $leaf)
	leaf_public=$(echo $leaf_private | wg pubkey)
	leaf_ip=$(bash string_to_ip.sh "$leaf")
	wg set $device peer $leaf_public persistent-keepalive 10 allowed-ips $leaf_ip
done

