# Stratum矿池协议说明

Stratum协议是目前最常见的矿机和矿池之间的TCP通讯协议。

## Stratum协议

### 1. 任务订阅

矿机启动，首先以`mining.subscribe`方法连接矿池，订阅任务。

```txt
{"id": 1, "method": "mining.subscribe", "params": ["cpuminer/2.5.0"]}
```

矿池以`mining.notify`返回订阅号、ExtraNoce1和ExtraNonce2_size。

```txt
{"id":1,"result":[["mining.notify","ae6812eb4cd7735a302a8a9dd95cf71f"],"08000002",4],"error":null}
```

其中：

```txt
ae6812eb4cd7735a302a8a9dd95cf71f -- 订阅号
08000002                         -- ExtraNonce1，用于构建coibase交易
4                                -- ExtraNonce2_size，矿机ExtraNonce2计数器的字节数
```

### 2. 任务分配

该命令由矿池定期发送给矿机，当矿机以`mining.subscribe`方法登记后，矿池马上以`mining.notify`返回该任务。

```txt
{
"params":
    ["bf","4d16b6f85af6e2198f44ae2a6de67f78487ae5611b77c6c0440b921e00000000", "01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff20020862062f503253482f04b8864e5008", "072f736c7573682f000000000100f2052a010000001976a914d23fcdf86f7e756a64a7a9688ef9903327048ed988ac00000000",
    ["c5bd77249e27c2d3a3602dd35c3364a7983900b64a34644d03b930bfdb19c0e5", "049b4e78e2d0b24f7c6a2856aa7b41811ed961ee52ae75527df9e80043fd2f12"],
    "00000002","1c2ac4af","504e86b9",false],
"id":null,
"method":"mining.notify"
}
```

```txt
"bf"       -------------------------------------------------------------------------------------------------------------------------------- 任务号
"01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff20020862062f503253482f04b8864e5008"                   -- coinbase第一部分
"072f736c7573682f000000000100f2052a010000001976a914d23fcdf86f7e756a64a7a9688ef9903327048ed988ac00000000"                                 -- coinbase第二部分
["c5bd77249e27c2d3a3602dd35c3364a7983900b64a34644d03b930bfdb19c0e5", "049b4e78e2d0b24f7c6a2856aa7b41811ed961ee52ae75527df9e80043fd2f12"] -- 交易ID列表
"00000002"                                                                                                                               -- 区块版本号
"1c2ac4af"                                                                                                                               -- nBit
"504e86b9" -------------------------------------------------------------------------------------------------------------------------------- 时间戳
false      -------------------------------------------------------------------------------------------------------------------------------- true表示发现新块，开始新任务
```

### 3. 矿机登录

矿机以`mining.authorize`方法，用帐号和密码登录到矿池，密码可空，矿池返回`true`登录成功。该方法必须在初始化连接之后马上进行，否则矿机得不到矿池任务。

```txt
Client:{"params":["miner1","password"],"id":2,"method":"mining.authorize"}

Server:{"error":null,"id":2,"result":true}
```

### 4. 结果提交

矿机找到合法share时，以`mining.submit`方法向矿池提交任务。矿池返回`true`即提交成功，失败则在error中显示错误。

```txt
Client:{"params":["miner1","bf","00000001","504e86ed","b2957c02"],"id":4,"method":"mining.submit"}

Server:{"error":null,"id":4,"result":true}
```

其中：

```txt
"miner1"   -- 矿工名
"bf"       -- 任务号
"00000001" -- ExtraNonce2
"504e86ed" -- 当前时间
"b2957c02" -- nonce
```

### 5. 难度调整

难度调整由矿池下发给矿机，以`mining.set_difficulty`方法调整难度，`params`中是难度值。

```txt
Server:{"id":null,"method":"mining.set_difficulty","params":[2]}
```

矿机会在下一个任务时采用新难度，矿池有时会马上下发一个新任务并把清理任务设为`true`，以便矿机马上开始新难度上的工作。