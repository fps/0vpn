# 0vpn

An experiment in making a wireguard VPN setup super easy (almost 0-conf). The only supported topology right now is the root-and-leafs (spokes-and-hub) topology.

# Howto

## General setup

Build the helper tool on all machines that want to take part in dynamic node setup (this includes AT LEAST the root node):

<pre>go build</pre>

This should have produced a binary called <code>ezvpn</code> (subject to change.)

Generate a master private key:

<pre>wg genkey > private</pre>

Guard this key carefully. It is used to derive all other private keys. That is what allows 0vpn to be almost 0-conf.

## On the root node

### Configuration

Copy over the private key into a file called <code>private</code> in the <code>0vpn</code> directory.

Copy over the <code>root.cfg.example</code> to <code>root.cfg</code> and edit it. Here it is included just as a reference:

<pre>
# The name of the root node which is used to derive its private key
root_wg_hostname=contabo

# The publically routable address of the root node
root_host=fps.io
root_port=4242
root_endpoint="$root_host":"$root_port"

# Names of static leaf nodes. These must be unique
# (including the root_wg_hostname.) These are again
# used to derive their private keys from the master
# private key.
static_leaf_wg_hostnames="phone"
</pre>

### Running

To setup the wireguard device and static peers run

<pre>bash setup_root.sh</pre>

Note that this requires privileges to create and configure the wireguard device.

The script will have created config files for every static leaf. In the case of the example config that would be <code>phone_leaf.cfg</code>. You can generate a QR code and display it in the terminal with

<pre>qrencode -t ansiutf8 < phone_leaf.cfg</pre>

On android you can just create a new tunnel directly from this QR code and things should work.

To listen for dynamic node additions, run the following script:

<pre>bash handle_leafs.sh</pre>

Note that this requires privileges to configure the wireguard device.
Note that for this to work you need the openbsd netcat version, as it's much less broken than the default debian installed netcat (PR's welcome to make this a proper daemon.)

## On each dynamic leaf node

### Configuration

Copy <code>leaf.cfg.example</code> to <code>leaf.cfg</code> and edit it. The example is included for reference here:

<pre>
# The name of the root node
root_hostname=contabo

# The publically routable endpoint running on the root node
root_endpoint=fps.io:4242
</pre>

Copy over the private key to <code>private</code>

### Running

Run the script <code>bash setup_leaf.sh [node name]</code> to create and setup the wireguard device.

Run the script <code>bash announce_leaf.sh [node name]</code> to make the root aware of the new node.

# Done


