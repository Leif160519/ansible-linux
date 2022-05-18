## Ansible install kafka cluster

安装kafka集群之前请先安装zookeeper集群


## 集群验证
```
#任意两台服务器登录kafka，一个发送，一个监听
docker exec -it kafka-cluster-x /bin/bash
```

a.建topic：
```
kafka-topics.sh --create --zookeeper <zookeeper-ip>:2181 --replication-factor 1 --partitions 1 --topic test
```

b.发送信息：
```
kafka-console-producer.sh --broker-list <kafka-ip>:9092 --topic test
你好
```

c.接收信息：
```
kafka-console-consumer.sh --bootstrap-server <kafka-ip>:9092 --topic test --from-beginning
```

## 疑难解答
#### 1.kafka连接zookeeper超时
```
kafka.zookeeper.ZooKeeperClientTimeoutException: Timed out waiting for connection while in state: CONNECTING
```

这个问题的是由于kafka启动的时候连接zookeeper比较慢, 把超时时间设置大一点就可以了,默认是6000ms

解决方案：`server.properties`中增加

```
zookeeper.connection.timeout.ms=6000000

```
重启zk集群

#### 2.发送消息时报一下错误
```
java.lang.IllegalStateException: No entry found for connection 0
```

解决方案：`server.properties`中增加

```
advertised.listeners=PLAINTEXT://172.28.21.243:9092
```
重启zk集群

> ip地址为发送消息端连接kafka的ip地址

## promethes监控
#### 1.使用[kminion][1]
Grafana看板：[10466][2]

#### 2.使用[kafka_exporter][3]
Grafana看板：[7589][4]

[1]: https://github.com/redpanda-data/kminion
[2]: https://grafana.com/grafana/dashboards/10466
[3]: https://github.com/danielqsj/kafka_exporter
[4]: https://grafana.com/grafana/dashboards/7589
