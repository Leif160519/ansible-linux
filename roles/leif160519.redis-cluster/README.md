## Ansible install redis cluster

## redis配置文件详解

| 参数 | 值 | 解释 |
|------|----|------|
| port  | 6379 | 端口号 |
| daemonize | yes | 以后台模式运行 |
| protected-mode | no   | 集群模式下要设置成no，设置为yes的时候需要配合bind参数，只有被bind的ip能访问我们的redis |
| requirepass | 123456 | redis密码 |
| dir | /opt/redis/data | 日志、aof、rdb文件都会保存到这里 所以这个路径要是机器磁盘空间最大的（可通过df –h来获取磁盘信息）|
| logfile | redis-6379.log  | 产生的日志名 |
| loglevel | notice |日志级别（用于生产环境）|
| timeout | 1800    | 在客户端空闲多久后关闭连接，单位为秒。0表示永不关闭，这里的值必须大于客户端设置的连接池的最小空闲时间 |
| tcp-keepalive | 0 | 0表示在没有通信的情况下，不会向客户端发送TCP ACK来检测客户端是否被关闭，因为在客户端有空闲检测，所以服务端没必要去检测客户端的状态 |
| maxmemory | 4gb   | redis最多能用多少内存，如果不设置的话，redis会一直消耗完系统所有的内存 |
| maxmemory-policy | volatile-lfu    | redis达到maxmemory后的内存回收策略，lfu比lru性能更好 |
| lfu-log-factor | 10 | |
| lfu-decay-time | 1 | |
| dbfilename | redis-6379.rdb | 产生的rdb文件名 |
| rdbcompression | yes  | 开启rdb文件压缩 |
| stop-writes-on-bgsave-error | yes  | bgsave错误的时候停止写操作来保证bgsave成功 |
| rdbchecksum | yes | 检测rdb文件的完整性 |
| appendonly | yes  | 开启aof，建议主节点关闭，从节点开启 |
| appendfsync | everysec  | aof刷盘策略 |
| auto-aof-rewrite-min-size | 64mb  | 当aof文件多大的时候才进行重写 |
| auto-aof-rewrite-percentage | 100 | aof增长率 |
| no-appendfsync-on-rewrite | yes   | 在aof重写的时候时候不进行正常的aof |
| appendfilename | redis-6379.aof  | 产生的aof文件名 |
| hash-max-ziplist-entries | 512 | 当hash的大小小于512个，并且每个值都小于64byte时，就使用ziplist存储 |
| hash-max-ziplist-value | 64 | |
| list-max-ziplist-size | -2 | 这里的-2是指zipList的长度8kb，超出了这个字节数，就会新起一个ziplist |
| list-compress-depth | 0 | 压缩深度为0，表示zipList不压缩 |
| set-max-intset-entries | 512 | 当intset的元素个数达到512个后，intset升级成dict |
| zset-max-ziplist-entries | 128 | 与hash同理，因为set是hash的特殊情况，set的value都是null |
| zset-max-ziplist-value | 64 | |
| hll-sparse-max-bytes | 3000 | |
| slowlog-max-len | 1000    | 慢查询队列的长度 |
| slowlog-log-slower-than | 1000   | 多少时间定义为慢查询 单位微秒 |
| cluster-enabled | yes | 是否以集群的形式启动 |
| cluster-config-file | redis-nodes.conf | |
| cluster-require-full-coverage | no | 集群中是否16384个槽都可用或所有master节点都没有问题才对外提供服务，保证集群的完整性 |
| cluster-node-timeout | 15000 | 各个节点相互发送消息的频率，单位为毫秒 |
| client-output-buffer-limit normal | 0 0 0 | 不限制普通客户端缓冲区 |
| client-output-buffer-limit replica | 512mb 128mb 60   | slave同步主节点的数据，当slave缓冲区超过512m或者缓冲区在60s秒一直处于128m以上，slave节点会被挂掉 |
| client-output-buffer-limit pubsub | 32mb 8mb 60 | |
| replica-lazy-flush | yes  | 从库接收完rdb文件后的flush操作 |
| lazyfree-lazy-eviction | yes  | 内存达到 maxmemory时进行淘汰 |
| lazyfree-lazy-expire |yes | key过期删除 |
| lazyfree-lazy-server-del | yes | rename指令删除destKey |

## 系统优化详解

```
sysctl vm.overcommit_memory=1
sysctl vm.swappiness=0
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo 511 > /proc/sys/net/core/somaxconn
```
| 名称 | 系统参数/路径 | 值 | 解释 |
|------|---------------|----|------|
| overcommit_memory | vm.overcommit_memory | 1 | 0：表示内核将检查是否有足够的可用内存供应用进程使用;1：表示内核允许超额分配所有的物理内存，而不管当前的内存状态如何。|
| swappiness | vm.swappiness | 0 | 0：宁愿被OOM kill也不swap。物理内存不足的时候，避免redis死掉 |
| THP | /sys/kernel/mm/transparent_hugepage/enabled | never | 加速fork；建议禁用，否则可能会造成更大的内存开销 |
| TCP backlog | /proc/sys/net/core/somaxconn | 511 | redis默认的 tcp backlog值为511 |

## 集群验证

1.检查集群信息
在任意redis节点上执行命令(记得替换ip)：
```
root@ecm-mzl84:/opt/applications/redis# ./redis-6.2.6/src/redis-cli -h 192.168.0.37  -c
192.168.0.37:6379> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:3
cluster_stats_messages_ping_sent:24279
cluster_stats_messages_pong_sent:23655
cluster_stats_messages_meet_sent:1
cluster_stats_messages_sent:47935
cluster_stats_messages_ping_received:23655
cluster_stats_messages_pong_received:24280
cluster_stats_messages_received:47935
192.168.0.37:6379> cluster nodes
41b57f75928d3b5d6249cee970c94904a7c91805 192.168.0.60:6379@16379 master - 0 1649841936423 1 connected 0-5460
640e7c014af661b02aad144d5f0c67db82261734 192.168.0.37:6379@16379 myself,master - 0 1649841935000 3 connected 10923-16383
9edf05abbb9e4244264b715b0702daed8374a1b6 192.168.0.242:6379@16379 slave 640e7c014af661b02aad144d5f0c67db82261734 0 1649841936000 3 connected
fd443821be978948093eafa89f99c68d6dfa7c8e 192.168.0.128:6379@16379 slave 41b57f75928d3b5d6249cee970c94904a7c91805 0 1649841938430 1 connected
201f6617928de701199003fe3cc604b76ea283e2 192.168.0.77:6379@16379 master - 0 1649841937427 2 connected 5461-10922
3a6003c7eece53fb6009c3a45e9a4b47263e5237 192.168.0.158:6379@16379 slave 201f6617928de701199003fe3cc604b76ea283e2 0 1649841935421 2 connected
192.168.0.37:6379>
```

2. 验证集群
```
root@ecm-piags:/opt/applications/redis/redis-6.2.6# ./src/redis-cli -h 192.168.0.60 -c
192.168.0.60:6379> get hello
(nil)
192.168.0.60:6379> set hello word
OK
192.168.0.60:6379> get hello
"word"
192.168.0.60:6379>

./src/redis-cli -h 192.168.0.37 -c
192.168.0.37:6379> get hello
-> Redirected to slot [866] located at 192.168.0.60:6379
"word"
192.168.0.60:6379>
```

## 参考
[搭建redis集群-超详细的配置](https://juejin.cn/post/6844904083321536526)
[Redis 6.0 集群搭建实践](https://segmentfault.com/a/1190000038995016)
