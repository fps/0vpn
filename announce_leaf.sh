echo $1 $(echo $(./ezvpn $(cat private) $1) | wg pubkey) | nc -q0 -u fps.io 4243

