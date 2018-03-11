# 共享VPN学习资料

## 参考资料
- [xkcptun](xkcptun.md)
- [ShadowSocks](ShadowSocks.md)
- [NAT](NAT学习资料)

## 简单原理
内网穿透具有几种标准RFC方法，STUN协议/服务器可进行P2P的直连穿透，而TURN协议/服务器可作为中间人（relay）转发数据进行穿透，此时会消耗服务器资源。ICE协议包含了STUN/TURN，在使用STUN穿透失败的情况下，为了保证成功连接，使用TURN协议进行转发。我们项目中也使用ICE协议进行穿透。
穿透后的数据走向：
设备1(设备ip:源端口，dip1:sp1) 
<--> 路由器1(公网ip:映射端口，ip1:map1)
<--> Internet
<--> 路由器2(公网ip:映射端口，ip2:map2)
<--> 设备2(设备ip:源端口，dip2:sp2)
穿透后，设备1使用dip1:sp1与ip2:map2通信，设备2使用dip2:sp2与ip1:map1通信。双方ip、端口严格对应。
穿透的过程就是获取本机dipN:spN与对方ipN:mapN的过程。穿透可以同时支持多个端口对多个端口，但不支持多个端口对一个端口。

## PJNATH
跨平台ICE穿透库 PJNATH
属于PJSIP项目的一个子模块：
https://github.com/pjsip/pjproject/tree/master/pjnath
[文档](http://www.pjsip.org/pjnath/docs/html/)
[demo的详细说明](http://www.pjsip.org/pjnath/docs/html/ice_demo_sample.htm)



