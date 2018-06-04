# ERC20标准

## 什么是ERC20 token

市面上出现了大量的用ETH做的代币，他们都遵守REC20协议，那么我们需要知道什么是REC20协议。

## 概述

token代表数字资产，具有价值，但是并不是都符合特定的规范。

基于ERC20的货币更容易互换，并且能够在Dapps上相同的工作。

新的标准可以让token更兼容，允许其他功能，包括投票标记化。操作更像一个投票操作

Token的持有人可以完全控制资产，遵守ERC20的token可以跟踪任何人在任何时间拥有多少token.基于eth合约的子货币，所以容易实施。只能自己去转让。

标准化非常有利，也就意味着这些资产可以用于不同的平台和项目，否则只能用在特定的场合。

## ERC20 Token标准(Github)

### 序言

> EIP: 20
> Title: ERC-20 Token Standard
> Author: Fabian Vogelsteller fabian@ethereum.org, Vitalik Buterin vitalik.buterin@ethereum.org
> Type: Standard
> Category: ERC
> Status: Accepted
> Created: 2015-11-19

### 总结

token的接口标准

### 抽象

以下标准允许在智能合约中实施标记的标记API。 该标准提供了转移token的基本功能，并允许token被批准，以便他们可以由另一个在线第三方使用。

### 动机

标准接口可以让Ethereum上的任何令牌被其他应用程序重新使用：从钱包到分散式交换。

### 规则

#### Token

##### 方法

注意：调用者必须处理返回`false`的`returns (bool success)`.调用者绝对不能假设返回`false`的情况不存在。

###### name

返回这个令牌的名字，比如`"MyToken"`.

可选 - 这种方法可以用来提高可用性，但接口和其他契约不能指望这些值存在。

```solidity
function name() constant returns (string name)
```

###### symbol

返回令牌的符号，比如`HIX`.

可选 - 这种方法可以用来提高可用性，但接口和其他契约不能指望这些值存在。

```solidity
function symbol() constant returns (string symbol)
```

###### decimals

返回token使用的小数点后几位， 比如 8,表示分配token数量为100000000

可选 - 这种方法可以用来提高可用性，但接口和其他契约不能指望这些值存在。

```solidity
function decimals() constant returns (uint8 decimals)
```

###### totalSupply

返回token的总供应量。

```solidity
function totalSupply() constant returns (uint256 totalSupply)
```

###### balanceOf

返回地址是`_owner`的账户的账户余额。

```solidity
function balanceOf(address _owner) constant returns (uint256 balance)
```

###### transfer

转移`_value`的token数量到的地址`_to`，并且必须触发`Transfer`事件。 如果`_from`帐户余额没有足够的令牌来支出，该函数应该被`throw`。

创建新令牌的令牌合同应该在创建令牌时将`_from`地址设置为`0x0`触发传输事件。

注意 0值的传输必须被视为正常传输并触发传输事件。

```solidity
function transfer(address _to, uint256 _value) returns (bool success)
```

###### transferFrom

从地址`_from`发送数量为`_value`的token到地址`_to`,必须触发`Transfer`事件。

`transferFrom`方法用于提取工作流，允许合同代您转移token。这可以用于例如允许合约代您转让代币和/或以子货币收取费用。除了`_from`帐户已经通过某种机制故意地授权消息的发送者之外，该函数**应该**`throw`。

注意 0值的传输必须被视为正常传输并触发传输事件。

```solidity
function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
```

###### approve

允许`_spender`多次取回您的帐户，最高达`_value`金额。 如果再次调用此函数，它将以`_value`覆盖当前的余量。

注意：为了阻止向量攻击，客户端需要确认以这样的方式创建用户接口，即将它们设置为0，然后将其设置为同一个花费者的另一个值。虽然合同本身不应该强制执行，允许向后兼容以前部署的合同兼容性

```solidity
function approve(address _spender, uint256 _value) returns (bool success)
```

###### allowance

返回`_spender`仍然被允许从`_owner`提取的金额。

```solidity
function allowance(address _owner, address _spender) constant returns (uint256 remaining)
```

#### Events

##### 方法

###### Transfer

当token被转移(包括0值)，必须被触发。

```solidity
event Transfer(address indexed _from, address indexed _to, uint256 _value)
```

###### Approval

当任何成功调用`approve(address _spender, uint256 _value)`后，必须被触发。

```solidity
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

### 实施

在Ethereum网络上部署了大量符合ERC20标准的令牌。 具有不同权衡的各种团队已经编写了不同的实施方案：从节省gas到提高安全性。

示例实现可在:

- <https://github.com/ConsenSys/Tokens/tree/master/contracts/eip20>
- <https://github.com/OpenZeppelin/openzeppelin-solidity/tree/master/contracts/token/ERC20>

在调用之前添加力0的实施“批准”了:

- <https://github.com/Giveth/minime/blob/master/contracts/MiniMeToken.sol>

### ERC20 Token标准接口

以下是一个接口合同，声明所需的功能和事件以符合ERC20标准：

```solidity
// https://github.com/ethereum/EIPs/issues/20
  contract ERC20 {
      function totalSupply() constant returns (uint totalSupply);
      function balanceOf(address _owner) constant returns (uint balance);
      function transfer(address _to, uint _value) returns (bool success);
      function transferFrom(address _from, address _to, uint _value) returns (bool success);
      function approve(address _spender, uint _value) returns (bool success);
      function allowance(address _owner, address _spender) constant returns (uint remaining);
      event Transfer(address indexed _from, address indexed _to, uint _value);
      event Approval(address indexed _owner, address indexed _spender, uint _value);
    }
```

大部分Ethereum主要标记符合ERC20标准。

一些令牌包括描述令牌合同的进一步信息：

```solidity
string public constant name = "Token Name";
string public constant symbol = "SYM";
uint8 public constant decimals = 18;  // 大部分都是18
```

### 如何工作？

以下是令牌合约的一个片段，用于演示令牌合约如何维护Ethereum帐户的令牌余额

```solidity
contract TokenContractFragment {

     // Balances 保存地址的余额
     mapping(address => uint256) balances;

     // 帐户的所有者批准将金额转入另一个帐户
     mapping(address => mapping (address => uint256)) allowed;

      // 特定帐户的余额是多少？
      function balanceOf(address _owner) constant returns (uint256 balance) {
          return balances[_owner]; //从数组中取值
      }

      // 将余额从所有者帐户转移到另一个帐户
      function transfer(address _to, uint256 _amount) returns (bool success) {
          //判断条件 发送者余额>=要发送的值  发送的值>0  接收者余额+发送的值>接收者的余额
          if (balances[msg.sender] >= _amount 
              && _amount > 0
              && balances[_to] + _amount > balances[_to]) {
              balances[msg.sender] -= _amount;   //发送者的余额减少
              balances[_to] += _amount;         //接收者的余额增加
              return true;
         } else {
              return false;
          }
      }

      // 发送 _value 数量的token从地址 _from 到 地址 _to
      // transferFrom方法用于提取工作流程，允许合同以您的名义发送令牌，例如“存入”到合同地址和/或以子货币收取费用; 该命令应该失败，除非_from帐户通过某种机制故意地授权消息的发送者; 我们提出这些标准化的API来批准：
      function transferFrom(
          address _from,
          address _to,
          uint256 _amount
     ) returns (bool success) {
          //和上面一样的校验规则
          if (balances[_from] >= _amount
              && allowed[_from][msg.sender] >= _amount
              && _amount > 0
              && balances[_to] + _amount > balances[_to]) {
              balances[_from] -= _amount;
              allowed[_from][msg.sender] -= _amount; //减少发送者的批准量
              balances[_to] += _amount;
              return true;
         } else {
             return false;
          }
      }

      // 允许_spender多次退出您的帐户，直到_value金额。 如果再次调用此函数，它将以_value覆盖当前的余量。
      function approve(address _spender, uint256 _amount) returns (bool success) {
          allowed[msg.sender][_spender] = _amount; //覆盖当前余量
          return true;
      }
  }
```

#### token余额

假设token合约内有两个持有者

- 0x1111111111111111111111111111111111111111有100个单位
- 0x2222222222222222222222222222222222222222有200个单位

那么这个合约的balances结构就会存储下面的内容

```solidity
balances[0x1111111111111111111111111111111111111111] = 100
balances[0x2222222222222222222222222222222222222222] = 200
```

那么，balanceOf(...)就会返回下面的结果

```solidity
tokenContract.balanceOf(0x1111111111111111111111111111111111111111) 将会返回 100
tokenContract.balanceOf(0x2222222222222222222222222222222222222222) 将会返回 200
```

#### 转移token的余额

如果`0x1111111111111111111111111111111111111111`想要转移10个单位给`0x2222222222222222222222222222222222222222`,那么`0x1111111111111111111111111111111111111111`会执行下面的函数

```solidity
tokenContract.transfer(0x2222222222222222222222222222222222222222, 10)
```

token合约的`transfer(...)`方法将会改变`balances`结构中的信息

```solidity
balances[0x1111111111111111111111111111111111111111] = 90
balances[0x2222222222222222222222222222222222222222] = 210
```

`balanceOf(...)`调用就会返回下面的信息

```solidity
tokenContract.balanceOf(0x1111111111111111111111111111111111111111) 将会返回 90
tokenContract.balanceOf(0x2222222222222222222222222222222222222222) 将会返回 210
```

#### 从token余额批准和转移

如果`0x1111111111111111111111111111111111111111`想要批准`0x2222222222222222222222222222222222222222`传输一些token到`0x2222222222222222222222222222222222222222`,那么`0x1111111111111111111111111111111111111111`会执行下面的函数

```solidity
tokenContract.approve(0x2222222222222222222222222222222222222222, 30)
```

然后`allowed`(这里官方文档写的是approve，很明显是错的)结构就会存储下面的内容

```solidity
tokenContract.allowed[0x1111111111111111111111111111111111111111][0x2222222222222222222222222222222222222222] = 30
```

如果`0x2222222222222222222222222222222222222222`想要晚点转移token从`0x1111111111111111111111111111111111111111`到他自己，`0x2222222222222222222222222222222222222222`将要执行`transferFrom(...)`函数

```solidity
tokenContract.transferFrom(0x1111111111111111111111111111111111111111, 20)
```

`balances`的信息就会变成下面的

```solidity
tokenContract.balances[0x1111111111111111111111111111111111111111] = 70
tokenContract.balances[0x2222222222222222222222222222222222222222] = 230
```

然后`allowed`就会变成下面的内容

```solidity
tokenContract.allowed[0x1111111111111111111111111111111111111111][0x2222222222222222222222222222222222222222] = 10
```

`0x2222222222222222222222222222222222222222`仍然可以从`0x1111111111111111111111111111111111111111`转移10个单位。

```solidity
tokenContract.balanceOf(0x1111111111111111111111111111111111111111) will return 70
tokenContract.balanceOf(0x2222222222222222222222222222222222222222) will return 230
```

### 简单修复的token合约

以下是一个样本令牌合同，固定供应量为1000000单位，最初分配给合同所有者：

```solidity
pragma solidity ^0.4.8;

  // ----------------------------------------------------------------------------------------------
  // Sample fixed supply token contract
  // Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
  // ----------------------------------------------------------------------------------------------

   // ERC Token Standard #20 Interface
  // https://github.com/ethereum/EIPs/issues/20
  contract ERC20Interface {
      // 获取总的支持量
      function totalSupply() constant returns (uint256 totalSupply);

      // 获取其他地址的余额
      function balanceOf(address _owner) constant returns (uint256 balance);

      // 向其他地址发送token
      function transfer(address _to, uint256 _value) returns (bool success);

      // 从一个地址想另一个地址发送余额
      function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

      //允许_spender从你的账户转出_value的余额，调用多次会覆盖可用量。某些DEX功能需要此功能
      function approve(address _spender, uint256 _value) returns (bool success);

      // 返回_spender仍然允许从_owner退出的余额数量
      function allowance(address _owner, address _spender) constant returns (uint256 remaining);

      // token转移完成后出发
      event Transfer(address indexed _from, address indexed _to, uint256 _value);

      // approve(address _spender, uint256 _value)调用后触发
      event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  }

   //继承接口后的实例
   contract FixedSupplyToken is ERC20Interface {
      string public constant symbol = "FIXED"; //单位
      string public constant name = "Example Fixed Supply Token"; //名称
      uint8 public constant decimals = 18; //小数点后的位数
      uint256 _totalSupply = 1000000; //发行总量

      // 智能合约的所有者
      address public owner;

      // 每个账户的余额
      mapping(address => uint256) balances;

      // 帐户的所有者批准将金额转入另一个帐户。从上面的说明我们可以得知allowed[被转移的账户][转移钱的账户]
      mapping(address => mapping (address => uint256)) allowed;

      // 只能通过智能合约的所有者才能调用的方法
      modifier onlyOwner() {
          if (msg.sender != owner) {
              throw;
          }
          _;
      }

      // 构造函数
      function FixedSupplyToken() {
          owner = msg.sender;
          balances[owner] = _totalSupply;
      }

      function totalSupply() constant returns (uint256 totalSupply) {
          totalSupply = _totalSupply;
      }

      // 特定账户的余额
      function balanceOf(address _owner) constant returns (uint256 balance) {
          return balances[_owner];
      }

      // 转移余额到其他账户
      function transfer(address _to, uint256 _amount) returns (bool success) {
          if (balances[msg.sender] >= _amount 
              && _amount > 0
              && balances[_to] + _amount > balances[_to]) {
              balances[msg.sender] -= _amount;
              balances[_to] += _amount;
              Transfer(msg.sender, _to, _amount);
              return true;
          } else {
              return false;
          }
      }

      //从一个账户转移到另一个账户，前提是需要有允许转移的余额
      function transferFrom(
          address _from,
          address _to,
          uint256 _amount
      ) returns (bool success) {
          if (balances[_from] >= _amount
              && allowed[_from][msg.sender] >= _amount
              && _amount > 0
              && balances[_to] + _amount > balances[_to]) {
              balances[_from] -= _amount;
              allowed[_from][msg.sender] -= _amount;
              balances[_to] += _amount;
              Transfer(_from, _to, _amount);
              return true;
          } else {
              return false;
          }
      }

      //允许账户从当前用户转移余额到那个账户，多次调用会覆盖
      function approve(address _spender, uint256 _amount) returns (bool success) {
          allowed[msg.sender][_spender] = _amount;
          Approval(msg.sender, _spender, _amount);
          return true;
      }

      //返回被允许转移的余额数量
      function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
      }
  }
```

注意的是，最后的例子中allowed限定的第二维的参数是调用者的转移数量，而开始的例子是接收者的数量。

## 参考资料

- <http://themerkle.com/what-is-the-erc20-ethereum-token-standard/>
- <https://github.com/ethereum/EIPs/pull/610>
- <https://github.com/ethereum/EIPs/issues/20>
- <https://theethereum.wiki/w/index.php/ERC20_Token_Standard>
- <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md>
- <https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729>
- <https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#heading=h.m9fhqynw2xvt>