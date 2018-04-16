# ShadowSocks
## 概况
[仓库地址](https://github.com/shadowsocks/shadowsocks-libev)
客户端：ss-local
服务端：ss-server
客户端与服务端均支持多平台，x86版可运行于Linux PC，arm版可运行于手机。

## 运行流程：
./ss-local -s 服务端ip -p 服务端端口 -k 密码 -m aes-256-cfb
./ss-server -s 0.0.0.0 -p 服务端端口 -k 密码 -m aes-256-cfb

ss-local可使用-b 0.0.0.0参数以及-l [port]参数指定一个本地端口作为公共代理（socks4/5协议），同一局域网的其他PC/手机设备上的应用程序将ss-local IP/端口设置成代理服务器后，即可通过ss上网。利用这个特性可以方便在PC上调试。
网上也有大量的ss源码分析可供参考。

ss普通运行流程：
Android APP
<--TCP/UDP--> Android VPNService
<--TCP/UDP--> ss中间件
<--> ss-local
<--TCP/UDP包装为TCP--> ss-server
<--> Internet

ss结合[xkcptun](xkcptun.md)后：
Android APP
<--TCP/UDP--> Android VPNService
<--TCP/UDP--> ss中间件
<--> ss-local
<--TCP--> xkcp_client
<--UDP--> xkcp_server
<--TCP--> ss-server
<--> Internet

ss-local将服务端ip设置为本机xkcp_client的监听端口，由xkcp_client将数据发送给远端xkcp_server处理。
引入穿透的情况下，xkcp_client需要使用穿透后的本机端口与目标端口进行通信。

ss-local同时支持TCP/UDP转发为TCP传输，但由于xkcptun只能监听TCP并将TCP转发为UDP，所以此时ss-local必须设置成TCP工作模式，只转发TCP，其他UDP数据不经过ss-server，而是直连。


