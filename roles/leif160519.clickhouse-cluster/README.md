## Ansible install clickhouse cluster

- clickhouse 至少两个节点

## prometheus监控
在`/etc/clickhouse-server/config.xml`中新增如下字段
```
<prometheus>
    <endpoint>/metrics</endpoint>
    <port>9363</port>
    <metrics>true</metrics>
    <events>true</events>
    <asynchronous_metrics>true</asynchronous_metrics>
    <status_info>true</status_info>
</prometheus>
```

重启clickhouse-server:`systemctl restart clickhouse-server`
