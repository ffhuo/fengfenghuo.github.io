# Hyperledger Fabric 架构概述

Hyperledger Fabric架构提供以下优点：

- **灵活的chaincode信任**。该体系，将chaincode的信任假设(blockchain应用程序)，同ordering的信任假设分离开来。 
换句话说，ordering服务有一系列的节点(orderers)提供，并且能够容忍一定节点的错误和不工作，并且对于不同的chaincode 
可以有不同的orderers。

- **可扩展性**。负责某个chaincode的endores节点同orderer节点相互正交，这样的系统比endorse和order是同一个节点更加 
灵活。尤其是，在不同的chaincode分离不同的当不同的链码指定不相交的endorsers时，会在不同的endorser之间引入chaincode 
的划分，并且允许并行的chaincode执行(endorsement)。除此之外，将chaincode的执行从ordering服务的关键路径中删除成本 
可能会更高。

- **保密性**。该架构便于部署具有关于其交易的内容和状态更新的机密性要求的链码。

- **共识模块化**。该架构是模块化的，允许可插拔的共识（即ordering服务)。

## 系统架构
区块链是由许多相互通信的节点组成的分布式系统。区块链运行的程序叫做chaincode，区块链负责保存状态和账本数据以及执行交易。chaincode是核心元素因为交易是在chaincode上调用的操作。交易必须被”**endorse**”，只有被背书过的交易才能够被提交并且对状态产生影响。可能存在用于管理功能和参数的一个或多个特殊chaincode，统称为系统chaincode。

### 交易
交易可以有两种类型：

- 部署交易创建一个新的chaincode，并且将程序作为参数。当一个部署交易成功的执行，chaincode就被部署到了区块链上。

- invoke交易先前部署的chaincode的上下文中执行操作。一个invoke交易，涉及一个chaincode以及之前它所提供的函数。 
当其成功时，chaincode会执行一个被指定的函数，这可能会涉及到修改相应的状态并返回一个输出。
其中，部署交易是invoke交易的一种特殊情况，部署交易是一种调用系统chaincode来创建新的chaincode的invoke交易。

**注意** 
这篇文档假设创建一个交易，或者调用一个已经部署在区块链上的chaincode提供的操作。本文档并没有提及： 
- query(只读)交易的最优化(v1中已经包含) 
- 跨链交易(post-v1特性)

### 区块链的数据结构
#### 状态

区块链的最新状态被模块化为版本化键/值存储（KVS），其中键是名称，值是任意的blob。这些实体被运行在区块链上的chaincode(or app)通过 put 和 get 键进行操作。状态被持久存储， 
并且状态的更新被记录。注意，状态模型采用版本化KVS，实现可能使用实际的KVS，也可以使用RDBMS或其他解决方案。 
状态 s 被模型化为，映射 K -> (V X N) 中的一个元素。 
其中： 
- K 是一组键。 
- V 是一组值。 
- N 是一个无限有序的版本号，内设函数 next: N -> N 
输入一个 N 的元素，返回下一个元素的版本号。 V 和 N 都包含一个特殊的元素 \bot ，他是假设 N 的最小元素。最初所有的键被映射到 (\bot,\bot) 。对于 s(k)=(v,ver) ，我们用 s(k).value 表示 v ，用 s(k).version 表示 v 。

KVS操作模型如下：
- put(k,v) ，其中 k\in K 和 v\in V ， 
获取区块链的状态 s ，并将其变为状态 s’ 。例如： s’(k)=(v,next(s(k).version)) ，对于所有的 k’!=k. ，都有 s’(k’)=s(k’) 。
- get(k) 返回 s(k) 。

状态被peer节点保存而不是orderer节点和client

**状态分区**。可以从名字中识别出KVS的键属于哪个chaincode，因此，只有属于特定chaincode的交易才可以修改该chaincode的键。原则上，任意chaincode都可以读取其他chaincode上的键。支持修改属于两个及以上的chaincode的状态的跨链交易是post-v1的一个特性。

#### 分布式账本

分布式账本提供了所有成功的状态改变(called valid transaction)，和没有成功的试图改变状态(called invalid transaction)的操作 
的可验证的历史记录。

分类帐由ordering服务器构建，其是一个排序区块组成的的hash链，每个区块中包含了invalid／valid交易。这条hash负责将账本中所有的区块全局排序，同时，每个区块包含一个整体被排序的交易的数组。

分布式账本被保存在所有的peer节点中，同时可以选择保存在一些orderer节点中。在orderer节点的上下文中，我们提及账本时为 **OrdererLedger** ，在peer节点的上下文中，我们提及账本时为 PeerLedger 。为了区分valid／invalid交易，那些本地中保存位掩码(bitmast)的peer节点中的 **PeerLedger** 和 **OrdererLedger** 不同。

Peer节点可能会精简 **PeerLedger** (post-v1 特性)。Orderer节点保存了 **OrdererLedger** ，它是为了保证（ PeerLedger )容错性和可用性，并且只要提供ordering 服务的属性得到保留，可以随时决定精简它。

账本允许peer节点重放交易历史并且修改状态，因此，1.2.1中说的状态是一种可选的数据结构。

### 节点
节点是区块链中相互通信的实体，一个节点只是逻辑上的节点，因此，一台物理主机上可以运行多个节点。重要的是节点如何在信任域中被分组，以及如何同控制他们的逻辑实体相关联。

有三种节点： 
1. **Client**，一个客户端向endorsers提交一个真实的交易请求(transaction-invocation)， 
同时向orderering服务器广播交易建议(transaction-invocation)。 
2. **Peer**，一个提交交易，保存状态，保存账本副本的节点。此外，peer节点还可以有一个特殊的endorser角色。 
3. **Orderer**，提供一个交流服务，保证传输，例如原子操作和全局排序广播。

#### Client
client代表最终用户的实体。为了同区块链交互，它必须同一个peer节点连接。client可以选择同任意一个节点连接。 
client创建并且调用交易。

client节点和peer节点以及ordering 服务器通信。

#### Peer
peer节点以区块的形式接收来自ordering 服务器的有序状态更新，同时保存状态和账本。此外peer节点还可以扮演endorse节点的角色，可以称为endorser。一个endorsing节点的特殊函数在同一些特殊chaincode有关时执行，这个函数的作用在于，提交一个交易之前对其进行endorsement。每个chaincode都可以在一组endorsing节点上指定一个endorsement策略。Endorsement策略为一个valid交易定义了一个充要条件。通常是一组endorsers的签名。在安装新的chaincode的部署交易的特殊情况下，（部署）endorsement策略是为指定的系统chaincode的endorsement策略。

#### Ordering service nodes (Orderers)
Orderers组成了ordering服务器，例如， 一个提供传输保证的通信架构。Ordering服务器可以用不同的方式执行：可以是一个中心化的服务(多用来开发和测试)，也可以针对不同网络和节点故障模型的分布式协议。

Ordering服务器为client和peer提供了一个共享的通信channel，为包含交易的消息提供了广播服务。Clients连接到channel然后可以在channel上广播消息，然后这个消息会被传输到所有peer节点上。Channel支持所有信息的原子化传输，即消息通信具有全局排序传输和可靠性。换句话说，channel向所有的连接的节点输出相同的消息，并且这些消息具有相同的顺序。这种原子通信保证也被称为全局排序广播/原子广播/分布式系统的一致性。通信消息是区块链状态的后补交易。

分区(ordering 服务器channel)。Ordering 服务器可以在发布/订阅（pub / sub）系统的一个主题中支持多个单一的channel。Client可以连接到一个给定的channel，并能够发送和接受消息。Channel可以被想象成分区–连接到一个channel上的client并不知道其他channel的存在，但是一个client可以连接到多个channel上。尽管一些ordering服务器的实现包括了对多个channel的支持，但为了简单起见，在接下来的文档中只考虑ordering服务器只包含一个channel/topic。

**Ordering 服务器 API。**Peer节点经由ordering服务器提供的接口连接到有ordering服务器提供的channel上。Ordering服务器的API有两个基本的操作组成(通常是异步的)。

在client/peer指定的序列号下获取指定的块的API:
- **broadcast(blob)** client调用这个函数通过channel来广播任意一个消息 blob 。在BFT上下文中当向服务器发送一个请求时，它也被称为 request(blob) 。
- **deliver(seqno, prevhash, blob)** ：Ordering服务器在peer上调用此函数，用来传递消息 blob ，消息中携带着具有指定的非负整数序列号 seqno 和最近传输的blob的hash prehash 。换句话说，它就是一个从ordering服务器的输出事件。 deliver() 有时也会在pub-sub系统中调用 notify() 和在BFT系统中调用 commit() 函数。

**账本和块的构成**。账本(Sec.1.2.2)包含所有的ordering服务器输出的数据。简而言之，它是一系列 deliver(seqno, prevhash, blob) 事件的序列，他们根据 prehash 组成了一条hash链。

大多数时间，出于效率考虑，ordering服务器将blobs打包并使用一个简单的 deliver 事件输出区块，而不是单个输出交易(blobs)。在这种情况下，ordering服务器必须在每个区块内引入并且传递一个blobs的确定排序。Blobs的数目可以由ordering服务器动态的选择。

在下文中，为了便于介绍，我们定义了ordering服务器的属性，并且解释了在每个 deliver 事件一个blob的情况下，交易endorsement的工作流程。这些容易扩展到区块，根据上述块内blobs的确定性排序，假设一个 区块的 deliver 事件，同区块中的每个blob对应的各自的一系列独立的 deliver 相一致。

**Ordering 服务属性**
保证ordering服务(或原子广播channel)规定如何操作一个广播消息和传递的消息之间的关系。这些保证如下： 

1. 安全性(一致性保证):只要peer连接到channel中足够长时间(他们可能会断开连接，也会重新启动并且重新连接)，他们将会看到一系列相同的被传递的消息 (seqno, prevhash, blob) 。这意味着输出（ deliver（） 事件）在所有对等体上以相同的顺序发生， 并且根据序列号携带相同的内容（ blob 和 prevhash ）。需要注意，这只是一个逻辑排序，并且在一个peer上的 deliver(seqno,prevhash,blob) 不需要与另一在其他对等体上输出相同消息的 deliver(seqno,prevhash,blob) 有任何实时关系。换句话说，给定一个特定的 seqno ，没有两个正确的提供不同的 prevhash 或 blob 值。此外，除非一些client(peer)调用了 broadcast(blob) ,并且每个广播的 blob 只被调用一次，否则不传输 blob 的值。

  此外， deliver() ,包含了前一个 deliver() 事件中的数据的加密hash值( prehash )。当ordering服务器实现原子广播保证时， prevhash 是来自具有序列号 seqno-1 的 deliver() 事件的参数的hash值。这建立了一个 deliver() 的hash链，用于帮助验证ordering服务输出的完整性，稍后在第4节和第5节中讨论。在第一个 deliver() 事件的特殊情况下 ， prevhash 具有默认值。


2. 活性(传输保证)：Ordering服务的活性保证是由一个ordering服务器指定的。确切的保证取决于网络和几点故障类型。

  原则上，如果提交client没有失败，ordering服务应该保证每个连接到ordering服务器正确的peer节点最终能够传递每个提交交易。

总的来说，ordering服务保证如下属性： 
- 一致性：对于正确的peer节点间的任意两个事件 deliver(seqno,prevhash0,blob0) 和 deliver(seqno,prevhash1,blob1) 具有相同的 seqno 时，有 prevhash0==prevhash1 
blob0==blob1 
- hash链完整性：对于正确的peer节点间的任意两个事件 deliver(seqno,prevhash0,blob0) 和 deliver(seqno,prevhash1,blob1) ， prevhash=HASH(seqno-1||prevhash0||blob0) 。 
- 没有跳过：如果一个ordering服务器在一个正确的peer节点p上输出 deliver(seqno,prevhash,blob) ，如果 seqno>0 ，则p已经传输了一个事件 deliver(seqno-1,prevhash,blob) 。 
- 没有创建：任何在正确peer节点上的 deliver(seqno,prevhash,blob) 事件，必须以在一些(可能不同的)peer上的 broadcast(blob) 
- 没有重复：对于任意两个事件 broadcast(blob) 和 broadcast(blob’) ，当两个事件 
deliver(seqno,prevhash0,blob) 和 
deliver(seqno,prevhash1,blob’) 发生在正确的peer节点上并且 
blob==blob’ ，则 seqno0==seqno1 prevhash0==prevhash1 。 
- 活性：如果一个正确的client invoke一个 broadcast(blob) 事件，那么每一个正确的peer最终会发出一个 deliver(,,blob) ， * 表示任意值。

## Endorsement交易的基本工作流程
在下面我们概述一个事务的高级请求流。 
**备注**： 请注意，以下协议*不假定所有事务都是确定性的，即它允许非确定性事务。

### Client创建一个交易并且将他发送到它选择的endorsing节点
为了invoke一个交易，client向它选择的一组endorsing节点发送一个 PROPOSE 消息。一组给定 chaincodeID 的endorser通过peer提供给客户端，而这些peer又从认可endorsement（见第3节）知道一组endorser，这些peer可以从endorsement策略获得这组endorsing节点。例如，交易可以发送给所有被分配给定 chaincodeID 的endorsing节点。也就是说，一些endorsers可能离线，一些endorsers可能反对和选择不支持交易。提交client尝试使用可用的endorsers来满足策略。在下面，我们首先详细介绍 PROPOSE 消息的格式，然后讨论提交client和endorers之间通信的可能模式。

#### PROPOSE 消息格式
PROPOSE 的消息格式是

#### 消息样式
client决定与endorser交互的顺序。例如，client通常发送

### 提交client为交易收集endorsement并通过ordering服务器将其广播出去
提交状态一直保持等待状态，直到它接收到了”足够“的消息和 (TRANSACTION-ENDORSED, tid, , ) 状态上的签名以判断这个交易是否被endorse。这可能包含了一轮或者多轮的endorser之间的交互。

对于”足够“的具体定义取决于chaincode的endorsement策略。如果endorsement策略被满足，这个交易就已经被endorse，需要注意，这个时候这个交易还没被提交。来自组成一个已经被endorse的交易endorsing节点的被签名的集合称作endorsement和 endorsement 的一个表示。

如果提交client无法尝试为 一个交易proposal搜集一个endorsement，它将会拒绝这个交易并且之后尝试。

对于被endorse的交易，我们开始使用ordering服务。提交client使用 broadcast(blob) ,其中 blob=endorsement 。 
如果client没有足够的能力直接调用ordering服务，它将会通过它选择的一些peer来代理它的广播。Peer必须被这个client信任，它不能从 endorsement 中移走任何信息，否则这个交易会被视为无效。注意，代理peer不能伪造一个有效的 endorsement 。

### Ordering服务器向peer节点传输交易
当一个 deliver(seqno,prehash,blob) 事件出现，并且一个peer已经用低于 seqno 序列号提供了blobs的说有的状态更新信息，一个peer会做如下操作： 
- 它根据chaincode( blob.tran-proposal.chaincodeID )的策略检查 blob.endorsement 是否有效。 

- 在一般情况下，他还验证了依赖性( blob.endorsement.tran-proposal.readset )是否被违反，在更复杂的情况下，在endorsement的 tran-proposal 字段可能不同，在这种情况下，endorsement策略指定状态如何改变。

根据为状态更新选择的一致性属性或者”隔离保证“，依赖性的验证可以用不同的方式实现。除非chaincode指定，串行化是一个默认的隔离保证。可以通过要求与状态中的每个键相关联的版本 readset 等于该键的版本，并且拒绝不满足该要求的事务来提供可串行性。
- 如果所有这些检查都通过，则交易被视为valid*or*committed。在这种情况下，peer在位掩码中用1标记事物 PeerLedger ，将 blob.endorsement.tran-proposal.writeset 应用于区块链的状态。(如果) tran-proposal 相同，否则endorsement策略逻辑定义所需的功能 blob.endorsement 。
- 如果endorsement策略验证 blob.endorsement 失败，交易无效，同时peer在位掩码中用1标记事物 PeerLedger 。需要注意的是，无效的状态不改变状态。

注意，这足以使所有（正确的）peer处理具有给定序列号的传输事件（块）之后具有相同的状态。也就是说，通过ordering服务的保证，所有正确的节点将接收确定的序列 deliver(seqno,prevhash,blob) 事件。由于endorsement策略的评估和 readset 中的版本依赖是确定性的，所有正确的peer节点也将得出相同的结论，即包含在blob中的交易是否有效。因此，所有的peer节点提交并应用相同的交易序列，并且以相同的方式安排状态更新。 
![ordering服务时序图](media/Fabric架构概述-ordering服务时序图.png)


## Endorsement策略
### Endorsement策略说明
一个endorsement策略，是在什么条件下endorse一个交易。区块链的peer节点有一组预先指定的endorsement策略，这些策略有安装在特定chaincode上的部署交易引用。Endorsement策略可以被参数化，这些参数可以被一个部署交易指定。

为了保证区块链的和安全属性，该组endorsement策略应该是一组经过验证的策略，这组 策略是有限的功能集，以确保有限的执行时间、确定性、性能和安全保证。

动态添加endorsement策略在有限策略评估时间、确定性、性能和安全保证方面十分敏感。**因此不允许动态添加endorsement策略，并却在未来可能得到支持。**

### 根据endorsement策略进行交易评估

交易只有在endorse后才能被宣布为有效的。一个chaincode的invoke交易首先必须获得一个满足chaincode策略的endorsement否则它不会被提交。这通过提交client和endorsing节点之间的交互而发生。

endorsement策略是endorsement的基础，并且可能进一步说明评估为TRUE或FALSE.对于部署交易，是根据系统范围内的策略(eg.系统chaincode)获得endorsement。

一个endorsement策略的确认涉及到一些变量，潜在的是： 
- 与chaincode相关的键和身份(在chaincode元数据(metadata)中找到)，例如，一组endorsers； 
- chaincode另外的元数据(metadata); 
- endorsement 和 endorsement.tran-proposal 的元素； 
- 其他潜在的变量。

上述列表通过表达性和复杂性的增加顺序排序，即，仅参考节点的密钥和身份的策略相对简单。

**endorsement策略评估必须是确定性的**。一个endorsement将由每个peer节点进行本地评估，这些peer不需要与其他的peer进行交互，所有正确的peer节点用相同的方式分析endorsement策略。

### Endorsement策略的例子
Predicate可以包含逻辑表达式并且评估是TRUE或者FALSE。通常情况下，在被endorsers节点调用的交易上使用数字签名。

假定chaincode指定了endorsers集合 E = {Alice, Bob, Charlie, Dave, Eve, Frank, George} 。一些事例策略：
- 一个有效签名来自相同的 tran-proposal ， tran-proposal 自所有E集合成员的有效签名。
- 来自E的任何单个成员的有效签名。
- 根据条件 (Alice OR Bob) AND (any two of: Charlie, Dave, Eve, Frank, George) 在相同的 tran-proposal 下的合法签名。
- 7个endorsers中的任何5个相同的 tran-proposal 上的有效的签名。(更一般情况下，对于endorsers有 n>3f ，需要 n 个endorsers中任意 2f+1 ，或者任意超过 (n+f)/2 个endorsers合法签名)。
- 假设有一个”state“或者”weight“分配给endorsers。例如： **{Alice=49, Bob=15, Charlie=15, Dave=10, Eve=7, Frank=3, George=1}** ，其中总的stake为100，该策略需要来自具有大多数stake的集合的有效签名（即，一个联合stake超过50的组，例如 **{Alice,x}** 与除 George 以外的其他任何背书者组成的组，等等。
- 先前示例中stake分配可以是静态的或动态的。
- （Alice or Bob）对 tran-proposal1 的有效签名，和从 **(any two of: Charlie, Dave, Eve, Frank, George)** 对 tran-proposal2 的有效签名，只有当他们的endorsers和状态更新时 tran-proposal1 和 tran-proposal2 才是不同的。

这些策略的有效性将取决于应用程序，取决于发生失败和endorsers错误行为时的恢复力以还取决于其他各种属性。

## (post-v1).被验证的账本和 PeerLedger 检查(精简)
### 被验证的账本(VLedger)
为了保持仅包含有效和已提交交易（例如在比特币中显示）的账本的抽象，peer除了状态和账本之外，还可以维护有效账本（或VLedger）。这是通过从账本中过滤掉无效交易产生的hash链。

VLedger块（这里称为vBlock）的构造如下进行。因为 PeerLedger 块可以包含无效交易（即，具有无效endorsement或具有无效版本依赖性的交易），所以在来自块的交易被添加到vBlock之前，这些事务被peer过滤掉。每个peer自己做这件事（例如，通过使用与PeerLedger相关联的位掩码 ）。vBlock被定义为没有无效交易的块，无效交易已被过滤掉。这样的vBlock在大小上是动态的并且可以是空的。下图给出了vBlock结构的示例。 
![vBlock结构示例](media/Fabric架构概述-vBlock结构示例.png)

Figure 2. 从分类帐（PeerLedger）块中验证的分类帐块（vBlock）的形成图。

- 前一个块vBlock的hash。
- vBlock号。
- 从计算最后一个vBlock开始，由peer提交的所有有效交易的有序列表（即，对应块中的有效交易的列表）。
- 导出当前vBlock的相应块的散列（in PeerLedger ）。

所有这些信息由peer连接和散列，产生有效账簿中的vBlock的散列。

### PeerLedger 检查节点
账本包含无效的交易，这没有必要永远记录。然而，peer不能简单地丢弃 PeerLedger 块，一旦它们建立相应的vBlocks就修剪 PeerLedger 。换句话说，在这种情况下，如果一个新的peer节点加入到网络中，其他节点不会将丢弃的块传输给新加入的块，或者认证它们的vBlocks的有效性。

为了促进 PeerLedger 的精简，这个文件描述成一个检查机机制。该机制通过对等网络建立vBlock的有效性，并允许检查点的vBlock替换丢弃的 PeerLedger 块。这反过来又减少了存储空间，因为不需要存储无效的交易。它还减少了重新构建加入网络的新对等体的状态的工作。(因为当通过重放 PeerLedger 来重建状态时它们不需要建立单独交易的有效性，而是可以简单地重放包含在有效账本中的状态更新)。

#### 检查协议
每个CHK块由peer周期性地执行检查操作，其中CHK是可配置参数。为了初始化一个检查点，peer节点向其他peer广播消息

#### 合法的检查节点
显然，检查点协议提出了以下问题： peer何时可以修剪它的“PeerLedger”？多少个“CHECKPOINT”消息是“足够多”？。这由检查点有效性策略定义，具有（至少）两种可能的方法，其也可以组合：

- 本地（特殊peer）检查点有效性策略（LCVP）。一个给定peer p 的本地策略可以指定peer p 信任的一组peer，并且其 **CHECKPOINT** 消息足以建立有效检查点。例如，根据LCVP，peer Alice可以定义 Alice需要从Bob或者从Charlie和Dave两者 **CHECKPOINT** 接收消息 。
- 全局检查点有效性策略（GCVP）。可以全局地指定检查点有效性策略。除了它在系统（区块链）粒度而不是peer粒度上规定，同本地peer策略是一样的。例如，GCVP可以指定： 
  - 如果由11个不同的peer确认，一个peer可以信任检查点。
  - 在某个部署中，每个orderer与一个peer在一个相同的机器中（即，信任域）中，而且f个orders可能是拜占庭错误，每个peer可以信任由f+1个peer证实的检查点。

[英文原版]（http://hyperledger-fabric.readthedocs.io/en/latest/arch-deep-dive.html）

