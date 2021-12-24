## Moosefs+keepalived 高可用开源分布式文件系统(基本型)
[官方安装教程][1]

## 集群组成
- 10.1.27.140 虚拟ip
- 10.1.27.141 master节点
- 10.1.27.142 metalogger节点
- 10.1.27.(151-153) chunkserver节点(1-3)
- /mnt/mfs(1-2) 底层存储盘
- /mnt/mfs 挂载点

## 注意
确保`/mnt/mfs1`和`/mnt/mfs2`提前存在,且最好使用单独挂载的硬盘而非单纯的文件夹

## 参考
- [MFS(二)---mfs使用 数据恢复 StorageClass详解][2]
- [Centos下MooseFS（MFS）分布式存储共享环境部署记录][3]

[1]: https://moosefs.com/download/
[2]: https://blog.csdn.net/qq_35887546/article/details/106973960
[3]: https://www.cnblogs.com/kevingrace/p/5707164.html
