# 0vpn

An experiment in making a wireguard VPN setup super easy (almost 0-conf). The only supported topology right now is the root-and-leafs (spokes-and-hub) topology.

## How does it work?

We give up security for convenience:

* There is a central "master" private key from which all other keys are derived by XOR'ing in the nodes name.
* Leaf nodes can dynamically announce the wish to partake in the VPN by sending their node name and their (derived) public key. The root node listens on an extra UDP port for these announcements.
* The root node can rederive the leaf node's key and check for the correctness of the transmitted public key.
* If those check out the lead node's public key is added to the peers list.

# Requirements

* netcat-openbsd (it won't work with the traditional netcat)
* wireguard-tools 

# Howto

## General setup

Build the helper tool on all machines that want to take part in dynamic node setup (this includes AT LEAST the root node):

<pre>go build</pre>

This should have produced a binary called <code>0vpn</code> (subject to change.)

Generate a master private key:

<pre>wg genkey > private</pre>

Guard this key carefully. It is used to derive all other private keys. That is what allows 0vpn to be almost 0-conf.

## On the root node

### Running

To setup the wireguard device and static peers run

<pre>0vpn root [device] [key] [root_name] [root_host] [root_port] [root_annouce_port] [static_leafs]</pre>

where:

<pre>
[device]:             A name for the wireguard device created (example: wg0)
[key]:                The "master" private key from which all other keys are derived
[root_name]:          The name of the root node. Example: myroot
[root_host]:          The publically routable hostname of the root node. Example: example.com
[root_port]:          The port on the root_host where the wireguard endpoint lives. Example: 4242
[root_announce_port]: The port the root node listens on for dynamic leaf node addition announcements. Example: 4243
[static_leafs]:       A single string containing leaf node names that are added as peers without dynamic announcement. Example: "my_phone my_desktop my_laptop"
</pre>

Note that this requires privileges to create and configure the wireguard device.

The script will have created config files for every static leaf. In the case of the example config that would be <code>phone_leaf.cfg</code>. You can generate a QR code and display it in the terminal with

<pre>0vpn_show_qr phone_leaf.cfg</pre>

On android you can just create a new tunnel directly from this QR code and things should work.

Note that this requires privileges to configure the wireguard device.
Note that for this to work you need the openbsd netcat version, as it's much less broken than the default debian installed netcat (PR's welcome to make this a proper daemon.)

## On each dynamic leaf node

### Running

<pre>0vpn leaf [device] [key] [root_name] [root_host] [root_port] [root_annouce_port] [persistent_keepalive] [leaf_name]</pre>

where all parameters have to be the same as for the root node (except for the device parameter which can be freely chosen and leaving out the static_leafs completely) and additionally:

<pre>
[persistent_keepalive]: Number of seconds after which to send keepalive packets
[leaf_name]:            The name of the leaf
<pre>

# Done

# Post Scriptum

The command <code>0vpn resolve [name]</code> can be used to find out the wireguard IP addresses of other nodes in the network.

<pre>
$ 0vpn resolve contabo
10.123.65.177
</pre>

In the future we might implement automatically generating a dnsmasq config on the root node to enable DNS resolution (PRs welcome.)
