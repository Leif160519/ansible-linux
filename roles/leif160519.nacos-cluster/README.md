## Ansible install nacos cluster

安装前请确保nacos目标主机都安装了docker和docker-compose

集群情况：
- nacos节点:3
- mysql节点:1

单节点版请参看:[nacos/single](https://github.com/Leif160519/docker-script/tree/master/nacos/single)

## 如何暴露metrcs数据

```
docker exec -it nacos-app bash
vim /home/nacos/conf/application.properties

# 在最后一行添加
management.endpoints.web.exposure.include=*

# 重启nacos容器
docker restart nacos-app
```

grafana图表：[13221][1]

[1]: https://grafana.com/grafana/dashboards/13221
