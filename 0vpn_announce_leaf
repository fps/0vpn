set -e
echo $1 $(echo $(./0vpn-tool mixin $(cat private) $1) | wg pubkey) > /dev/udp/fps.io/4243

