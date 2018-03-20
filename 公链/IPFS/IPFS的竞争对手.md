# IPFS的竞争对手
[TOC]

## Storj

官方网站：<https://storj.io/>
白皮书: <https://storj.io/storj.pdf>
代币符号: STORJ
ICO日期：2017.5.19-2017.5.25
ICO筹集资金: 3000万美元
代币总量：5亿个
合约地址: 0xb64ef51c888972c908cfacf59b47c1afbc0ab8ac
区块链浏览器：<https://etherscan.io/token/Storj>

**Storj是一个区中心化的云存储平台**，跟百度云盘一样的服务，业务流程是，用户从Storj处付费租用空间，矿工共享自己的磁盘获取代币。Storj的挖矿软件（GUI界面）做的不错，设置比较简单。下载软件，一步步跟Next就可以完成，中间需要输入自己的代币获取地址，由于Storj使用的ERC20协议，代币地址使用自己的以太坊地址就可以了。

**影响挖矿的因素有：**

- 共享的硬盘空间大小
- 上传和下载的速度
- Storj节点的可靠性和可用性（别老掉线）
- 空间的需求量

分布式存储的价格优势，Storj跟亚马逊的S3和微软Azure对比，想试试的同学不妨去申请个空间玩玩。

> Storj: \$0.015 GB/月
> S3:    \$0.023 GB/月
> Azue:  \$0.030 GB/月

Storj提供第一年25G的免费空间。申请地址：<https://app.storj.io/signup>

## Sia

官方网站：<https://sia.tech>
ICO: 无
代币总量：314亿枚
区块链浏览器：<http://explore.sia.tech/>
钱包地址：<https://sia.tech/apps/>

Sia跟 Storj非常像，也是一个去中心化的云存储平台，文件被切成小块，加密存储到分布式的网络里面。Sia使用的GPU挖矿，如果要参与就需要买显卡了。Sia挖矿跟BTC一样需要加入矿池，挖矿设置也比较复杂。

挖矿软件下载地址：<https://siawiki.tech/mining/software>。

Sia的挖矿和共享硬盘是分开的（这一点跟Storj不一样），如果参与Sia的硬盘共享，只需要下载钱包，在里面简设置一下就可以了。

**参与Sia的硬盘共享条件**

- 抵押 Siacoin的，最少抵押是2000SC，官方的建议是：每T的抵押成本为2万-5万SC。（IPFS也需要抵押）
- 共享空间至少达到20G
- 静态IP或者使用动态DNS（网上有提供免费动态DNS服务比如：https://www.noip.com）
- 开放端口 9981和9982
- Sia的合约执行期长达13周，也就是3个月才能收到共享硬盘的收益（这时间也太长了）
- Sia合约要求7x24小时时间 97%在线，低于这个时间可能会导致合约失败，那么可能你的抵押SC会被扣掉（有点坑）

## Burstcoin

代币符号：BURST
官网：<https://www.burst-coin.org>
目前交易所价格：0.16RMB
总量：18亿枚

Burst作为第一个使用容量证明（Proof-of-capacity）的项目还是具有很大的进步意义的。
按官方的说法是挖矿很简单，只需要下载AIO client就可以了，

项目是2014.8.10从 bitcointalk 上发起的，发起人是的账号是 “Burstcoin”，一年后创始人 “Burstcoin”跟中本聪一样消失了，不知道为什么，也不知道真实身份（区块链的匿名性特点，是不是都是遗传自这些创始人？）由于项目是开源的，2016年1月11号一些成员做了接盘侠，在 Bitcointalk上开了一个新的板块。

项目地址: <https://github.com/burst-team/burstcoin/graphs/contributors>

## Genaro

代币符号：GNX
当前交易所价格：0.4美元
ICO日期：2017.11.17~11.30
ICO成本：1ETH=3000~3800GNX，当时大约折价：0.1~0.7美元
官网：<https://genaro.network>
白皮书：<https://genaro.network/en/documentation/whitepaper>

Genaro号称是第一个具有图灵完备公有链的分布式存储区网络

图灵完备的意思就是：可以实现图灵机，解决所有可计算问题。

Genaro由新加坡非盈利基金会 Genaro Ltd开发运营。Genaro生态系统的目标打造区块链3.0，作为下一代区块链平台，帮助区块链应用落地。

**Genaro网络 = 公有链+去中心化存储**

1. 去中心化的存储网络共识机制：SPoR (Sentinel Proof of Retrievability)
2. 公有链共识机制：权益证明 proof of stake（跟以太坊一样）

就是在以太坊上面添加了一个分布式存储。

Genaro上面的第一个落地项目已经开始测试了，有兴趣可以申请一下测试账号试一下 <https://genaro.network/hk/genaro_eden/>

第一个项目Genaro_eden是基于Storj做的。小编在github上找到了Genaro_eden客户端代码，小编只是想瞅瞅他们怎么实现的，你们猜小编发现了什么，Genaro_eden这货只是 Storj的一个js实现客户端，Genaro和 Storj勾搭到了一起 ，小编申请的测试账号号称正在审批中，（如果只是一个Storj的话，我还要什么测试账号），当然我没有看完全部的源代码，也许后面有自己的东西？

## MaidSafe

代币符号：MAID
总量：大约45亿
官网地址：<https://maidsafe.net/>
项目源代码主页：<https://github.com/maidsafe-archive>
共识机制：资源证明（Proof of Resouce），资源包括，CPU，存储，带宽，在线时长

关于MaidSafe网上的资料不太多，包括官网都没有太多资料。

这个项目起步于2006年（看到这个我还怎么抱怨IPFS开发进度太慢）。从官方论坛得知：2014年众筹的时候项目把币全部卖出去了。也就是说以后挖矿的时候，只能从交易中获取币，并不能像想起他挖矿一样进行挖币（官方称为Farmer），区块链的用途实际上是一个交易市场，用户提供资源，矿工获取支付。

## CDN类的项目

BlockCDN：<http://www.blockcdn.org/>
流量矿石：<https://www.lltoken.com/>
游娱宝盒：<http://www.gechain.cc/>
暴风播控云：<http://bfc.baofeng.com/index_pc.html>
玩客云：<https://red.xunlei.com/>
赤链的无花果：<http://www.figtoo.com/>
锐角云：<https://acuteangle.com/index_zh.html>

<!-- TODO: @Beik #A 项目白皮书撸一遍，商业上、技术上的差异搞出来 -->

这些基本上都是做CND加速的，竞争的是同一个市场（上行流量市场），在我国经营CDN是要牌照的，给大家一张目前已经获取到CDN牌照的企业，投资的时候大家睁大眼睛就好了，当然拥有牌照跟能把CDN卖出去是两回事，别被割了韭菜，分布式CDN网络相当于实现了IPFS的一部分，目测还会有一波进来的。



