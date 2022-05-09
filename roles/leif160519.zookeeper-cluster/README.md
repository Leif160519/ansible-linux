## Ansible install zookeeper cluster

- 2181：对cline端提供服务
- 3888：选举leader使用
- 2888：集群内机器通讯使用（Leader监听此端口）

> zookeeper版本使用3.5.8是因为要与kafka容器中`/opt/kafka_2.13-2.6.0/libs`下的zookeeper包版本保持一致

## 集群验证
1. 分别到三台zk机器上执行以下命令查看节点角色
```
docker exec  <zk-cluster-name> /apache-zookeeper-3.5.8-bin/bin/zkServer.sh status
```

2. 查看日志有无错误
```
docker logs -f <zk-cluster-name> --tail 200
```
