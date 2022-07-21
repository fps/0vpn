package main

import (
	"os"
	"fmt"
	"crypto/ed25519"
	"encoding/base64"
)

func MixinString(masterKey ed25519.PrivateKey, hostname string) ed25519.PrivateKey {
    sigPrivSlice := masterKey[0:32]
    for index := 0; index < len(sigPrivSlice); index++ {
        sigPrivSlice[index] = sigPrivSlice[index] ^ hostname[index % len(hostname)]
    }
    return ed25519.NewKeyFromSeed(sigPrivSlice)
}


func main() {
	if len(os.Args) < 4 {
		fmt.Println("Usage: 0vpn command [arguments]")
		fmt.Println("")
		fmt.Println("where command can be one of the following:")
		fmt.Println("")
		fmt.Println("mixin [key] [string]")
		fmt.Println("   derive a new key by mixing in string")
		fmt.Println("   into key and output the new key to stdout")
		fmt.Println("")
		fmt.Println("resolve [string]")
		fmt.Println("   hash [string] into an IP address")
		os.Exit(1)
	}

	if os.Args[1] == "mixin" {
    	input_key_bytes := make([]byte, 32)
    	_, err := base64.StdEncoding.Decode(input_key_bytes, []byte(os.Args[2]))
    	if (err != nil) {
    		fmt.Println("Failed to decode key")
            os.Exit(1)
    	}
    	input_key := ed25519.PrivateKey(input_key_bytes)
    
    	mixed_key := MixinString(input_key, os.Args[3])
    
    	fmt.Println(base64.StdEncoding.EncodeToString(mixed_key[0:32]))
    }
}


