# 以太坊ERC20代币交易数据解析

## 交易数据解析

通过钱包的以太坊代币交易实质上是发送到代币智能合约的一条消息。

当识别到这是一次代币交易，钱包默认会将`_to`地址转换成代币合约地址。gas消耗计算、gas价格等与普通交易相同，但因为要发送到合约地址并调用合约函数修改数据所以gas消耗量要比普通交易多些。

在确认交易的PARAMETERS信息中，显示的是`_to`地址以及交易数额。

点击SHOW RAW DATA后显示的是方法+`_to`地址+交易数额的转换数据。

给出普通以太币交易和代币交易的一组数据：

```txt
//代币交易
{
  blockHash: "0x54cb79280c490aa4c4f161fab1a41ebfe4c7bdc25e6442d691dce04647ee283d",
  blockNumber: 751,
  from: "0x01939207f2216fb448be34dc3d74c9da9efc2adc",
  gas: 151975,
  gasPrice: 18000000000,
  hash: "0xee1eb347736907b12705db30b64a186e7c2f96fa26f315d4cf99206e26fbe4af",
  input: "0xa9059cbb000000000000000000000000cb3b3511d3b5033e3ff4f3ef7d516d3f6657df570000000000000000000000000000000000000000000000056bc75e2d63100000",
  nonce: 11,
  r: "0xdb9a7ac3c0a80c7b7640ef88ef8555892ad7e5bdcb18e2eaad7bf8747b929d64",
  s: "0x2b871ed35f4d0bbc96f0149502944e420159b98903d18073217e7c9eb8bc39ab",
  to: "0x09688fbfb91bce0ce8538e1abb46aa9758c57628",
  transactionIndex: 0,
  v: "0x38",
  value: 0
}
//以太币交易
{
  blockHash: "0xa446d7c06d283e3c39f9ad8be43f4a50ddf899633469c7fd9e70f53b12677ba1",
  blockNumber: 99,
  from: "0x01939207f2216fb448be34dc3d74c9da9efc2adc",
  gas: 121000,
  gasPrice: 18000000000,
  hash: "0x9d4f356d8ff342e8db9a038010cfe20596fc877894a2eb34080d97afe40806cf",
  input: "0x",
  nonce: 3,
  r: "0xb2321431dc1346209d629266d5880d3874a66ade7f199fe2f376b815a353b8a2",
  s: "0x165016d0a29caf38d9816b2ca57607f0a2905955306d9ba7d509273231e3f9c1",
  to: "0x7f1da592485780e207a170c242e59b6497f14761",
  transactionIndex: 0,
  v: "0x38",
  value: 100000000000000000000
}
```

首先解释下各个字段含义：

- blockHash        -- 交易所在区块的区块hash值
- blockNumber      -- 交易所在区块的区块序号
- from             -- 交易发起者地址
- gas              -- 交易消耗gas
- gasPrice         -- 交易消耗gas当前价格
- hash             -- 交易的hash值
- input            -- 交易携带数据
- nonce            -- 发送地址的交易次数
- r                -- 交易签名数据
- s                -- 交易签名数据
- to               -- 交易接收方地址
- transactionIndex -- 交易所在区块的交易序号
- v                -- 交易签名数据
- value            -- 交易金额数值

以太币交易与代币交易最大的区别在于`value`和`input`字段，代币交易`value`字段为0，以太币交易`input`字段为空。

## 代币交易的`input`字段

`input`是一个136位的十六进制字符串，该字段由三部分组成，方法、地址和交易金额。

### 方法

8位16进制方法ID，取了合约方法的SHA3散列哈希的前4字节

例如：
交易方法`transfer(address,uint256)`的SHA3哈希值是`A9059CBB2AB09EB219583F4A59A5D0623ADE346D962BCD4E46B11DA047C9049B [qQWcuyqwnrIZWD9KWaXQYjreNG2WK81ORrEdoEfJBJs=]`
取前4字节8位，即`A9059CBB`

### 地址

64位16进制地址，交易接收方的地址，高位补0

### 交易金额

64位16进制字符串，是交易金额（最小单位下）十进制转为十六进制的结果。

## web3获取交易信息方法

- `web3.eth.getBlock(number or hash)`获取区块信息，参数为区块序号或区块hash，不填参数返回默认区块，返回区块object
- `web3.eth.getBlockTransactionCount(number or hash)`获取区块包含交易数，参数为区块序号或区块hash，返回数值
- `web3.eth.getTransaction(hash)`获取交易信息，参数为交易哈希，返回交易object
- `web3.eth.getTransactionFromBlock(hash or number, indexNumber)`获取区块上的第indexNumber个交易，参数为区块序号或区块hash以及交易序号，返回交易object

## 代币区块浏览器实现方法

1. 发布代币，记录当前区块hash或区块序号以及代币地址
2. 获取当前区块号
3. 遍历代币初始区块到当前区块号的所有区块信息，主要为区块时间、交易hash，根据交易hash查询到交易具体信息，主要为交易发起方地址、交易接收方地址（即合约地址，可通过此项筛选该代币交易）、input字段信息等，并解析input字段
4. 保存信息到数据库