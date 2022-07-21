# 0vpn

An experiment in making a wireguard VPN setup super easy (almost 0-conf). The only supported topology right now is the root-and-leafs (spokes-and-hub) topology.

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

### Configuration

Copy over the private key into a file called <code>private</code> in the <code>0vpn</code> directory.

Copy over <code>common.cfg.example</code> to <code>common.cfg</code> and edit it according to your setup.

Copy over <code>root.cfg.example</code> to <code>root.cfg</code> and edit it according to your setup.

### Running

To setup the wireguard device and static peers run

<pre>bash setup_root.sh</pre>

Note that this requires privileges to create and configure the wireguard device.

The script will have created config files for every static leaf. In the case of the example config that would be <code>phone_leaf.cfg</code>. You can generate a QR code and display it in the terminal with

<pre>qrencode -t ansiutf8 < phone_leaf.cfg</pre>

On android you can just create a new tunnel directly from this QR code and things should work.

Note that this requires privileges to configure the wireguard device.
Note that for this to work you need the openbsd netcat version, as it's much less broken than the default debian installed netcat (PR's welcome to make this a proper daemon.)

## On each dynamic leaf node

### Configuration

Copy <code>common.cfg.example</code> to <code>common.cfg</code> and edit it according to your needs.

Copy <code>leaf.cfg.example</code> to <code>leaf.cfg</code> and edit it if needed.

Copy over the private key to <code>private</code>

### Running

Run the script <code>bash setup_leaf.sh [node name]</code> to create and setup the wireguard device and announce the leaf node to the root node.

# Done

# Post Scriptum

The script <code>string_to_ip.sh</code> can be used to find out the wireguard IP addresses of other nodes in the network.

<pre>
$ bash string_to_ip.sh contabo
10.65.177.6
</pre>

In the future we might implement automatically generating a dnsmasq config on the root node to enable DNS resolution (PRs welcome.)
