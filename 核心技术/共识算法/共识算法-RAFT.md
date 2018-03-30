# RAFT

## 概要
RAFT核心思想很容易理解，如果数个数据库，初始状态一致，只要之后的进行的操作一致，就能保证之后的数据一致。由此RAFT使用的是Log进行同步，并且将服务器分为三中角色：Leader，Follower，Candidate，相互可以互相转换。
RAFT从大的角度看，分为两个过程：

1. 选举Leader
2. Leader生成Log，并与Follower进行Headbeats同步

### 选举Leader

Follower自增当前任期，转换为Candidate，对自己投票，并发起RequestVote RPC，等待下面三种情形发生；

1. 获得超过半数服务器的投票，赢得选举，成为Leader
2. 另一台服务器赢得选举，并接收到对应的心跳，成为Follower
3. 选举超时，没有任何一台服务器赢得选举，自增当前任期，重新发起选举

### 同步日志

Leader接受客户端请求，Leader更新日志，并向所有Follower发送Heatbeats，同步日志。所有Follwer都有ElectionTimeout，如果在ElectionTimeout时间之内，没有收到Leader的Headbeats，则认为Leader失效，重新选举Leader

流程图示：
![同步日志流程图示](media/共识算法-RAFT-同步日志流程图示.png)

### 安全性保证

1. 日志的流向只有Leader到Follower，并且Leader不能覆盖日志
2. 日志不是最新者不能成为Candidate

[画演示RAFT](http://thesecretlivesofdata.com/raft/)
