# 安装和使用bitcoind
[TOC]

## 安装bitcoind

### 从源代码安装

```bash
brew install autoconf
brew install automake
brew install berkeley-db@4
brew install boost
brew install libevent

cd bitcoin
./autogen.sh
./configure
make
make install
```

### Mac从brew直接安装

```bash
brew install bitcoin
```

### Ubuntu通过源安装

中午参考文档: <https://steemit.com/cn-007/@speeding/bitcoin-miner-pool>
参考文档: <https://github.com/UNOMP/unified-node-open-mining-portal>

```bash
apt-get update
apt-get install software-properties-common 
add-apt-repository ppa:bitcoin/bitcoin
apt-get update
apt-get install bitcoind
```

## 启动bitcoind

配置文件路径 
- mac: `$HOME/Library/Application Support/Bitcoin
- linux: ~/.bitcoin

```txt
rpcuser=xxxxxxxx
rpcpassword=xxxxxxxxxxxxxxxxxxxxxxxx
onlynet=ipv4
server=1
rest=1
```

启动命令

```bash
bitcoind -daemon
```


