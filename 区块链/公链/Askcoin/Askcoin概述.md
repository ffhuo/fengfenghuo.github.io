# Askcoin概述

## 简述

AskCoin系统是专为知识共享平台设计的区块链基础设施，Askcoin 是基于 DAG 技术的底层区块链系统，它为知识和现金之间的转换提供了最为便捷的通道。

## 特点

- 加密技术：[Bech32/Base32编码](../../核心技术/加密技术/编解码-Base32.md)和[Ed25519签名算法](../../核心技术/加密技术/加密算法-Ed25519.md)
- 共识机制：DAG自带的共识性
- 组网：[DAG](../../核心技术/组网拓扑/DAG网络.md)

1. Askcoin使用椭圆曲线加密算法（ECC）来作为公钥密码算法。选择使用ed25519作为签名算法。

2. Askcoin的地址通过ECC算法生成的公私钥对推衍而生成，具体采用比特币BIP173协议中提出的Bech32/Base32编码方法进行编码，相比[base58](../../核心技术/加密技术/编解码-Base58.md)效率更高，功能更强大。

**架构特点**：使用DAG这种基于图的数据就够相对于传统的数据结构将帮助Askcoin更好的解决**水平扩容、交易延伸性等**问题。

在DAG中，没有区块的概念，所以也没有出块时间的概念。由于DAG这种基于图的数据结构并不像传统区块链那样基于链的数据结构那样具有严格的顺序，所以会产生双花的问题。

因此基于DAG的区块链平台必须解决双花问题。字节雪球提出了主链（mainchain）的概念，通过见证人机制来解决双花问题。Askcoin也将沿用这种机制，实现自己的主链选择算法，通过Askcoin Hub（Askcoin自己的见证人机制）来解决双花问题。

Askcoin平台在实现上会采取[侧链（sidechain）](../../核心技术/侧链技术/BTC-Relay与RootStock侧链技术对比.md)技术，会成为比特币和以太坊的侧链。可以使用Askcoin代币ASK自由兑换BTC和ETH。通过让ASK成为BTC、ETH网络的侧链实现直接跨链交易的功能。

## 发展路线

- 2017年6月16日 发布AskCoin白皮书草案
- 2017年6月17日 AskCoin preICO众筹
- 2017年6月25日 AskCoin官网上线
- 2017年7月 AskCoin ICO 北京/上海 路演
- 2017年7月 AskCoin ICO
- 2017年8月 发布AskCoin白皮书正式版
- 2017年8月 发布AskCoin开发路线图
- AskCoin ERC20代币上线交易平台
- 2017年11月 AskCoin 测试网络alpha、ASK手机钱包发布
- 2018年2月 AskCoin 正式网发布，创世区块生成
- 2018年2月 兑换正式ASK币
- 2018年5月 AskCoin应用：区块链技术问答社区上线

## 网站

- 官网：<http://askcoin.org>

- 社区:
    - Slack：<https://askcoin.slack.com/>
    - Github：<https://github.com/askcoin>

- 博客：<https://askcoin.org/blog/>

## 收集数据

- [Askcoin白皮书](Askcoin白皮书.md)
