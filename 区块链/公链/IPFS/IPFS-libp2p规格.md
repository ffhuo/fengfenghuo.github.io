# libp2规范

原文: <https://github.com/libp2p/specs>
作者: [Juan Benet](https://github.com/jbenet) [David Dias](https://github.com/diasdavid)

[TOC]

## 摘要

本文档描述了IPFS的网络层协议。网络层协议提供了任何两个 **IPFS网络节点** 之间 **点对点传输能力**（可靠和不可靠）。

本文档定义了在**libp2p**中实现的规范。

## 1 介绍

在开发[IPFS, the InterPlanetary FileSystem](IPFS概要.md)的过程中, 我们开始学习构建一个分布式文件系统。由于必须在异构设备之间通过不同架构和能力的网络互联，我们遭遇了一系列巨大的挑战。在这个过程中， 我们重新审视整个网络技术栈，在不破坏兼容性或者创造新技术的前提下, 精心设计了跨越不同层次和协议的解决方案.

为了构建这个库，我们致力于独立跟踪不同的问题，创造一个尽量简单但功能强大的环境，以便能过顺利组装出一个点对点应用。

### 1.1 动机

**libp2p**是我们构建分布式系统的集体经验的结晶。通过应用**libp2p**, 开发者可以自主决定App如何与其他节点通过网络通信，并且可配置和可扩展，避免一开始就对网络作出假设。

事实上，一个使用了**libp2p**的节点有能力通过各种不同的传输方式和其他节点通信，包括**中继通讯**和**通过协商方式使用不同协议通信**。

### 1.2 目标

**libp2p**说明书及其不同实现的目标是:

- 支持各种不同的传输协议:
  - 非加密传输协议: TCP, UDP, [SCTP](../../核心技术/传输协议/SCTP.md), UDT, [uTP](../../核心技术/传输协议/uTP.md), QUIC, SSH, etc.
  - 加密传输协议: TLS, DTLS, CurveCP, SSH
- 能高效的使用socket链接(连接复用)
- 可以通过一个socket与不同的对端通信 (尽量避免握手开销)
- 通过协商过程，支持多个不同的协议以及协议的不同版本
- 后向兼容
- 能过在当前的系统中工作
- 能过使用当前网络技术的全部能力
- 支持NAT穿透
- 支持中继通讯
- 支持加密信道
- 高效使用底层传输（例如，本地流复用，本地认证等）

## 2 网络协议栈分析

本节整体介绍网络协议栈的可用协议和体系结构。目标是为理解**libp2p**为什么有如此的需求和体系结构提供必要的基础知识。

## 2.1 客户端-服务器 模式

**客户端-服务器** 模式指出，通道的两端是不同的角色，它们提供不同的服务和（或）不同的能力。换句话说，它们实现不同的协议。

构建一个**客户端-服务器**模式的应用由于以下原因是一个自然的选择:

- 数据中心的带宽远高于与之连接的客户端的带宽。
- 由于使用效率搞和批量采购，数据中心的资源一般都比客户端侧的资源便宜。
- 这个模式方便开发者或者系统管理员精细的管理整个应用。
- 它减少了需要处理的不同系统的数量 (虽然数量依旧十分巨大)。
- 类似NAT这样的系统使客户端之间的互相发现以及互相通信变得非常困难。导致开发者采用巧妙的手段穿越这样的障碍。
- 大量的协议在设计之初就假设会被应用在**客户端-服务器**模式的的应用中。

我们甚至学会了如何封装**所有的复杂性**以实现一个**隐藏在互联网网关之后的分布式系统**。应用无需理解具体协议栈，就能通过那些被设计为点对点操作的协议，例如**HTTP**，完成请求。

**libp2p**在**客户端-服务器**的**监听器**基础上更进一步，提供一种**拨号器-监听器**的交互模式，在这种模式下不需要明确指定哪个实体是**拨号者**或**者监听者**，有哪些能力或者能够执行或者能够执行哪些操作。在两个应用之间建立连接是一个需要在多个层次上解决的问题，这些连接在建立时不应带有某种特定的目的，进一步应该支持多个不同的协议在已经建立的连接上运行。在**客户端-服务器**模式中，服务器需要在没有客户端请求到达而需要发送数据，被称为**推送**模式，这经常会带来更多的复杂性；不同的是，在**拨号器-监听器**模式中，每一个实体都能没有依赖的发起请求。

## 2.2 根据解决方案对网络协议栈分类

在深入理解**libp2p**协议族之前，理解已经广泛使用和部署的多样化的协议是非常重要的。这些协议共同维护了当前对于网络的简单抽象。例如，当我们考虑一个HTTP连接时，我们可能天真的只考虑 HTTP/TCP/IP 这样一种主要的协议组合，但实际上有更多的协议参与其中，这取决于使用情况，涉及的网络等等。类似**DNS***, **DHCP**, **ARP**, **OSPF**, **Ethernet**, **802.11 (Wi-Fi)** 和很多其他协议都被组合在一起。研究以下ISPs自己的网络会发现数十个。

进一步说，传统的OSI七层网络模型并不适合**libp2p**。
相反，我们通过协议所扮演的角色对协议分类，例如，协议所解决的问题。

OSI模型的高层也是面向应用之间点对点连接的，但是**libp2p**协议针对更多的是通过不同的属性处理不同规模的网络和不同安全模型的网络。不同的**libp2p**协议可以承担相同的角色(在OSI模型中, 被成为"同一层地址)，意思是不同的协议可以类似的运行，都是相同的角色，使用相同的地址(这与传统ISO模型的每层每协议一个地址不同)。例如, **bootstrap lists**, *mDNS*, **DHT发现**, 和 **PEX** 都是"**对端发现**"这个角色的表现形式; 它们能够共存甚至协作。

### 2.2.1 建立物理连接

- Ethernet
- Wi-Fi
- Bluetooth
- USB

### 2.2.2 设备或者进程的寻址

- IPv4
- IPv6
- Hidden addressing, like SDP

### 2.2.3 发现其他的节点和服务

- ARP
- DHCP
- DNS
- Onion

### 2.2.4 通过网络转发消息

- RIP(1, 2)
- OSPF
- BGP
- PPP
- Tor
- I2P
- cjdns

### 2.2.5 传输层

- TCP
- UDP
- UDT
- QUIC
- WebRTC data channel

### 2.2.6 进程间通讯

- RMI
- Remoting
- RPC
- HTTP

## 2.3 目前缺陷

虽然我们目前有一整套协议可供我们的服务进行通信，但丰富多样的解决方案会带来新的固有问题。目前应用难以支持通过多种协议传输（比如浏览器环境中运行的应用无法通使用TCP/UDP协议栈)。也没有'持久化连接'的能力，也就是是没有一种能够使一个节点在多次传输的过程中表示自己的方法, 这样，其他节点无法保证连接的一直是同一个节点。

## 3 需求和考量
### 3.1 传输不可感知

**libp2p**是传输不可感知的，因而它可以运行在任何的传输协议上。它甚至不依赖于IP，可以运行在**NDN**, **XIA**, 以及其他新的互联网结构之上。

为了能够推断出可能的传输协议，**libp2p**使用**组合地址**，一种自解释的地址格式。这使得**libp2p**可以在系统的任何地方解析地址信息，并且能够在网络层支持大量的传送协议。**libp2p**实际上采用的地址格式是**ipfs地址**， 一种用IPFS节点id结尾的组合地址。例如, 这里有一些合法的**ipfs地址**:

- IPFS over TCP over IPv6 (typical TCP)
`/ip6/fe80::8823:6dff:fee7:f172/tcp/4001/ipfs/QmYJyUMAcXEw1b5bFfbBbzYu5wyyjLMRHXGUkCXpag74Fu`

- IPFS over uTP over UDP over IPv4 (UDP-shimmed transport)
`/ip4/162.246.145.218/udp/4001/utp/ipfs/QmYJyUMAcXEw1b5bFfbBbzYu5wyyjLMRHXGUkCXpag74Fu`

- IPFS over IPv6 (unreliable)
`/ip6/fe80::8823:6dff:fee7:f172/ipfs/QmYJyUMAcXEw1b5bFfbBbzYu5wyyjLMRHXGUkCXpag74Fu`

- IPFS over TCP over IPv4 over TCP over IPv4 (proxy)
`/ip4/162.246.145.218/tcp/7650/ip4/192.168.0.1/tcp/4001/ipfs/QmYJyUMAcXEw1b5bFfbBbzYu5wyyjLMRHXGUkCXpag74Fu`

- IPFS over Ethernet (no IP)
`/ether/ac:fd:ec:0b:7c:fe/ipfs/QmYJyUMAcXEw1b5bFfbBbzYu5wyyjLMRHXGUkCXpag74Fu`

注意: 当前, 没有不可靠传输的实现，协议中关于不可靠传输接口的定义和使用都没有定义。

TODO: 定义不可靠传输应该如何工作，基于WebRTC.

### 3.2 增强的多路复用 Multi-multiplexing

**libp2p**协议是一系列协议的集合。为了保留资源以及有更高的连通性，**libp2p**可以通过一个端口执行所有的操作，例如一个TCP或者UDP的端口，取决于具体使用了什么传输层。**libp2p**可以在单个点对点连接上多路复用不同的协议。这种复用既可以是可靠的流传输也可以是不可靠的数据分片传输。

**libp2p**是务实的。它设计为能够尽可能多的在不同组网中情况下使用的，模块化并可以灵活组装以适应不同的用况的，并且尽量减少额外的限制。 这种**libp2p**网络层提供的能力我们非正式的称为"**增强的多路复用 multi-multiplexing**":

- 可以多路复用不同的网络监听接口
- 可以多路复用不同的传输层协议
- 可以多路复用每一个对端一个的物理连接
- 可以多路复用不同的客户端协议
- 可以多路复用每用户每连接一个流传输通道
- 有流控能力(backpressure, fairness)
- 可以通过临时的key加密不同的连接

举个例子，设想一个单一的IPFS节点：

- 在一个公布的TCP/IP地址上监听
- 在一个不同的TCP/IP地址上监听
- 在一个SCTP/UDP/IP地址上监听
- 在一个UDT/UDP/IP地址上监听
- 有多个不同的连接到另一个节点X
- 有多个不同的连接到另一个节点Y
- 每一个连接上都不同的流传输
- 多个不同的流通过HTTP2连接到节点X
- 多个不同的流通过SSH连接到节点Y
- 一个承载在**libp2p**之上的协议为每一个对端节点使用一个流
- 一个承载在**libp2p**之上的协议为每一个对端节点使用多个流

如果不能提供这种级别的灵活性，**libp2p**就不能应用在不同的平台，用况和网络组网中。在所有的实现中支持所有的组合并不重要；重要的是规范有足够的灵活性，使不同的实现可以精确的实现它们需要的部分。这确保复杂用况的用户和应用可以将**libp2p**作为一个可选的方案。

### 3.3 加密

基于**libp2p**的通信可以是：

- 加密的
- 签名的 (不加密)
- 原生的 (不加密, 不签名)

我们认为安全和性能同等重要。我们注意到在一些数据中心内部通信的高性能场景中，加密是没有价值的。

我们的建议是:

- 实现应该默认加密所有通信
- 实现应该被审计
- 除非确实必要，用户一般都应该加密通信。

**libp2p**使用类似TLS这样的密码包

注意: 我们并没有直接使用TLS，因为我们不希望CA系统的额外依赖。很多TLS实现都是非常的巨大。由于**libp2p**加密模型从密钥开始，**libp2p**只需要接受ciphers。对于完整的TLS标准来说，这是很小的一个子集。

### 3.4 NAT穿透

**网络地址穿透**是Internet普遍存在的情况。不仅很多客户端设备隐藏在不同级别的NAT设备之后，而且很多的数据中心节点，由于安全和虚拟化的需求，同样隐藏在NAT设备之后。当我们采用了容器化部署以后，情况就变得更加糟糕了。**IPFS 实现** **应该** 提供一种穿透NAT的方法，否则操作可能会受影响。甚至运行在真实IP上的节点也都需要实现NAT穿透技术，因为这些节点也可能需要主动于在NAT设备之后的节点建立连接。

**libp2p**通过一个类似ICE的协议，完整实现了的NAT穿越。不采用真正的ICE协议，是由于**IPFS**网络提供基于IPFS协议自身的中继通讯能力，因而需要能够协助打甚至中继通讯。

建议实现使用一种NAT穿透库，例如**libnice**，**libwebrtc**或者**natty**。但是，NAT穿越必须能够互操作。

### 3.5 中继

不幸的是，由于对称NAT，容器和虚拟机NAT, 以及其他不可避免的NAT, **libp2p**必须能够回退到中继通讯的状态，以便于能建立一个全连接的图。 为了完整性，实现**必须**支持中继，虽然这种能力应该是**可选的**，也能够被最终用户关闭。

连接中继**应该**被实现为一种传输，以便于上层传输使用。

作为一种中继的例子，请参考[**libp2p电路中继规格**](IPFS-libp2p规格-中继.md)。

### 3.6 支持多种网络拓扑结构

不同的系统有不同的需求因而有不同的网络拓扑结构。
在P2P的文献中，我们发现的组网结构列举如下：**非结构化的**、**结构化的**、**混合的**和**集中的**。

**集中的**TOPO结构是在Web应用中最常见的，它需要给定的服务，或者一系列服务，始终存在在一个已知的静态位置，这样，其他的服务才能够访问它。**非结构化的网络**是**P2P网络**的一种，他的网络拓扑结构是完全随机的，或者至少是不确定的，而**结构化网络**有一种明确的方式进行组织。**混合网络**是这两者的组合。

考虑到这一点，**libp2p**必须准备好执行不同的路由机制和对端发现机制，以便构建路由表，使服务能够传播消息或查找对方。

### 3.7 资源发现

**libp2p**通过**记录 records**的方式，解决网络中资源发现的问题。一条记录是一条临时有效的数据单位，通过数字签名、加盖时间戳以及其他方法共同保证。记录中保存着网络上资源的描述信息片段，比如位置、可见性等。这些资源可以是数据，存储，CPU周期和其他类型的服务。

**libp2p** **不能**限制资源的位置，而是应该提供在网络中轻松找到或使用它们的方法，或者是一个辅助的通道。

### 3.8 消息传递

高效的消息传递协议提供以最小延迟在大型复杂拓扑中分发内容的方法。

**libp2p**通过合并**广播**和**发布-定于**这两种模式，实现高效的消息传递的需求。

### 3.9 命名

网络经常在变化，因而应用需要有一种无需考虑网络的拓扑结构就能够使用网络的方案。命名似乎是可以解决这个问题的。

## 4 架构

**libp2p**遵守**UNIX设计哲学**，创建小的组件以方便理解和测试。这些组件也应该能够替换以适应不同的技术或场景，并且还可以随着时间的推移升级它们。

虽然，不同的节点可以根据它们不同的能力支持不同的协议，但是任何一个节点都应该可以作为其他节点的**拨号器**或者**监听器**，建立好的连接能够被任何一个端点复用，连接不应该被理解为有方向。

**libp2p**接口是点对点通讯所必须的多个子系统之间的薄薄的封装层。只要遵守标准化接口，这些子系统就可以建立在其他子系统之上。 这些子系统适合的主要领域是：

- **节点路由** - 决定使用哪个节点（或者一系列节点）来传递一个特定的消息的机制。这种路由可以通过递归、迭代、甚至广播/多播的方式完成。

- **集群** - 处理**libp2p**中所有涉及“打开流”这样的任务，包括**协议复用**，**流复用**，NAT穿透，连接中继，以及多传输通道。

- **分布式记录存储** - 存储和分发记录的系统。记录是指小的条目，被其他系统用于签名，建立连接，通告节点或者内容等等。它扮演了类似DNS广域网上的角色。

- **节点发现** - 查找或识别网络中的其他节点。

每一个子系统都公开了一个众所周知的接口（见第6章接口），并可能会相互调用以实现其目标。 系统的全局结构如下：

```txt
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  libp2p                                         │
└─────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────┐┌─────────────────┐┌──────────────────────────┐┌───────────────┐
│     节点路由     ││       集群       ││       分布式记录存储       ││    节点发现    │
└─────────────────┘└─────────────────┘└──────────────────────────┘└───────────────┘
```

### 4.1 节点路由

```txt
┌──────────────────────────────────────────────────────────────┐
│       节点路由                                                │
│                                                              │
│┌──────────────┐┌────────────────┐┌──────────────────────────┐│
││   kad路由    ││    mDNS-路由    ││        其他路由机制       ││
││              ││                ││                          ││
││              ││                ││                          ││
│└──────────────┘└────────────────┘└──────────────────────────┘│
└──────────────────────────────────────────────────────────────┘
```

#### 4.1.1 kad路由

**kad路由**实现Kademlia路由表，每个节点拥有一组k-bucket，每个k-bucket都包含来自网络中其他节点的几个PeerInfo对象。

#### 4.1.2 mDNS路由

**mDNS路由**使用mDNS探测来识别局域网是否存在节点，以及节点是否拥有指定的密钥。

### 4.2 集群

#### 4.2.1 流复用器

流复用器必须实现interface-stream-muxer提供的接口。

#### 4.2.2 协议复用器

协议复用是在应用层面上处理的，而不是传统的在端口级别处理的方式（不同服务/协议在不同端口监听）。这是我们能够在同一个`套接字`上支持不同的协议, 从而避免NAT穿透一个以上的端口。

协议多路复用是通过**多数据流**完成的，该协议使用**多编解码器**协商承载不同类型的数据流（协议）。

#### 4.2.3 传输

#### 4.2.4 加密

#### 4.2.5 标识

**标识**是构建在集群（连接处理器）之上的一种协议。它和其他构建在集群之上的协议一样，遵循和遵守相同的模式。**标识**使我们能够在各个节点之间交换`监听地址`和`观察地址`，这对IPFS来说是至关重要的。
由于每个打开的`套接字`都实现了`REUSEPORT`，因此另一个节点的`观察地址`可以使第三个节点体连接到我们，因为这个端口已经打开并且在NAT上重定向到我们。

#### 4.2.6 中继通讯

参考[电路中继规格](IPFS-libp2p规格-中继.md)

### 4.3 分布式记录存储
#### 4.3.1 Record

服从[IPRS记录系统规格](IPFS-libp2p规格-记录.md)

### 4.4 节点发现

#### 4.4.1 mDNS节点发现

**mDNS发现**是一种运行在局域网上，使用`mDNS协议`的发现协议。它发射`mDNS信号`以发现附近是否有更多的节点可见。本地局域网的节点对于`P2P协议`来说是非常有用的，因为它们之间有低延时的链接。

`mDNS发现`是一个独立的协议，它并不依赖于任何其他的`libp2p协议`。`mDNS发现`可以发现局域网中的可见节点而无需其他任何设施的帮助。这在`Intranet`、`和Internet骨干网断开的网络`、以及`临时丢失链接的网络`中都特别有用。

`mDNS发现`可以配置为为某一个服务执行（例如. 发现那些只参与某一个特定协议的节点，比如IPFS), 以及在某一个私有的网络(发现数据一个私有网络的节点)。

我们正在探索一种把`mDNS发现信号`加密的方法，（这样本地网络中的其他节点就不能辨识正在使用的协议），尽管mDNS的本质是始终显示本地IP地址的。

**隐私注意事项**：mDNS协议在局域网网中发布公告，将自己的本地IP暴露给本地网络中的监听者。对于关注隐私的应用或者被动的路由协议不建议采用本协议。

#### 4.4.2 随机搜索

**随机搜索 Random-Walk**是构建在`DHTs`(或者其他的路由表协议）基础上的一种发现协议。它使用随机的`DHT查询`以快速的了解到大量的节点。这导致`DHT`(或者其他协议)能够快速的完成，代价就是每次启动的时候有一定的负载。

#### 4.4.3 启动列表

**启动列表 Bootstrap-List**是一种通过预先缓存在本地的地址列表发现节点的协议。通常缓存的是具有高可用性的和信任的节点。这允许协议“查找网络的其余部分”。

本质上，这与DNS自身引导的方式相同（但请注意，修改DNS的“域名地址”系统，设计一个改动过的**启动列表**并不容易）。

列表应该被存储在长期有效的本地介质上，基本上这就以为着存储在当前节点上（例如磁盘）。协议可以提供一个硬编码的默认列表或者标准的方式分发（例如DNS）。大多数情况下（当然也包括在IPFS中），这个**启动列表**应该允许用户配置，因为用户可能希望构建一个独立的网络，或者选择信任某些特定的节点。

### 4.5 消息传递

#### 4.5.1 发布-订阅

### 4.6 命名
### 4.6.1 IPRS
### 4.6.1 IPNS

## 5 数据结构

网络协议处理一下的数据结构：

- a PrivateKey, the private key of a node.
- a PublicKey, the public key of a node.
- a PeerId, a hash of a node's public key.
- a PeerInfo, an object containing a node's PeerId and its known multiaddrs.
- a Transport, a transport used to establish connections to other peers. See <https://github.com/diasdavid/interface-transport>.
- a Connection, a point-to-point link between two nodes. Must implement <https://github.com/diasdavid/interface-connection>.
- a Muxed-Stream, a duplex message channel.
- a Stream-Muxer, a stream multiplexer. Must implement <https://github.com/diasdavid/interface-stream-muxer>.
- a Record, IPLD (IPFS Linked Data) described object that implements IPRS.
- a multiaddr, a self describable network address. See <https://github.com/jbenet/multiaddr>.
- a multicodec, a self describable encoding type. See <https://github.com/jbenet/multicodec>.
- a multihash, a self describable hash. See <https://github.com/jbenet/multihash>.

## 6 接口

**libp2p**是一系列协议的集合，它们共同提供了一套稳定的，能互相合作的接口。通过这套接口，可以通过网络和其他任何可以命名的节点通讯。这是我们可以将一系列现存的协议以及实现重新桥接到一组明确的接口中去：节点路由、发现、流复用、传输、连接等等。

### 6.1 libp2p

**libp2p**是向其他模块提供建立**libp2p实例**的最上层接口，必须提供一个拨号到其他节点的接口以及组装其他我们希望支持的协议的接口（例如，使用什么传输协议）。We present the libp2p interface and UX in section 6.6, after presenting every other module interface.

### 6.2 节点路由

A Peer Routing module offers a way for a libp2p Node to find the PeerInfo of another Node, so that it can dial that node. In its most pure form, a Peer Routing module should have an interface that takes a 'key', and returns a set of PeerInfos. See https://github.com/diasdavid/interface-peer-routing for the interface and tests.

### 6.3 集群

<https://github.com/diasdavid/js-libp2p-swarm#usage>

#### 6.3.1 传输

<https://github.com/diasdavid/interface-transport>

#### 6.3.2 连接

https://github.com/diasdavid/interface-connection

#### 6.3.3 流复用

https://github.com/diasdavid/interface-stream-muxer

### 6.4 分布式记录存储

<https://github.com/diasdavid/interface-record-store>

### 6.5 节点发现

节点发现模块应该返回`PearInfo对象`，因为它发现的节点可以提供给我们的`节点路由`模块最为新的可选节点。

### 6.6 libp2p接口和用况

**libp2p**实现需要提供通过编码实例化的能力，或者通过一个预先编译好，并且包含了一系列协议决策的库，这样用户能够重用或者扩展。

**通过代码构造一个libp2p实例**

例子是使用javascript实现的，也可以通过其他语言来实现：

```js
var Libp2p = require('libp2p')

var node = new Libp2p()

// 增加一个集群实例
node.addSwarm(swarmInstance)

// 增加一个或者多个节点路由机制
node.addPeerRouting(peerRoutingInstance)

// 增加一个分布式数据存储
node.addDistributedRecordStore(distributedRecordStoreInstance)
```

配置**libp2p**是非常直接的，这是由于大量的配置是在不同模块实例化的时候设置的，一次一个模块。

**拨号到一个节点以及监听请求连接的节点**

理想情况下，**libp2p**使用自己的机制（节点路由，记录存储）来寻找到达给定节点的路径。

```js
node.dial(PeerInfo)
```

To receive an incoming connection, specify one or more protocols to handle:

```js
node.handleProtocol('<multicodec>', function (duplexStream) {

})
```

**寻找一个节点**

寻找节点是通过**节点路由**来实现的，因此接口是相同的。

**存储和读取记录**

和寻找一个节点类似，存储和读取记录是通过**节点存储**接口完成的，因此接口是相同的。

## 7 属性

### 7.1 通讯模型 - 流模型

所有的连接到对端的问题都交给网络层来解决，并且对外暴露一个简单的，没有方向的流接口。用户既可以创建一个新的流(NewStream)也可以在一个现有的流上注册处理器(SetStreamHandler)。这样用户就可以自由的实现任何需要的基于连接和消息的协议。这也使得实现一个点对点的协议变得非常容易，因为像**连通性**，**支持多种传输协议**，**流控**这样的难点都已经被解决了。

为了帮助理解这个模型，请考虑如下的情况：

- NewStream就向一个HTTP客户端构造一个请求。
- SetStreamHandler就类似于在HTTP服务器注册一个URL处理器。

因此，一个类似DHT这样的协议，看起来如下：

```go
node := p2p.NewNode(peerid)

// 注册一个执行函数，这里假设就是简单的拷贝回去任何接收到的数据。
node.SetStreamHandler("/helloworld", func (s Stream) {
  io.Copy(s, s)
})

// 构造一个请求
buf1 := []byte("Hello World!")
buf2 := make([]byte, len(buf1))

stream, _ := node.NewStream("/helloworld", peerid) // 创建一个新的流
stream.Write(buf1)  // 发送到远端
stream.Read(buf2)   // 读取接收到的信息
fmt.Println(buf2)   // 打印接收到的信息
```

### 7.2 端口 - Constrained Entrypoints

在2015年的Internet中，我们有一种处理模型，在这个模型里，程序可能不能打开多个网络端口，甚至可能连一个网络端口都不能打开。
很多的主机隐藏在NAT设备之后，无论是家庭的ISP的不同类型，还是新出现的容器化的数据中。还有一些程序可能运行在浏览器中，没有办法直接打开socket。这给需要能够连接到任意节点的完全P2P网络带来了巨大的挑战，无论是运行在一个在浏览器中打开的网页还是运行在一个容器中的容器。

**IPFS**只需要一个通道就能和网络的其他部分通讯，可以是一个TCP或者UDP的端口，也可以是一个WebSockets或者WebRTC的连接。在某些场景中，TCP/UDP协议所扮演的角色（例如基于应用和连接的多路复用）已经被迫在应用层解决了。

### 7.3 传输协议

**IPFS**是传输协议不可感知的。它可以运行在任何传输协议之上。`ipfs-addr`地址格式（就是IPFS规格说明中所描述的`multiaddr`) 描述了使用的传输协议。例如：

```bash
# ipv4 + tcp
/ip4/10.1.10.10/tcp/29087/ipfs/QmVcSqVEsvm5RR9mBLjwpb2XjFVn5bPdPL69mL8PH45pPC

# ipv6 + tcp
/ip6/2601:9:4f82:5fff:aefd:ecff:fe0b:7cfe/tcp/1031/ipfs/QmRzjtZsTqL1bMdoJDwsC6ZnDX1PW1vTiav1xewHYAPJNT

# ipv4 + udp + udt
/ip4/104.131.131.82/udp/4001/udt/ipfs/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ

# ipv4 + udp + utp
/ip4/104.131.67.168/udp/1038/utp/ipfs/QmU184wLPg7afQjBjwUUFkeJ98Fp81GhHGurWvMqwvWEQN
```

**IPFS**将传输层拨号委托给一个基于`复合地址`的网络包，例如`go-multiaddr-net`.建议在其他语言中也建立类似的模块，并且限定好实现的传送层协议。

我们将使用的传输层协议：

- UTP
- UDT
- SCTP
- WebRTC (SCTP, etc)
- WebSockets
- TCP Remy

### 7.4 非IP网络

像**NDN**和**XIA**这样的成果是为广域网研究的新架构，它们的体系，相比于目前基于IP的网络架构，更加接近于**IPFS**所提供的网络抽象。**IPFS协议**可以天然的可以在这些网络架构上运行，因为在ipfs协议栈上，没有对物理网络协议栈做任何的假设。实现是有可能需要改变的，但是改变实现比改变协议要容易很多。

### 7.5 运行于单一连接之上

为了使IPFS网络能够在任何双向流（一个输入一个输出成对的任何连接）之上，任意的平台之上顺利运行，我们有很强的限制。

为了完成以上的目标，IPFS必须解决一下几个问题：

- 协议复用 - 在同一个流上运行不同的协议
    - `multistream` - 自解释所使用协议的流
    - `multistream-selector` - 一个`multistream`协议选择器
    - 流多路复用 - 在同一个底层连接中，运行多个无不相干的流
- 可替换的编解码 - 使用可替换的序列化格式
- 安全的通讯 - 使用密码组来构建安全、隐私的连接（类似TLS）

#### 7.5.1 复合流协议

复合流协议的意思是在同一个流上运行多个不同的协议。这可能是顺序发生的（一个协议接着一个协议)，也可能是同时的（在同一时间，交叉到达）。我们归纳复合流协议为下面三种情况：

- `multistream` - 自解释所使用协议的流
- `multistream-selector` - 一个`multistream`的选择器
- 流多路复用 - 在同一个底层连接中，运行多个互不相干的流

#### 7.5.2 `multistream` - 自描述的协议流

`multistream`是一种自描述的协议流格式。它非常的简单。其目标是定义一种在协议头部增加对协议本身的描述的方法。这有点像给协议增加版本信息，但它更加具体（指定了协议）。

例如：

```txt
/ipfs/QmVXZiejj3sXEmxuQxF2RjmFbEiE9w7T82xDn3uYNuhbFb/ipfs-dht/0.2.3
<dht-message>
<dht-message>
...
```

#### 7.5.3 `multistream-selector` - 自描述协议的分发系统

`multistream-select`这是一个简单的`multistream`协议，允许查询和指定其他协议。这意味着，协议复用有一个注册的协议列表，每个协议一个监听器，然后通过新增嵌套的连接（或者升级）和注册的协议进行通讯。这个协议带来最直接的好处就是： 在提供了查询对端支持的协议列表的同时，支持交错使用不同的协议。

例如：

```txt
/ipfs/QmdRKVhvzyATs3L6dosSb6w8hKuqfZK2SyPVqcYJ5VLYa2/multistream-select/0.3.0
/ipfs/QmVXZiejj3sXEmxuQxF2RjmFbEiE9w7T82xDn3uYNuhbFb/ipfs-dht/0.2.3
<dht-message>
<dht-message>
...
```

#### 7.5.4 流多路复用

流复用是将多个不同流复用（或合并）为一个流的过程。这是一个复杂的主题，通过这个协议，可以支持不多个协议的流同时运行在一个线路上，并且提供类似公平、流控、基于头部信息的阻塞等概念。开始我感受这个协议。实践上，流多路复用是很好理解的，而且现在已经有很多支持流多路复用的协议了，这里列举几个：

- HTTP/2
- SPDY
- QUIC
- SSH

**IPFS节点**可以在默认的多路复用协议之上，自由选择任何它们希望的流复用协议。系统至少有一个默认的多路复用的协议，这使得即使是最简单的节点都可以同时支持多套不同的协议。默认的多路复用协议可以是HTTP/2（或者可以是QUIC？），但是实现很少去实现这样的协议，因此，我们从一个最简单的**SPDY**开始。我们非常简单的通过一个`multistream`的头部来指定用什么具体的协议。

例如：

```txt
/ipfs/QmdRKVhvzyATs3L6dosSb6w8hKuqfZK2SyPVqcYJ5VLYa2/multistream-select/0.3.0
/ipfs/Qmb4d8ZLuqnnVptqTxwqt3aFqgPYruAbfeksvRV1Ds8Gri/spdy/3
<spdy-header-opening-a-stream-0>
/ipfs/QmVXZiejj3sXEmxuQxF2RjmFbEiE9w7T82xDn3uYNuhbFb/ipfs-dht/0.2.3
<dht-message>
<dht-message>
<spdy-header-opening-a-stream-1>
/ipfs/QmVXZiejj3sXEmxuQxF2RjmFbEiE9w7T82xDn3uYNuhbFb/ipfs-bitswap/0.3.0
<bitswap-message>
<bitswap-message>
<spdy-header-selecting-stream-0>
<dht-message>
<dht-message>
<dht-message>
<dht-message>
<spdy-header-selecting-stream-1>
<bitswap-message>
<bitswap-message>
<bitswap-message>
<bitswap-message>
...
```

#### 7.5.5 可替换的编解码系统

为了能够在任何地方使用，我们必须使用一种超级可移植的编码格式，这样才能非常容易的在不同的平台上使用。理想情况下，采用的编解码技术最好在其他项目这仔细测试，并且被广泛使用了。
有可能存在一些情况，需要要支持多种编码（因此，可能还需要多编解码器自描述），但迄今为止并不需要这种编码。目前，我们对所有的协议都使用protobuf编码，但是其他还有一些好的选择，比如capnp，bson，和ubjson。

#### 7.5.6 加密通讯

在连接层运行的协议当然是加密的。我们通过类似TLS那样的cyphersuites进行加密，这在很多网络协议中都有描述。

#### 7.5.7 Protocol Multicodecs

这里有一份列表用于描述各个在连接协议之上的IPFS协议所使用的多协议复用描述。随着时间，这份协议可能会改变，所以只能作为参考使用。


|   协议   | multicodec | 注释 |
| -------- | ---------- | ------- |
| secio    | /secio/1.0.0 |   |
| TLS      | /tls/1.3.0   | not implemented |
| plaintext | /plaintext/1.0.0 | |
| spdy     | /spdy/3.1.0 | |
| yamux    | /yamux/1.0.0 | |
| multiplex | /mplex/6.7.0 | |
| identify | /ipfs/id/1.0.0 | |
| ping     | /ipfs/ping/1.0.0 | |
| circuit-relay | /libp2p/relay/circuit/0.1.0 | spec |
| diagnostics | /ipfs/diag/net/1.0.0 | |
| Kademlia DHT | /ipfs/kad/1.0.0 | |
| bitswap | /ipfs/bitswap/1.0.0 | |

## 8 实现

一个**libp2p**的实现应该 (建议) follow a certain level of granulatiry when implementing different modules and functionalities, so that common interfaces are easy to expose, 测试和检查与其他不同实现的**互操作性**

以下是**libp2p**当前可用的模块列表

- libp2p (入口点)
- 集群
  - libp2p-swarm
  - libp2p-identify
  - libp2p-ping
  - 传输
      - interface-transport
      - interface-connection
      - libp2p-tcp
      - libp2p-udp
      - libp2p-udt
      - libp2p-utp
      - libp2p-webrtc
      - libp2p-cjdns
  - 流复用器
      - interface-stream-muxer
      - libp2p-spdy
      - libp2p-multiplex
  - 加密通道
      - libp2p-tls
      - libp2p-secio
- 节点路由
  - libp2p-kad-routing
  - libp2p-mDNS-routing
- 发现服务
  - libp2p-mdns-discovery
  - libp2p-random-walk
  - libp2p-railing
- 分布式记录存储
  - libp2p-record
  - interface-record-store
  - libp2p-distributed-record-store
  - libp2p-kad-record-store
- 通用
  - PeerInfo
  - PeerId
  - multihash
  - multiaddr
  - multistream
  - multicodec
  - ipld
  - repo

## 9 参考

- State of Peer-to-Peer (P2P) Communication across Network Address Translators (NATs): <https://tools.ietf.org/html/rfc5128>

