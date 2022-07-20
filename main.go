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
	if len(os.Args) < 3 {
		fmt.Println("Usage: ezvpn private_key hostname")
		os.Exit(1)
	}
	input_key_bytes := make([]byte, 32)
	_, err := base64.StdEncoding.Decode(input_key_bytes, []byte(os.Args[1]))
	if (err != nil) {
		fmt.Println("Failed to decode key")
	}
	input_key := ed25519.PrivateKey(input_key_bytes)

	mixed_key := MixinString(input_key, os.Args[2])

	fmt.Println(base64.StdEncoding.EncodeToString(mixed_key[0:32]))
}


