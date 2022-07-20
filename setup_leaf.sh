set -x

source leaf.cfg

ip link add wg0 type wireguard
ip addr add $(bash string_to_ip.sh $leaf_hostname)/8 dev wg0
./ezvpn $(cat private) $leaf_hostname > private_derived
wg set wg0 private-key private_derived
ip link set wg0 up

root_private=$(./ezvpn $(cat private) $root_hostname)
root_public=$(echo $root_private | wg pubkey)
root_ip=$(bash string_to_ip.sh "$root_hostname")

wg set wg0 peer $root_public endpoint $root_endpoint persistent-keepalive 10 allowed-ips $root_ip

