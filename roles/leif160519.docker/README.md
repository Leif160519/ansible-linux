## Ansible Role:Docker
安装配置docker和docke-compose

## 系统要求
- Debian(全系)
- RedHat(全系)

## 用法
```
vars:
  docker_root_dir: /var/lib/docker
  address: 198.18.0.0/16
  size: 24
  mirrors1: http://hub-mirror.c.163.com
  mirrors2: https://b9pmyelo.mirror.aliyuncs.com
  mirrors3: http://docker.mirrors.ustc.edu.cn
  mirrors4: https://registry.docker-cn.com
  log_max_file: 3
  log_max_size: 10m
roles:
  - role: roles/leif160519.docker
```

> 参数解释
> - `docker_root_dir`: docker根目录
> - `address`: docker网桥内网地址段
> - `size`: docker内网子网掩码
> - `mirrors*`: docker镜像源地址
> - `log_max_file`: docker最大日志个数
> - `log_max_size`: docker日志最大文件大小
