## Ansible 安装emqx集群

## 注意
- 1.emqx集群的机器必须开启防火墙4370，5370端口以便集群互访

## 暴露metrics
在plugin中开启`emqx_prometheus`即可
另外创建只读用户，用户名exporter，密码public
