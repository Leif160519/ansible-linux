## Ansible install zookeeper cluster

- 2181：对cline端提供服务
- 3888：选举leader使用
- 2888：集群内机器通讯使用（Leader监听此端口）

> zookeeper版本使用3.5.8是因为要与kafka容器中`/opt/kafka_2.13-2.6.0/libs`下的zookeeper包版本保持一致
