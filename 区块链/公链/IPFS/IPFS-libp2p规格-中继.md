# libp2p电路中继规格 Circuit 

> Circuit Switching for libp2p, also known as TURN or Relay in Networking literature.

实现
- js-libp2p-circuit
- go-libp2p-circuit

[TOC]

# 综述

The circuit relay is a means to establish connectivity between libp2p nodes (e.g. IPFS nodes) that wouldn't otherwise be able to establish a direct connection to each other.

Relay is needed in situations where nodes are behind NAT, reverse proxies, firewalls and/or simply don't support the same transports (e.g. go-ipfs vs. browser-ipfs). Even though libp2p has modules for NAT traversal (go-libp2p-nat), piercing through NATs isn't always an option. The circuit relay protocol exists to overcome those scenarios.

Unlike a transparent tunnel, where a libp2p peer would just proxy a communication stream to a destination (the destination being unaware of the original source), a circuit relay makes the destination aware of the original source and the circuit followed to establish communication between the two. This provides the destination side with full knowledge of the circuit which, if needed, could be rebuilt in the opposite direction.

Apart from that, this relayed connection behaves just like a regular connection would, but over an existing swarm stream with another peer (instead of e.g. TCP). A node asks a relay node to connect to another node on its behalf. The relay node short-circuits streams between the two nodes, enabling them to reach each other.

Relayed connections are end-to-end encrypted just like regular connections.

The circuit relay is both a tunneled transport and a mounted swarm protocol. The transport is the means of establishing and accepting connections, and the swarm protocol is the means to relaying connections.

```txt
+-----+    /ip4/.../tcp/.../ws/p2p/QmRelay    +-------+    /ip4/.../tcp/.../p2p/QmTwo       +-----+
|QmOne| <------------------------------------>|QmRelay|<----------------------------------->|QmTwo|
+-----+   (/libp2p/relay/circuit multistream) +-------+ (/libp2p/relay/circuit multistream) +-----+
     ^                                         +-----+                                         ^
     |           /p2p-circuit/QmTwo            |     |                                         |
     +-----------------------------------------+     +-----------------------------------------+
```

Notes for the reader:

We're using the /p2p multiaddr protocol instead of /ipfs in this document. /ipfs is currently the canonical way of addressing a libp2p or IPFS node, but given the growing non-IPFS usage of libp2p, we'll migrate to using /p2p.
