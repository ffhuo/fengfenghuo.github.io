# Zilliqa技术白皮书

[Version 0.1]

2017年8月10日

> Zilliqa团队

[TOC]

## 摘要

已知的现有的加密货币和智能合约平台都存在可伸缩性的问题，每秒钟处理交易的数量也是有限的，通常小于10。随着应用对加密货币使用量的增加和智能合约平台的发展，对处理高交易率的需求将成百上千的增长。

在这方面的工作中，我们介绍Zilliqa，一个用于规模化交易的区块链平台。随着矿工的不断加入，Zilliqa的交易率也将不断上升。在以太坊目前的网络中，大约有3万名矿工，Zilliqa预计将处理上千次的以太坊交易量。Zilliqa设计的基石是分片技术--将挖掘网络划分成每一个都能处理事物的平行的组。

Zilliqa进一步提出了一种智能合约语言和一个利用底层架构提供的大规模且高效的计算平台环境。Zilliqa的智能合约语言遵循数据流编程语言风格，这使得它非常适合运行大规模并行计算。例如，搜索、排序和线性代数计算，更复杂的计算例如训练神经网络、数据挖掘、金融模型、科学计算以及MapReduce的任务。

## 1. 简介

加密货币和智能合约平台正在成为共享的计算资源。我们可以把这些平台看作是同步的成千上万台个人电脑的新一代计算机。然而，现有的加密货币和智能合约平台广泛存在公认的规模（scaling）限制。平均事物率在比特币[^1]，以太坊[^2]以及相关的加密货币的每秒交易量被限制在10以下（通常是3-7）。那么我们能否建立一个大规模处理交易的去中心化的开放的区块链平台呢？

在某种程度上拓展现有协议的局限性在于，它们根植于共识和网络协议设计之中。因此，即使再造比特币或者以太坊现有协议的参数（比如块大小或者出块速率），可能有些加速，但是要支持成千上万事物量的处理需要从底层协议重新寻求出路。

我们提供了一个新的区块链平台Zilliqa，它可以成比例拓展事物处理速率。在Zilliqa中，随着矿工数量的增加，它的事物率也会随之增加。具体来说，Zilliqa的设计允许每当网络中新增几百个节点交易率就会翻倍。在写这篇文章时，以太坊的节点数量已经超过了30000个。以以太坊的现有节点数量来计，Zilliqa预计处理效率是以太坊的上千倍。

Zilliqa从新设计了底层框架，持续研究和开发已达两年之久。在Zilliqa中，分片的概念是设计的基石，将网络划分为更小的共识组，称为碎片。每个组都能并行的进行交易。如果Zilliqa网络有8000名矿工，Zilliqa会自动创建10个子网络，每个子网有800个矿工，在没有可信的协调者的情况下，以分散的方式运行。现在，如果一个子网络能够就一组100个交易（比如说）达成一致，在某一时期，10个子网络可以达成一致的交易量就会有千笔。安全聚合的关键在于确保子网络处理没有重复消费的不同的交易。

这些假设与现有的区块链解决方案类似。我们假设挖掘网络中存在一个总计算量占整个网络计算量一部分（< 1 / 4）的恶意节点。它基于标准的工作量证明方案，有一个新的两层区块链结构。它为处理碎片提供了高度优化的一致性算法。

Zilliqa还提供了一种特殊用途的智能合约语言和执行环境。利用底层架构提供了一个大型且高效的计算平台。在Zilliqa中，智能合约语言遵循数据流编程风格，其中智能合约可以表示为有向图。图表中的节点可以是操作或者函数，而两个节点之间的弧代表了第一个节点的输出和第二个节点的输入。当所有的输入都变为有效时，一个节点就会被激活（或操作），因此dataflow契约本质上是并行的，并且适合于像ZILLIQA这样的去中心化系统。

分片式架构对于大规模并行计算的处理是非常理想的。例子包括简单的计算，如搜索、排序和线性代数计算，到更复杂的计算，如训练神经网络、数据挖掘、金融建模、科学计算，以及一般的MapReduce任务。

本文概述了Zilliqa区块链协议的技术设计。Zilliqa有一个全新的，概念清晰的模块化的设计。它有六层：加密层（第三节）、数据层（第四节）、网络层（第五节）、共识层（第六节）、智能合约层（第七节）和奖励层（第八节）。在提出不同的层之前，我们首先在第二部分讨论系统设置，基本假设和威胁模型。

## 2. 系统设置和假设

## 3. 加密层

加密层定义了在ZILLIQA中使用的密码原语。与其他几个区块链平台类似，ZILLIQA依赖于数字签名的椭圆曲线密码术和一个内存硬哈希函数（PoW）。

在整个白皮书中，我们广泛使用SHA3[^6]哈希函数来表示我们的设计。SHA3最初基于Keccak[^7]，它广泛应用于不同的区块链平台，特别是以太坊。在不久的将来，我们可能会转向Keccak，以便更好地与其他平台进行互操作。

### A. Schnorr数字签名

Zilliqa采用基于椭圆曲线的Schnorr签名算法（EC-Schnorr）[^8]作为基本签名算法。我们用secp256k1曲线来实例化该方案。同样的曲线目前也在比特币和以太坊中使用，与另一签名算法ECDSA相比较，EC-Schnorr有以下几个好处：

1. **非延展性**：非正式地说，非可塑性属性意味着给定一组根据私钥和消息生成的签名，对于一个对手来说，使用相同的消息，和相应的公钥，应该很难生成一个新的签名。ECDSA不像ECDSA，它是可塑的，它已经被证明是不可塑的。不同于ECDSA的可塑性，ECSchnorr已经被证明是不可塑的[^10]。

2. **多重签名**：多签名方案允许多个签署者将他们的签名“聚合”到一个单独的签名上，这个签名可以通过“聚合”所有授权方的密钥的单个公钥进行身份验证。EC-Schnorr本身就是一个多签名方案（见[^11]），ECDSA允许创建多签名，但方式不太灵活。在一个消息需要多个签名时，ZILLIQA使用基于EC-Schnorr的多签名来减少签名的大小。在我们的共识协议中，较小的签名是特别重要的，在这个协议中，多方需要通过签署协议来达成一致。

3. **速度**：EC-Schnorr比ECDSA快，因为后者要求计算一个很大的逆模。在EC-Schnorr中不需要反转。

在附录A中给出了准确的EC-Schnorr密钥生成、签名和验证过程。在附录中，我们还介绍了如何将EC-Schnorr作为一个多签名方案使用。

### B. PoW

Zilliqa使用PoW来防止Sybil攻击并生成节点标识。这与许多现有的区块链平台（特别是比特币[^1]和以太坊[^2]）形成了鲜明的对比，在这些区块链中PoW用于达成分布式共识。Zilliqa使用了Ethash[^13]，这是一种PoW算法，在以太坊中被使用到。

Ethash是一种内存硬哈希函数，旨在让它更容易使用GPU，但对于诸如ASIC这样的专用计算硬件来说很难。为了达到这个目的，Ethash计算需要大量的内存（在GBs）和输入/输出带宽，这样就不能在专门的计算硬件上并行调用函数。

简单来说，Ethash接受一段数据（例如一个块头）和一个64位的nonce作为输入，并声称一个256位的摘要。该算法由四个子程序组成，这些子程序按照给定的顺序运行：

1. **种子生成**：种子是一个SHA3-256摘要，每隔30000个块就会更新一次，称为“新纪元”。对于第一个纪元，它是32字节的0的SHA3-256散列。每隔一段时间，它都是前一种子的SHA3-256散列。
2. **缓存生成**：根据种子使用SHA3-512生成一个伪随机缓存。缓存的大小随时间线性增加。缓存的初始大小是16MB。
3. **数据集生成**：然后使用缓存来生成数据集，数据集中每个“item”只依赖于缓存中的一小部分项。数据集每隔一段时间更新一次，这样一来，矿工们就不必频繁的更改数据了。数据集的大小也随时间线性增加，初始大小是1GB
4. **挖掘和验证**：挖掘涉及到对数据集随机分片并对它们进行散列。验证使用缓存来重新生成计算哈希所需的数据集的特定部分。

## 4. 数据层

从广义上讲，数据层定义了构成了ZILLIQA的全局状态的数据。此外，它还定义了ZILLIQA中不同实体所需要的数据，以更新其全局状态。

### A. 账户，地址和状态

ZILLIQA是一个基于账户的系统（像以太坊）。有两种类型的账户：正常账户和合同账户。一个正常的帐户是通过生成EC-Schnorr私有密匙创建的。合同帐户是由另一个帐户创建的。

每个帐户根据其类型的不同而派生出不同的地址。普通帐户的地址来自帐户的私钥。对于一个给定的私有密匙$sk$，该地址$A_{normal}$是一个160位的值，计算为：

$$
A_{nromal} = LSB_{160}(SHA3-256(PubKey(sk)))
$$

这里，$LSB_{160}(\cdot)$返回输入的最右边160位，$PubKey(\cdot)$返回对应于输入密钥的公钥。合同帐户的地址是从创建者的地址和创建者帐户发送的事务数计算出来的，也就是帐户nonce（如下所述）。

$$
A_{contract} = LSB_{160}(SHA3-256(address||nonce))
$$

地址是创建者帐户的地址，nonce是创建者的nonce值。

每个帐户（无论是正常的还是契约的）与一个帐户状态相关联。帐户状态是一个键值存储，由以下键组成：

1. **账户nonce**：（64位）计数器（初始化为0），计数从普通帐户发送的交易数。在合同帐户的情况下，它计算由该帐户创建的合同的数量。
2. **平衡**：（128位）一个非负的值。每当一个帐户接收来自另一个帐户的令牌时，接收的金额就会被添加到帐户的余额中。当一个帐户向另一个帐户发送令牌时，余额会被适当的数量减少。
3. **代码散列**：（256位）这个存储了契约代码的SHA3-256摘要。对于一个普通的帐户，它是空字符串的SHA3-256摘要。
4. **存储根**：（256位）每个帐户都有一个存储，它又是一个键值存储，有256位键和256位值。存储根是一个SHA3-256摘要，代表这个存储。例如，如果存储是trie，那么存储根是trie树的根的摘要。

ZILLIQA的全局状态（state）是帐户地址和帐户状态之间的映射。它是通过一个类似于trie树的数据结构实现的。

### B. 交易

交易总是从一个普通账户地址发出，它会更新Zilliqa的全局状态。一个交易具体有以下字段：

1. **version**：（32位）当前版本
2. **nonce**：（64位）一个计数器，等于该交易发送者发送的交易数。
3. **to**：（160位）目的账户地址，如果交易创建了一个新的合同账户，这个字段就是空字符串SHA3-256哈希散列后值的最右边160位
4. **amount**：（128位）将被转移到目标地址的交易总量
5. **gas price**: (128位)Gas被定义为最小的计价单元。Gas价格是指在交易处理过程中所需要支付的费用
6. **gas limit**：（128位）处理交易所需的Gas的最大数量
7. **code**：（无限制）一个可拓展的字节数组，它指定了契约代码。只有当交易创建一个新的合同账户的时候才会触发
8. **data**：（无限制）一种可扩展的字节数组，它可以指定用于处理交易的数据。只有当交易调用目标地址的合同时才会出现这种情况。
9. **pubkey**：（264位）一个EC-Schnorr公共密钥，该公钥应该用于验证签名。pubkey字段还决定交易的发送地址。
10. **signature**：（512位）一个EC-Schnorr对于全部数据的签名。

每个交易都由交易ID惟一标识——一个SHA3-256摘要，它是交易数据的摘要，不包括签名字段。

### C. 区块

## 5. 网络层

ZIlliqa已经被设计成按交易比例进行扩展。主要的思想是分片。将挖掘网络划分为小碎片，每个碎片可以并行处理事务。在本节中，我们将介绍网络和事务分片的概念。

### A. 网络分片

网络分片，即将挖掘网络划分为更小的碎片，这是一个两步的过程。首先，选出一个被称为目录服务委员会（或DS委员会）的专用节点集，然后对网络进行切分，并将节点分配给这些切分。我们将在下面详细介绍。

**1.目录服务委员会**：为了促进网络的分片，我们首先选出一组节点，称为目录服务（DS）节点。DS节点形成一个DS委员会。DS节点的选举是基于一个我们称之为PoW1的工作证明。在算法1中给出了PoW1的算法。

```txt
Algorithm 1: PoW1 for DS committee election.

Input: i: Current DS-epoch, DSi−1: Prev. DS committee composition.

Output: header: DS-Block header.

On each competing node:
// get epoch randomness from the DS blockchain
// DBi−1: Most recent DS-Block before start of i-th epoch
r1 ← GetEpochRand(DBi−1)
// get epoch randomness from the transaction blockchain
// TBj : Most recent TX-Block before start of i-th epoch
r2 ← GetEpochRand(TBj )
// pk: node’s public key, IP = node’s IP address
nonce, mixHash ← Ethash-PoW(pk, IP, r1, r2)
header ← BuildHeader(nonce, mixHash, pk)
// header includes pk and nonce among other fields
// IP, header is multicast to members in the DS committee
MulticastToDSi−1(IP, header)
return header
```

<!--TODO: 网络分片翻译-->

### B. 公共频道

DS节点在公共通道上发布某些信息，包括DS节点的标识和连接信息、每个碎片的节点列表，以及事务的分片逻辑（在5-D部分中解释）。公共通道是不可信的，所有的节点都是可以访问该通道的。
在我们的实现中，我们的广播原语实现了这样一个公共通道。

我们的区块链用户想要提交一份交易，然后就可以查看分片上的信息，从而让碎片负责处理她的事务。公共通道上发布的信息预计将由超过三分之二的DS节点签名，这些节点可以由任何节点或用户进行验证。

### C. 新加入Zilliqa的节点

一个新节点要想加入网络，它可以尝试POW1来成为一个DS节点，或者POW2来成为一个分片的成员。为达到这个目的，它需要获得一个来自POW1或者POW2所需的区块随机信息。一旦获得随机信息，新节点就可将其解决方案提交DS委员会。

### D. 交易分片和处理

正如5-A部分中所展示的，网络分片创建可以并行处理交易的组。在本节中，我们将介绍如何将特定交易分配给分片，以及如何处理交易。为此我们使用抽象$A \rightarrow B$来表示从发送者账户A到接收者账户B的一个交易。

<!--TODO: 交易分片和处理翻译-->

## 6. 共识层

如前所述，每个分组和DS委员会必须分别在微块和最后块上运行一致协议。在本节中，我们将介绍共识层，该层定义了在每个分组和DS委员会中运行的共识协议。在剩下的讨论中，我们把碎片和DS委员会统称为一个共识小组。

### A. PBFT

Zilliqa共识协议的核心是依赖于卡斯特罗和李斯科夫[^3]提出的实用拜占庭容错（PBFT）协议。我们任然可以提高它的效率，通过使用EC-Schnorr多重签名的思想在PBFT协议上发展而来[^14][^15]。使用EC-Schnorr多重签名可将正常情况下的通信延迟从$O(n^2)$降到$O(n)$，并将签名大小从$O(n)$降到$O(1)$，其中，n为共识组的大小。在本节中，我们将介绍PBFT。

在PBFT中，一个共识组中的所有节点都是有序排列的，并且有一个主节点（或领导者），其他节点被称为备份节点。每轮PBFT有三个阶段，如下：

1. **预准备阶段**：在这个阶段，领导宣布下一个记录（在我们的案例中是一个TX-Block），团队应该同意。
2. **准备阶段**：在接收预准备消息时，每个节点都验证其正确性，并向所有其他节点发送一条准备消息。
3. **提交阶段**：在接收超过2n/3条准备消息时，一个节点最终将提交消息发送到群组，一个节点等待超过2/3个提交消息，以确保足够数量的节点做出了相同的决策。因此，所有诚实的节点都接受相同的有效记录。

PBFT依靠一个正确的领导者来开始每一阶段，并在有足够的多数时进行。如果领导者是拜占庭式的，它可能会阻碍整个共识协议。为了应对这一挑战，PBFT提供了一个视图变更协议，以取代拜占庭式的领导者。如果节点在有限时间内看不到任何进展，它们可以独立地宣布改变领导者的意愿。如果超过2n/3个节点的认定领导是有缺陷的，那么在一个众所周知的时间表下，下一个领导者就会接管。

由于在准备/提交阶段的每个节点的多播，在正常情况下，PBFT的通信复杂性是$O(n^2)$。

### B. 效率提高

经典的PBFT使用消息验证码（MAC）来进行节点间的身份验证。由于MAC需要在每两个节点之间共享一个密钥，一个共识组中的节点可以在相同的记录上达成一致，每个节点的通信复杂度为$O(n^2)$。由于二次复杂度，当委员会有超过20个节点时，PBFT变得不切实际。

为提高效率，我们使用受ByzCoin[^15]启发得到的方案：

1. 我们用数字签名替换MAC，以有效的减少通信复杂度到$O(n)$。
2. 同时为了方便其他节点验证协议，一种典型的方法是收集来自诚实节点的签名，并将它们附加到协议中，这样的结果是导致了协议大小以共识组的大小线性增长。为了改进这一点，我们使用EC-Schnorr多签名来将多个签名聚合到大小为$O(1)$的多签名中。

然而，我们不能直接在PBFT的设置中使用经典的EC-Schnorr多重签名方案。这是因为在经典设置中，所有签署者都同意签署一个给定的消息，签名只有在所有签名者都签署了消息时才有效。在PBFT设置中，我们只要求一条消息在共识组中被超过2n/3的节点签名。需要进行的主要修改之一是为参与签名过程的签署者维护位图B。如果第i个节点参与了这个过程，$B[i] = 1$，否则它就是0，位图是由领导者构建的。任何验证器都可以使用位图来验证签名。所产生的协议在附录B中。

### C. Zilliqa共识

在ZILLIQA中，我们使用了PBFT作为基本共识的协议，并使用了两轮EC-Schnorr多签名来代替PBFT中的准备和提交阶段。下面解释了对PBFT不同阶段的修改。

1. **预准备阶段**：在标准的PBFT中，领导者将一个TX-Block或一个声明（由领导者签名）分发到共识组中的所有节点。
2. **准备阶段**：所有诚实的节点都检查TX-Block的有效性，而领导者收集的响应来自超过2n/3个节点。这保证了领导者提出的声明是安全的，并且与之前所有的历史相一致。签名是使用EC-Schnorr多重签名生成的。领导者还构建了签署TX-Block的节点位图。
3. **提交阶段**：为了确保超过2n/3个节点知道超过2n/3个节点已经验证了TX-Block的事实，我们将执行第二轮EC-Schnorr多签名。正在签署的声明是上一轮生成的多签名。

在这三个阶段的最后，达成了领导人提出的TX-Block的共识。

### D. 领导者变更

在我们的共识协议中，如果领导者是诚实的，它可以驱使共识组中的节点不断地达成新的交易集协议。但是，如果领导是拜占庭式的，它可以故意延迟或从诚实节点上删除消息，并降低协议的速度。为了惩罚这些恶意的领导者，我们的协议定期更换每个碎片和DS委员会的领导。这就避免了拜占庭领导人在无限时间里拖延共识协议。因为所有的节点都是有序的，所以下一个领导者将以循环的方式被选中。

事实上，在每一个最终块之后，微块和DS委员会的领导者都会发生改变。让我们假设共识组的大小是n，然后在一个DS间隔内，我们允许最多有n个最终块，每个分片的每个最终块最多可以聚集一个微块。

## 7. 智能合约层

Zilliqa提供了一种创新的专用智能合约语言和执行环境，利用底层架构提供了一个大型且高效的计算平台。在本节中，我们将介绍使用数据流编程架构的智能合约层。

### A. 使用数据流范例的计算分片

<!--TODO: 使用数据流范例的计算分片翻译-->

### B. 智能安全预算

<!--TODO: 智能安全预算翻译-->

### C. 可伸缩的应用程序:实例

<!--TODO: 可伸缩的应用程序:实例翻译-->

## 8. 奖励层

### A. 令牌供应

<!--TODO: 令牌供应翻译-->

### B. 激励矿工

<!--TODO: 激励矿工翻译-->

## 9. 相关工作

Zilliqa是基于比特币-NG[^18]，集体签名（CoSi）[^14],ByzCoin[^15]，Elastico[^19]和Omniledger[^20]理念发展起来的。

Bitcoin-NG协议首先提出一种想法，即在比特币内部，将领导人选举和他的封杀提议脱钩。首先，通过挖掘一个块来选出一个领导者，它可以在10分钟的间隔内生成许多微块，这个想法在Byzcoin[^15]中被进一步使用。

对比特币系统进行网络化和交易的想法最初是在[^19]被提出的。然而，单独的网络/交易分片不能解决可伸缩性的问题，因为每个碎片都需要签署一个TX-Block，这使得签名总数总是线性的。这最终导致了一个大的块大小，并且成为了在广播和多播间的瓶颈。

多签名[^11]为上述问题提供了一个解决方案，CoSi[^14]使用EC-Schnorr多签名方案来设计用于集体签名的协议。CoSi被提议在一个平和的环境中工作，而不是带有拜占庭节点的公共区块链中。我们为CoSi方案开发了几个重要的增强，我们推出了一个安全方案并将其应用到Zilliqa上。

还有一些其他的提议，以回避现有的区块链协议固有的可伸缩性限制，例如，重新参数化原始的比特币协议（例如增加块大小），移动大量的计算链（如微支付渠道和闪电网络），创建区块链的层级（如侧链）。这些协议都没有直接使区块链协议本身更具可扩展性。ZILLIQA瞄准了可伸缩性问题的核心——它的区块链。

Zilliqa可以看作是ByzCoin和OmniLedger在安全和性能上的一种拓展。Zilliqa还提出一个在Byzcoin和OmniLedger上不能提供的智能合约平台。

与以太坊相比，Zilliqa的智能合同平台采用了不同的方式。Zilliqa的智能合同平台利用了底层的分片架构，并基于数据流编程。数据流程序的优点有很多：固有的并发性和并行性，很容易推断出它们的正确性、函数和程序的自然可组合性等等。

## 10. 未来研究方向

## 11. 总结

## 参考文献

[^1]: S. Nakamoto, “Bitcoin: A peer-to-peer electronic cash system, <http://bitcoin.org/bitcoin.pdf>,” 2008.
[^2]: E. Foundation, “Ethereum’s white paper,” <https://github.com/ethereum/wiki/wiki/White-Paper>, 2014.
[^3]: M. Castro and B. Liskov, “Practical Byzantine Fault Tolerance,” in Proceedings of the Third Symposium on Operating Systems Design and Implementation, ser. OSDI ’99. Berkeley, CA, USA: USENIX Association, 1999, pp. 173–186.
[^4]: E. Heilman, A. Kendler, A. Zohar, and S. Goldberg, “Eclipse Attacks on Bitcoin’s Peer-to-Peer Network,” in 24th USENIX Security Symposium (USENIX Security 15). Washington, D.C.: USENIX Association, 2015, pp. 129–144.
[^5]: S. Gilbert and N. Lynch, “Brewer’s Conjecture and the Feasibility of Consistent Available Partition-Tolerant Web Services,” in In ACM SIGACT News, 2002, p. 2002.
[^6]: NIST, “Sha-3 standard: Permutation-based hash and extendable-output functions,” 2015.
[^7]: B. Guido, D. Joan, P. Michael, and V. A. Gilles, “The Keccak Reference” 2011.
[^8]: C. Schnorr, “Efficient signature generation by smart cards,” J. Cryptology, vol. 4, no. 3, pp. 161–174, 1991.
[^9]: C. Research, “SEC 2: Recommended Elliptic Curve Domain Parameters,” 2000. [Online]. Available: <http://www.secg.org/download/aid-386/sec2-final.pdf>
[^10]: A. Poelstra, “Schnorr Signatures are Non-Malleable in the Random Oracle Model,” 2014.
[^11]: S. Micali, K. Ohta, and L. Reyzin, “Accountable-subgroup Multisignatures: Extended Abstract,” in Proceedings of the 8th ACM Conference on Computer and Communications Security, ser. CCS ’01. New York, NY, USA: ACM, 2001, pp. 245–254.
[^12]: G. Wood, “Ethereum: A secure decentralised generalised transaction ledger,” <http://gavwood.com/paper.pdf>, 2014.
[^13]: “Ethash,” <https://github.com/ethereum/wiki/wiki/Ethash>, Accessed on June 27, 2017., version 23.
[^14]: E. Syta, I. Tamas, D. Visher, D. I. Wolinsky, P. Jovanovic, L. Gasser, N. Gailly, I. Khoffi, and B. Ford, “Keeping authorities ”honest or bust” with decentralized witness cosigning,” in IEEE Symposium on Security and Privacy, SP 2016, San Jose, CA, USA, May 22-26, 2016, 2016, pp. 526–545.
[^15]: E. Kokoris-Kogias, P. Jovanovic, N. Gailly, I. Khoffi, L. Gasser, and B. Ford, “Enhancing Bitcoin Security and Performance with Strong Consistency via Collective Signing,” in 25th USENIX Security Symposium, USENIX Security 16, Austin, TX, USA, August 10-12, 2016., 2016, pp. 279–296.
[^16]: Arvind and D. E. Culler, “Annual review of computer science vol. 1, 1986,” J. F. Traub, B. J. Grosz, B. W. Lampson, and N. J. Nilsson, Eds. Palo Alto, CA, USA: Annual Reviews Inc., 1986, ch. Dataflow Architectures, pp. 225–253.
[^17]: A. L. Davis and R. M. Keller, “Data flow program graphs,” Computer, vol. 15, no. 2, pp. 26–41, Feb. 1982.
[^18]: I. Eyal, A. E. Gencer, E. G. Sirer, and R. van Renesse, “Bitcoinng: A scalable blockchain protocol,” in 13th USENIX Symposium on Networked Systems Design and Implementation, NSDI 2016, Santa Clara, CA, USA, March 16-18, 2016, 2016, pp. 45–59.
[^19]: L. Luu, V. Narayanan, C. Zheng, K. Baweja, S. Gilbert, and P. Saxena, “A secure sharding protocol for open blockchains,” in Proceedings of the 2016 ACM SIGSAC Conference on Computer and Communications Security, Vienna, Austria, October 24-28, 2016, 2016, pp. 17–30.
[^20]: E. Kokoris-Kogias, P. Jovanovic, L. Gasser, N. Gailly, and B. Ford, “Omniledger: A secure, scale-out, decentralized ledger,” IACR Cryptology ePrint Archive, vol. 2017, p. 406, 2017.
[^21]: E. Stefanov, M. van Dijk, E. Shi, C. W. Fletcher, L. Ren, X. Yu, and S. Devadas, “Path ORAM: An Extremely Simple Oblivious RAM Protocol,” in 2013 ACM SIGSAC Conference on Computer and Communications Security, CCS’13, Berlin, Germany, November 4-8, 2013, 2013, pp. 299–310.
[^22]: E. Ben-Sasson, A. Chiesa, E. Tromer, and M. Virza, “Succinct NonInteractive Zero Knowledge for a von Neumann Architecture,” in Proceedings of the 23rd USENIX Security Symposium, San Diego, CA, USA, August 20-22, 2014., 2014, pp. 781–796.
[^23]: P. Mohassel, S. S. Sadeghian, and N. P. Smart, “Actively Secure Private Function Evaluation,” in Advances in Cryptology - ASIACRYPT 2014 - 20th International Conference on the Theory and Application of Cryptology and Information Security, Kaoshiung, Taiwan, R.O.C., December 7-11, 2014, Proceedings, Part II, 2014, pp. 486–505.
[^24]: BSI, “Technical Guideline TR-03111 Elliptic Curve Cryptography,” Federal Office for Information Security, Tech. Rep., 01 2012.
[^25]: D. J. Bernstein, “Multi-user Schnorr Security, Revisited,” IACR Cryptology ePrint Archive, vol. 2015, p. 996, 2015. [Online]. Available: <http://eprint.iacr.org/2015/996>
[^26]: M. Michels and P. Horster, “On the Risk of Disruption in Several Multiparty Signature Schemes,” in Proceedings of the International Conference on the Theory and Applications of Cryptology and Information Security: Advances in Cryptology, ser. ASIACRYPT ’96. London, UK, UK: Springer-Verlag, 1996, pp. 334–345.

## 附录A Schnorr数字签名算法

## 附录B 多重签名PBFT