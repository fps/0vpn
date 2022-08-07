package main

import (
	"crypto/ed25519"
	"golang.org/x/crypto/scrypt"
	"encoding/base64"
	"fmt"
	"os"
	"bufio"
	"io/ioutil"
)

func MixinString(masterKey ed25519.PrivateKey, hostname string) ed25519.PrivateKey {
	sigPrivSlice := masterKey[0:32]
	for index := 0; index < len(sigPrivSlice); index++ {
		sigPrivSlice[index] = sigPrivSlice[index] ^ hostname[index%len(hostname)]
	}
	return ed25519.NewKeyFromSeed(sigPrivSlice)
}

func print_usage() {
	fmt.Println("Usage: 0vpn command [arguments]")
	fmt.Println("")
	fmt.Println("where command can be one of the following:")
	fmt.Println("")
	fmt.Println("help")
	fmt.Println("    show this help text")
	fmt.Println("")
	fmt.Println("mixin [key-file] [string]")
	fmt.Println("   Derive a new key by mixing in string")
	fmt.Println("   into key and output the new key to stdout")
	fmt.Println("")
	fmt.Println("key-from-password")
	fmt.Println("   Derive a key from a password given at")
	fmt.Println("   stdin and output the new key to stdout")
	fmt.Println("")
}

func main() {
	if len(os.Args) < 2 || os.Args[1] == "help" {
		print_usage()
		os.Exit(1)
	}

	if os.Args[1] == "mixin" && len(os.Args) == 4 {
		input_key_bytes := make([]byte, 32)
		input_file_bytes, err := ioutil.ReadFile(os.Args[2])
		if err != nil {
			fmt.Println("Failed to read key-file")
			fmt.Println(err)
			os.Exit(1)
		}
		_, err = base64.StdEncoding.Decode(input_key_bytes, input_file_bytes)
		if err != nil {
			fmt.Println("Failed to decode key")
			fmt.Println(err)
			os.Exit(1)
		}
		input_key := ed25519.PrivateKey(input_key_bytes)

		// mixed_key := MixinString(input_key, os.Args[3])
		mixed_key, err := scrypt.Key([]byte(os.Args[3]), input_key, 32768, 8, 1, 32)
		if err != nil {
			fmt.Println("Failed to derive key")
			fmt.Println(err)
			os.Exit(1)
		}
		fmt.Println(base64.StdEncoding.EncodeToString(mixed_key[0:32]))
		os.Exit(0)
	}
	if os.Args[1] == "key-from-password" && len(os.Args) == 2 {
		line, _ := bufio.NewReader(os.Stdin).ReadString('\n')
		key, err := scrypt.Key([]byte(line), nil, 32768, 8, 1, 32)
		if err != nil {
			fmt.Println("Failed to derive key")
			fmt.Println(err)
			os.Exit(1)
		}
		fmt.Println(base64.StdEncoding.EncodeToString(key))
		os.Exit(0)
	}

	print_usage()
	os.Exit(1)
}
