echo Announcing leaf to root node.
echo $1 $(echo $(./ezvpn $(cat private) $1) | wg pubkey) > /dev/udp/fps.io/4243

