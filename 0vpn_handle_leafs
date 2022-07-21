set +x

device=wg0

IFS=' '

nc -ulkp 4243 | while read line; do 
    echo got line: $line;
    read -ra tokens <<< "$line"
    echo "  host: ${tokens[0]}"
    echo "  public: ${tokens[1]}"

    echo "  rederiving leaf public key:"
    leaf_private=$(go run main.go $(cat private) $line)
    echo "    private: $leaf_private"
    leaf_public=$(echo $leaf_private | wg pubkey)
    echo "    public: $leaf_public"
    leaf_wg_ip=$(bash string_to_ip.sh "${tokens[0]}")

    echo "  checking if they match:"
    if [ "${tokens[1]}" == "$leaf_public" ]; then 
        echo "  match! adding the leaf..."
        wg set $device peer $leaf_public persistent-keepalive 10 allowed-ips $leaf_wg_ip
    else
        echo "  key mismatch. not adding leaf..."
    fi
done
