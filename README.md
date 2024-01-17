# 0vpn

An experiment in making a wireguard VPN setup super easy (almost 0-conf). The only supported topology right now is the root-and-leafs (spokes-and-hub) topology.

## How does it work?

We give up security for convenience:

* There is a central "master" private key from which all other keys are derived mixing in the nodes' names. This master key can (optionally) be derived from a password/phrase.
* Leaf nodes can dynamically announce the wish to partake in the VPN by sending their node name and their (derived) public key. The root node listens on an extra UDP port for these announcements.
* The root node can rederive the leaf node's key and check for the correctness of the transmitted public key.
* If those check out the lead node's public key is added to the peers list.
* IP addresses are derived from the node's names in the 10.123.0.0/16 subnet. So they must be unique and there might be collisions which will make stuff not work well.
* For non linux clients that only have a "vanilla" wireguard "app" we provide ready to use .cfg files (these are written to the TMPDIR path reported during startup of <code>0vpn-root</code>
* We run an instance of dnsmasq on the root node which resolves clients in the "internal" tld.

# Requirements

## On the root node

* netcat-openbsd (it won't work with the traditional netcat)
* dnsmasq
* wireguard-tools
* bash
* core utilities like cat, kill, mktemp, etc..

## On dynamic leafs

* wireguard-tools
* bash
* core utilities like cat, kill, mktemp, etc..
* systemd-resolved 

## On static leafs

* wireguard in some form or other (wireguard-android, wireguard-windows)

# Howto

## General setup

Build the helper tool on all machines that want to take part in dynamic node setup (this includes AT LEAST the root node):

<pre>go build</pre>

This should have produced a binary called <code>0vpn-tool</code> 

Generate a master private key:

<pre>wg genkey > private</pre>

Guard this key carefully. It is used to derive all other private keys.

Alternatively derive the master private key from a password:

<pre>./0vpn-tool key-from-password > private</pre>

Enter the password.

## On the root node

### Running

To setup the wireguard device and static peers run

<pre>0vpn-root [device] [key_file] [root_name] [root_host] [root_port] [root_annouce_port] [static_leafs] [dns_port]</pre>

where:

<pre>
[device]:             A name for the wireguard device created (example: wg0)
[key_file]:           The file containing the "master" private key from which all other keys are derived
[root_name]:          The name of the root node. Example: myroot
[root_host]:          The publically routable hostname of the root node. Example: example.com
[root_port]:          The port on the root_host where the wireguard endpoint lives. Example: 4242
[root_announce_port]: The port the root node listens on for dynamic leaf node addition announcements. Example: 4243
[static_leafs]:       A single string containing leaf node names that are added as peers without dynamic announcement. Example: "my_phone my_desktop my_laptop"
[dns_port]:           The port dnsmasq listens on. Many clients have problems with ports other than 53 - so best set it to 53. Example: 5553
</pre>

Note that this requires privileges to create and configure the wireguard device.

The script will have created config files for every static leaf. In the case of the example config that would be <code>phone_leaf.cfg</code>. You can generate a QR code and display it in the terminal with

<pre>0vpn-show-qr phone_leaf.cfg</pre>

On android you can just create a new tunnel directly from this QR code and things should work.

Note that this requires privileges to configure the wireguard device.
Note that for this to work you need the openbsd netcat version, as it's much less broken than the default debian installed netcat (PR's welcome to make this a proper daemon.)

## On each dynamic leaf node

### Running

<pre>0vpn-leaf [device] [key] [root_name] [root_host] [root_port] [root_annouce_port] [persistent_keepalive] [leaf_name] [dns_port]</pre>

where all parameters have to be identical to the ones for the root node (except for the device parameter which can be freely chosen and leaving out the static_leafs completely) and additionally:

<pre>
[persistent_keepalive]: Number of seconds after which to send keepalive packets
[leaf_name]:            The name of the leaf
</pre>

# Done

# Post Scriptum

The command <code>0vpn-resolve [name]</code> can be used to find out the wireguard IP addresses of other nodes in the network.

<pre>
$ 0vpn-resolve contabo
10.123.65.177
</pre>

