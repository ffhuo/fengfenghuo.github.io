# AMBR概述

## 简述

AMBR是一个复合型分布式操作系统，对于现有的区块链和DAG网络，Ambr在以下三方面做出了技术改进与革新：Galaxygraph算法，智能合约，多链与跨链。

- Galaxygraph：重新定义交易单元，拓展多种交易类型，并在共识层使用复合型节点共识，同时根据节点信用进行动态赋权，从而解决传统DAG网络手续费分发与节点激励的难点。

- 智能合约：改变传统区块链结构下因强一致性原则而必须使用固定时间戳执行交易与合约的方式，将指定时间域作为合约执行缓冲期，在一定权重周期内达成全网共识，以此来解决DAG网络偏序结构下难以实现智能合约的痛点。

- 多链与跨链：在多链共识中引入报信人与验证者角色，分别用于消息通信与交易确认，将链上功能封装为可拔插模块，并使其具有片区容错性。在Ambr的跨链系统中，可采用侧链作为中继链，实现可信消息传递与资产的价值转移。

## 特点

- 加密技术：zk-snarks加密算法
- 共识机制：Galaxygraph的共识机制是一种Credit Continuing（信用延续）的共识，信用节点被分为五类：general, encrypted, contract, cross, foo 。其本身的信用基础来自于网络之前的无故障率交易、接收手续费多少、即时网络各节点类型数量。这是一种节点权力更新型机制。General节点被归为level1等级节点，encrypted与contract节点被归为level2等级节点，cross与foo被归为level3等级节点，每种等级节点确认相应类型的交易，不同交易的权重分别为1，3，5。

- 智能合约：使用了时间+权重缓冲确认的方式来使得DAG网络上实现智能合约具有可行性。解决了DAG时间确认的问题

- 跨链机制：Ambr主链、侧链均可作为一条中继链，与其他区块链项目进行对接时会生成对应的链。

- 组网：Galaxygraph算法：交易速度极快，甚至远高于DAG网络的速度。

## 发展路线

- 2018

    - Feb-March：融资（Financing）

    - 15thApr：交易与共识黄皮书，交易包括信区间等与共识系统包括复合型节点的更新机制细则的具体设计与严格数学证明

    - 15thMay：DAG+智能合约黄皮书

    - 15thJune：多维与跨链黄皮书

    - 15thJuly：Ambr系统代码结构总览

    - Aug:主网上线，全部源码开源

    - Nov：智能合约上线

- 2019

    - Jan：PermissionSystem+Mult：Chain，Cross-cjainDemo

    - Apr：Multi-chain，Cross-chain+EncryptedTransacttionsDemo

    - July：CustomTransction+智能合约库完善

    - Oct：EncryptedTransactionsystem

    - Jan：完成去中心化运营，持续更新与运维

## 网站

- 官网： <http://www.ambr.org/index_CN.html#>

## 收集资料

- [AMBR白皮书](AMBR白皮书.md)
