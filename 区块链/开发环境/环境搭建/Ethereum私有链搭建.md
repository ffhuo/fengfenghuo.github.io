# Ethereum私有链搭建

Ethereum私有链搭建所需环境：

- Go语言环境支持，请参照[GoLang环境配置](GoLang环境配置.md)
- Ethereum源码支持，请参照[Ethereum源码编译环境](Ethereum源码编译环境.md)

有了以上支持，命令geth就可以使用了，这是搭建私有链准备工作。

## 1.定制创世文件

创世区块是整个区块链的开端——第一个区块，编号是0，也是唯一一个没有前驱指向的区块。协议必须确保没有其他节点会认同你的区块链版本，除非他们拥有同样的创世区块。因此你可以创造出任意多的私有测试网络。

配置自己的创世块是为了区分公有链，同一个网络中，创世块必须是一样的，否则无法联通，此方法在windows和MacOS下通用。

新建文件夹PrivateEtherNet，这里将文件夹放在目录GoWork底下，文件夹底下新建privateEtherBlock.json，用于配置传世区块的信息，内容如下：

```txt
{
    "config": {
          "chainId": 10,
          "homesteadBlock": 0,
          "eip155Block": 0,
          "eip158Block": 0
      },
    "coinbase"   : "0x0000000000000000000000000000000000000000",
    "difficulty" : "0x20000",
    "extraData"  : "",
    "gasLimit"   : "0x2fefd8",
    "nonce"      : "0x0000000000000042",
    "mixhash"    : "0x0000000000000000000000000000000000000000000000000000000000000000",
    "parentHash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
    "timestamp"  : "0x00",
    "alloc"      : {}
}
```

解释一下各个参数的作用：
| 参数 | 作用 |
| -------------- | ------------------------------------------------------------ |
| **mixhash**    | 与nonce配合用于挖矿，由上一个区块的一部分生成的hash。注意他和nonce的设置需要满足以太坊的Yellow paper, 4.3.4. Block Header Validity, (44)章节所描述的条件。 |
| **nonce**      | nonce就是一个64位随机数，用于挖矿，注意他和mixhash的设置需要满足以太坊的Yellow paper, 4.3.4. Block Header Validity, (44)章节所描述的条件。 |
| **difficulty** | 设置当前区块的难度，如果难度过大，cpu挖矿就很难，这里设置较小难度 |
| **alloc**      | 用来预置账号以及账号的以太币数量，因为私有链挖矿比较容易，所以我们不需要预置有币的账号，需要的时候自己创建即可以。 |
| **coinbase**   | 矿工的账号，随便填                                           |
| **timestamp**  | 设置创世块的时间戳                                           |
| **parentHash** | 上一个区块的hash值，因为是创世块，所以这个值是0              |
| **extraData**  | 附加信息，随便填，可以填你的个性信息                         |
| **gasLimit**   | 该值设置对GAS的消耗总量限制，用来限制区块能包含的交易信息总和，因为我们是私有链，所以填最大。 |

网上的资料，`extraData`填的内容为`0x00`运行回报错误：

```txt
Fatal: invalid genesis file: json: cannot unmarshal hex string without 0x prefix into Go struct field Genesis.extraData of type hexutil.Bytes
```

不填可运行通过。

> 此创世区块的定义Ethereum源码版本1.8.4，较早版本的定义方式与此不相同。

## 2.启动私有链节点

启动geth即可以启动以太坊的区块链，为了构建私有链 ，需要在geth启动时加入一些参数，geth参数含义如下：
| 参数  | 意义         |
| ------------- | ------------------------------------------------------|
| **identity**  | 区块链的标示，随便填写，用于标示目前网络的名字         |
| **init**      | 指定创世块文件的位置，并创建初始块                     |
| **datadir**   | 设置当前区块链网络数据存放的位置                       |
| **port**      | 网络监听端口                                           |
| **rpc**       | 启动rpc通信，可以进行智能合约的部署和调试              |
| **rpcapi**    | 设置允许连接的rpc的客户端，一般为db,eth,net,web3       |
| **networkid** | 设置当前区块链的网络ID，用于区分不同的网络，是一个数字 |
| **console**   | 启动命令行模式，可以在Geth中执行命令                   |

由于geth是通过以太坊源码生成的，所以需使当前目录在`GoWork/bin/`，VSCode终端输入命令

```txt
geth --datadir "../PrivateEtherNet/chain" init ../PrivateEtherNet/privateEtherBlock.json
```

此命令创建数据存放地址PrivateEtherNet/chain并初始化创世块。

再执行：

```txt
geth --identity "Textetherum" --rpc --rpccorsdomain "*" --datadir "../PrivateEtherNet/chain" --port "30303"  --rpcapi "db,eth,net,web3,personal" --networkid 95518 console
```

当看到`Welcome to the Geth JavaScript console!`信息时，表示已经启动成功。

## 3.使用节点创建帐号

启动节点成功后，会进入Geth的命令行模式，输入如下命令

```txt
personal.newAccount()
```

系统会提示你输入账号密码，并确认，最后会显示一个新生成的账号。

0xfb6c3ab31919d42959a9adc7bfcc7fda6a8448a4

查看当前账户的以太币需执行以下命令：

```txt
eth.accounts
```

返回你拥有的账户地址排列

```txt
primary = eth.accounts[0]
```

注意：用你的账户指数取代0，这个控制台指令会返回到你第一个以太坊地址。

输入以下指令：

```txt
balance = web3.fromWei(eth.getBalance(primary), "ether");
```

返回值即为当前选择账户的以太币。

或者直接使用命令：`eth.getBalance(eth.accounts[0])`。

## 4.使用节点进行挖矿

在`geth`命令行界面，输入`miner.start()`即启动挖矿，输入`miner.stop()`即停止挖矿，不必在意挖矿刷屏，命令仍会正常执行。

节点信息可通过`admin.nodeInfo`命令查看。

这里再说明几个`geth`命令行下常用命令：

```txt
miner.setEtherbase(eth.accounts[1])  //以账户1作为coinbase，挖到区块以后，账户1的以太币就会增加

personal.unlockAccount(eth.accounts[0]) //解锁账户，某些情况下账户会被锁掉而不能交易或创建合约，可使用此命令解锁账户

amount = web3.toWei(5,'ether')
eth.sendTransaction({from:eth.accounts[0],to:eth.accounts[1],value:amount}) //从账户0转移5个以太币到账户1

eth.blockNumber //查看当前区块总数

eth.getTransaction("0x0c59f431068937cbe9e230483bc79f59bd7146edc8ff5ec37fea6710adcab825") //通过交易hash查看交易
eth.getBlock(33)  //通过区块号查看区块
```

## 5.多节点挖矿

此处Windows平台操作时，运行一个geth命令行后，无法再运行另一个geth命令行，提示错误`Fatal: Error starting protocol stack: Access is denied.`，查到问题为不能打开多个终端，暂未解决此问题。

此处以MacOS平台环境说明，目标为成功运行两个节点，节点0和节点1，节点1连接到节点0

### 运行节点0

1. 创建数据存放地址PrivateEtherNet/chain/00并初始化创世块，`./geth --datadir "../PrivateEtherNet/chain/00" init "../PrivateEtherNet/privateEtherBlock.json"`
2. 启动geth命令行`./geth --rpc --datadir "../PrivateEtherNet/chain/00" --rpcapi "db,eth,net,web3,personal" --networkid 95518 console`
3. 创建账户`personal.newAccount("111111")`，参数为账户密码
4. 获取当前节点的信息`admin.nodeInfo.enode`，得到`enode://429d21ba4915fa37b5d66e78bae48e82c76601306ae4cab2f0abebd5619f1ec02f10a216078b12fb71386adca122d7e4f124536738a0dee37137c1e3d2c9f840@222.73.203.10:30303`
5. 开始挖矿`miner.start(1)`

### 运行节点1

1. 创建数据存放地址PrivateEtherNet/chain/01并初始化创世块，`./geth --datadir "../PrivateEtherNet/chain/01" init "../PrivateEtherNet/privateEtherBlock.json"`，创世区块的参数需与节点0相同，否则是两条链
2. 启动geth命令行`./geth --rpc --datadir "../PrivateEtherNet/chain/01" --rpcapi "db,eth,net,web3,personal" --networkid 95518 --port 61911 --rpcport 8101 console`，此处注意，默认的创建监听端口为30303，节点0监听端口即为30303，节点1需与其不同，若是不在同一服务器运行节点，则监听端口可相同；需注意节点0和节点1的networkid需相同才能保证在同一网络
3. 连接节点0`admin.addPeer("enode://429d21ba4915fa37b5d66e78bae48e82c76601306ae4cab2f0abebd5619f1ec02f10a216078b12fb71386adca122d7e4f124536738a0dee37137c1e3d2c9f840@222.73.203.10:30303")`
4. 创建账户`personal.newAccount("111111")`创建成功后显示`Block synchronisation started`节点1即开始同步块数据，表示两节点连接成功

在节点0的命令行中，输入命令`admin.peers`可查看连接到的其他节点信息，命令`net.peerCount`可以查看已连接到的节点数量。

## 6.发送一笔交易

1. 使用`sendTransaction`方法发送一笔ETH：

    ```bash
    from = web3.eth.accounts[0]
    to = web3.eth.accounts[1]
    transaction = { from: from, to: to, value: 100000 }
    transactionHash = web3.eth.sendTransaction(transaction)
    ```

2. 启动挖矿确认交易，挖到区块后停止
3. 查看交易信息`web3.eth.getTransaction(transactionHash)`