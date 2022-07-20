echo 10.$((0x$(echo $1 | sha256sum  | cut -c 1-2))).$((0x$(echo $1 | sha256sum  | cut -c 3-4))).$((0x$(echo $1 | sha256sum  | cut -c 5-6)))

