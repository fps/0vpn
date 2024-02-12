# 0vpn

An experiment in making a wireguard VPN setup super easy (almost 0-conf). The only supported topology right now is the server-and-clients (a.k.a. root-and-leafs, hub-and-spokes) topology. This is mainly useful if you just need a VPN for your personal machines and you have a cheap server available on the internet (the smallest virtual private server (VPS) should be fine.) Since all your machines are under your control it is easy to have a shared secret on all of them. This shared secret is a private key from which all other privae and public keys are derived via mixing in names.

## How does it work?

We give up security for convenience:

* There is a central "master" private key from which all other keys are derived mixing in the nodes' names. This master key can (optionally) be derived from a password/phrase using <code>0vpn-tool key-from-password > keyfile</code>, which reads the password from <code>stdin</code>.
* Clients can dynamically announce the wish to partake in the VPN by sending their node name and their (derived) public key. The server listens on an extra UDP port for these announcements.
* The server can rederive the client's key and check for the correctness of the transmitted public key.
* If those check out the client's public key is added to the peers list.
* The VPN uses IPv6 exclusively. 
* The network prefix is derived from the private key by hashing with <code>sha256sum</code>.
* IP addresses are derived from the node's names via hashing with <code>sha256sum</code> as well. So the names must be unique. If 
* For non linux clients that only have a "vanilla" wireguard "app" we provide ready to use .cfg files (these are written to the TMPDIR path reported during startup of <code>0vpn-root</code> and can be used with the equivalents of wg-quick.)
* We run an instance of dnsmasq on the server which resolves clients in the "internal" TLD (the TLD can be configured as well).

# Requirements

## On the server

* netcat-openbsd (it won't work with the traditional netcat)
* dnsmasq
* wireguard-tools
* bash
* core utilities like cat, kill, mktemp, etc..

## On dynamic clients

* wireguard-tools
* bash
* core utilities like cat, kill, mktemp, etc..
* systemd-resolved 

## On static clients

* wireguard in some form or other (wireguard-android, wireguard-windows)

# Howto

## General setup

Build the helper tool on all machines that want to take part in dynamic client setup (this includes AT LEAST the server):

<pre>go build</pre>

This should have produced a binary called <code>0vpn-tool</code> 

Generate a master private key:

<pre>wg genkey > private</pre>

Guard this key carefully. It is used to derive all other private keys.

Alternatively derive the master private key from a password:

<pre>./0vpn-tool key-from-password > private</pre>

Enter the password.

## On the server

### Running

In the simplest case, just run:

<pre>0vpn-server --keyfile [file] --server-name [name] --server-hostname [hostname] --static-clients "client_a client_b"</pre>

where:

Note that this requires privileges to create and configure the wireguard device.

The script will have created config files for every static leaf. In the case of the example config that would be <code>client_a.cfg</code> and <code>client_b.cfg</code>. You can generate a QR code and display it in the terminal with

<pre>0vpn-show-qr client_a.cfg</pre>

On android you can just create a new tunnel directly from this QR code and things should work.

Note that this requires privileges to configure the wireguard device.
Note that for this to work you need the openbsd netcat version, as it's much less broken than the default debian installed netcat (PR's welcome to make this a proper daemon.)

## On each dynamic client

### Running

<pre>0vpn-client --keyfile [file] --server-name [name] --server-hostname [hostname] --client-name [name]</pre>

Note that the value of the <code>--server-name</code> option has to be identical to the one passed to the server.

## All client and server options:

<pre>
Common available options:
  --server-hostname [hostname]     (default: "localhost")
  --server-name [name]             (default: "ogfx100")
  --wireguard-port [port]          (default: "4242")
  --announce-port [port]           (default: "4243")
  --dns-port [port]                (default: "53")
  --keyfile [filename]             (default: "key")
  --tld [domain-name]              (default: "internal")
  --wireguard-device [device-name] (default: "wg0")

Server-only options:
  --static-clients [list of names] (default: "")

Client-only options:
  --client-name [name]             (default: "ogfx100")
  --announce-interval [seconds]    (default: "30")
</pre>

Note that some options like <code>--server-name</code> and <code>--client-name</code> are set to <code>$(hostname --short)</code> per default (in this case <code>ogfx100</code>). 

# Done

