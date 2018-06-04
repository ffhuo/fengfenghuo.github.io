# Ethereum私有链智能合约部署

智能合约的部署需要搭建一条私有链并运行geth命令行，可参照[Ethereum私有链搭建](Ethereum私有链搭建.md)来实现。

## 下载以太坊钱包

下载对应版本的[以太坊钱包客户端](https://github.com/ethereum/mist/releases)

这里下载的是:

- [Windows版本 Ethereum-Wallet-win64-0-10-0.zip](https://github-production-release-asset-2e65be.s3.amazonaws.com/37201011/11884188-2d12-11e8-91c0-d0845ffcda1f?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20180409%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20180409T103332Z&X-Amz-Expires=300&X-Amz-Signature=31de6a74034d632a02e9c3e0c2099eb5ee7d03f9ee167fabd3be0ad2baaef30f&X-Amz-SignedHeaders=host&actor_id=13411145&response-content-disposition=attachment%3B%20filename%3DEthereum-Wallet-win64-0-10-0.zip&response-content-type=application%2Foctet-stream)

- [MacOS版本 Ethereum-Wallet-macosx-0-10-0.dmg](https://github-production-release-asset-2e65be.s3.amazonaws.com/37201011/945d1574-2d2c-11e8-9125-303224439687?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20180409%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20180409T070247Z&X-Amz-Expires=300&X-Amz-Signature=fa680bc86cebaa9164851671ff32b15b9b819e2b4a56f84f98a2c5c08a7304b4&X-Amz-SignedHeaders=host&actor_id=13411145&response-content-disposition=attachment%3B%20filename%3DEthereum-Wallet-macosx-0-10-0.dmg&response-content-type=application%2Foctet-stream)

## 使用以太坊钱包部署智能合约

以太坊钱包的运行需要连接到当前运行的私有链节点上，geth命令行运行成功后找到`IPC endpoint opened`，这里Windows环境下是`url=\\\\.\\pipe\\geth.ipc`，MacOS环境下是`url=/Users/drowgames/workspace/GoWork/PrivateEtherNet/chain/00/geth.ipc`

部署智能合约需要消耗燃料，所以需要账户中有足够数量的以太币，需先挖矿获得一定数量以太币。

### Windows环境启动钱包客户端

命令行当前目录为以太坊客户端.exe同目录下，运行`./Ethereum\ Wallet.exe --rpc \\\\.\\pipe\\geth.ipc`

### MacOS环境启动钱包客户端

MacOS下通过.dmg安装的钱包可通过命令`/Applications/Ethereum\ Wallet.app/Contents/MacOS/Ethereum\ Wallet --rpc /Users/drowgames/workspace/GoWork/PrivateEtherNet/chain/00/geth.ipc`打开

### 部署智能合约

如图：

![Ethereum钱包](media/Ethereum私有链智能合约部署-Ethereum钱包.png)

右上角显示PRIVATE-NET表示连接的是私有链，若没有此标记则连接了以太坊公链。

点击“LAUNCH APPLICATION”进入钱包主界面，

按下面步骤进行：

![Ethereum创建合约](media/Ethereum私有链智能合约部署-Ethereum创建合约.png)

![Ethereum新建](media/Ethereum私有链智能合约部署-Ethereum新建.png)

选择一个有足够以太币的账户来新建一个智能合约，在代码区填入以下代码：

![Ethereum合约代码](media/Ethereum私有链智能合约部署-Ethereum合约代码.png)

```solidity
pragma solidity ^0.4.18;

contract SimpleStorage {
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function get() public constant returns (uint) {
        return storedData;
    }
}
```

代码无误则右侧区域会显示当前合约，选择一个条目

![Ethereum选择合约](media/Ethereum私有链智能合约部署-Ethereum选择合约.png)

支付所需费用

![Ethereum支付费用](media/Ethereum私有链智能合约部署-Ethereum支付费用.png)

即创建了一条智能合约，此时合约还未生效，需要挖到一定块后合约确认。

合约确认后查看该合约

![Ethereum查看合约](media/Ethereum私有链智能合约部署-Ethereum查看合约.png)

点击进入合约页

![Ethereum合约详情](media/Ethereum私有链智能合约部署-Ethereum合约详情.png)

选择一个功能，这里这条合约的作用就是设置一个数值。查看合约是不收取费用的。

## Geth JavaScript console部署智能合约

geth JavaScript命令行中是不能直接运行Solidity语言源码的，需要经过编译，得到的编译码可用于部署合约。

给出参考源码：

```txt
pragma solidity ^0.4.18;
contract hello {
    string greeting;

    function hello(string _greeting) public {
        greeting = _greeting;
    }

    function say() constant public returns (string) {
        return greeting;
    }
}
```

关于编译Solidity语言，可通过官方提供的浏览器[Browser-Solidity](https://ethereum.github.io/browser-solidity/#optimize=false&version=soljson-v0.4.21+commit.dfe3193c.js)进行

![solidity编译1](media/Ethereum私有链智能合约部署-solidity编译1.png)
![solidity编译2](media/Ethereum私有链智能合约部署-solidity编译2.png)

Browser-Solidity生成的代码，拷贝到编辑器里修改后的代码如下：

```txt
var _greeting = Hello World ;
var helloContract = web3.eth.contract([{"constant":true,"inputs":[],"name":"say","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_greeting","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]);
var hello = helloContract.new(
   _greeting,
   {
     from: web3.eth.accounts[0],
     data: '0x6060604052341561000f57600080fd5b6040516102b83803806102b8833981016040528080518201919050508060009080519060200190610041929190610048565b50506100ed565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061008957805160ff19168380011785556100b7565b828001600101855582156100b7579182015b828111156100b657825182559160200191906001019061009b565b5b5090506100c491906100c8565b5090565b6100ea91905b808211156100e65760008160009055506001016100ce565b5090565b90565b6101bc806100fc6000396000f300606060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063954ab4b214610046575b600080fd5b341561005157600080fd5b6100596100d4565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561009957808201518184015260208101905061007e565b50505050905090810190601f1680156100c65780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6100dc61017c565b60008054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156101725780601f1061014757610100808354040283529160200191610172565b820191906000526020600020905b81548152906001019060200180831161015557829003601f168201915b5050505050905090565b6020604051908101604052806000815250905600a165627a7a72305820e7bee58cd04d8ca354929dae8d532de4844d3f4f962ac3f3d29319457dc40ab30029',
     gas: '300000'
   }, function (e, contract){
    console.log(e, contract);
    if (typeof contract.address !== 'undefined') {
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 });
```

拷贝回geth控制台里，Windows环境VSCode下无法拷贝，这里环境是MacOS，回车后，看到输出如：

```txt
Submitted contract creation              fullhash=0x7171ceb8fe1a16a548573eb1ec84454b24f920b72af9c907622728358ac4a286 contract=0x1D13d659decA75A87c40b025DDfBe99025aC62f1
null [object Object]
undefined
```

开始挖矿`miner.start(1)`，合约确认后会输出：

```txt
Contract mined! address: 0x1d13d659deca75a87c40b025ddfbe99025ac62f1 transactionHash: 0x7171ceb8fe1a16a548573eb1ec84454b24f920b72af9c907622728358ac4a286
```

表示智能合约已经部署成功。停止挖矿`miner.stop()`，运行智能合约`hello.say()`，输出`"Hello World"`，输入`hello`，输出：

```txt
{
  abi: [{
      constant: true,
      inputs: [],
      name: "say",
      outputs: [{...}],
      payable: false,
      stateMutability: "view",
      type: "function"
  }, {
      inputs: [{...}],
      payable: false,
      stateMutability: "nonpayable",
      type: "constructor"
  }],
  address: "0x1d13d659deca75a87c40b025ddfbe99025ac62f1",
  transactionHash: "0x7171ceb8fe1a16a548573eb1ec84454b24f920b72af9c907622728358ac4a286",
  allEvents: function(),
  say: function()
}
```

### 遇到的几个错误说明

1. `Error: authentication needed: password or unlock undefined`，账户未解锁，初始账户处于锁定状态，需要先执行`personal.unlockAccount(eth.accounts[0])`解锁当前账户
2. `Error: exceeds block gas limit undefined`，消耗的gas量值太大，将默认的`gas: '4700000'`值改小即可

- 可参考官网详细信息：<https://ethereum.org/token>
- 智能合约概述：<http://solidity-cn.readthedocs.io/zh/develop/introduction-to-smart-contracts.html#>
- 智能合约开发环境搭建及Hello World合约：<https://learnblockchain.cn/2017/11/24/init-env/>
