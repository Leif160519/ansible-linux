## Moosefs+keepalived 高可用开源分布式文件系统(基本型)
[官方安装教程][1]

docker 部署moosefs集群: [leif160519/docker-script/moosefs][5]

## 1.集群组成
- 10.1.2.140 虚拟ip
- 10.1.2.141 master节点
- 10.1.2.142 metalogger节点(可接替master节点)
- 10.1.2.(151-153) chunkserver节点(1-3)
- /mnt/mfs(1-2) 底层存储盘
- /mnt/mfs 挂载点

## 2.注意
`/mnt/mfs1`和`/mnt/mfs2`最好使用单独挂载的硬盘而非单纯的文件夹已保证最佳性能

## 3.mfs灾难恢复
> [MooseFS超实用手册（6）--性能、灾难测试及总结][4]

## 3.1 机器关机，重启不用修复
matser、metalogger、chunker、client端，服务器关机（init0）和重启（init6）时，程序都是正常关闭，无需修复。

## 3.2 启动顺序
master启动后，metalogger、chunker、client三个元素都能自动与master建立连接。
正常启动顺序：matser---chunker---metalogger---client
关闭顺序：client---chunker---metalogger---master
但实际中无论如何顺序启动或关闭，未见任何异常。

## 3.3 mfs master恢复
- mfsmaster主机还能开机并访问
  一旦mfsmaster崩溃(突然断电引起的关机),需要将最后一个元数据changelog加载metadata中，则使用`mfsmetarestore -a`，之后运行`mfsmaster -a`启动master即可恢复集群

- mfsmaster主机不能开机
  如果mfsmaster主机不能开机或者正常访问了，则需要将metalogger服务器变为master或者使用新机器重建mfsmaster，这时候`keepalived`的作用就体现出来了，虚机ip能保证无论mfs集群的master ip是什么，对客户端的挂载地址始终是统一的
  a). 将metalogger变为master: 在metalogger上安装moosefs-master服务，在`/var/lib/mfs`中执行`mfsmetarestore -a`，最后启动`moosefs-master`服务即可启动集群，这也是最快的能恢复mfs集群的方法
  b). 重建mfsmaster:创建一台新机器，安装好`moosefs-master`和`keepalived`服务，将metalogger机器上的`/var/lib/mfs`内容全部复制到新创建的mfsmaster机器的对应路径下，接着停止metalogger上的keepalived服务，最后在mfsmaster上执行`mfsmetarestore -a`和`mfsmaster -a`启动集群

## 参考
- [MFS(二)---mfs使用 数据恢复 StorageClass详解][2]
- [Centos下MooseFS（MFS）分布式存储共享环境部署记录][3]

[1]: https://moosefs.com/download/
[2]: https://blog.csdn.net/qq_35887546/article/details/106973960
[3]: https://www.cnblogs.com/kevingrace/p/5707164.html
[4]: https://blog.51cto.com/u_15127621/2770922
[5]: https://github.com/Leif160519/docker-script/tree/master/moosefs
