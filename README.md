## 一、说明
本项目源自：[centos-script](https://github.com/Leif160519/centos-script) | [ubuntu-script](https://github.com/Leif160519/ubuntu-script)

针对待执行脚本的主机数量众多的情况下，建议采用ansible刷入的方式统一配置这些机器，可以大大减少人工成本与时间成本

项目目录结构
```
ansible-linux
├── files
│   ├── docker
│   │   ├── daemon.json
│   │   └── docker-ce.repo
│   ├── network
│   │   ├── 00-installer-config.yaml
│   │   ├── ifcfg-eth0
│   │   ├── interfaces
│   │   └── resolv.conf
│   ├── prometheus
│   │   ├── alert
│   │   │   ├── alertmanager.yml
│   │   │   └── rules
│   │   │       ├── default.rules
│   │   │       └── ping.rules
│   │   ├── exporter
│   │   │   └── blackbox_exporter.yml
│   │   ├── scrape
│   │   │   ├── file_sd
│   │   │   │   └── node.yml.j2
│   │   │   ├── node.job
│   │   │   ├── ping.job
│   │   │   └── prometheus.job
│   │   └── service
│   │       ├── alertmanager.service
│   │       ├── blackbox_exporter.service
│   │       └── node_exporter.service
│   └── repository
│       ├── sources-debian.list
│       └── sources.list
├── inventory
│   ├── all
│   └── dist
├── playbooks
│   ├── config.yml
│   ├── docker.yml
│   ├── files -> ../files
│   ├── gitlab.yml
│   ├── grafana.yml
│   ├── install.yml
│   ├── network.yml
│   ├── ntp.yml
│   ├── oh-my-fish.yml
│   ├── oh-my-zsh.yml
│   ├── prometheus.yml
│   ├── rar.yml
│   ├── remove_gnome.yml
│   ├── repository.yml
│   ├── ssh-key.yml
│   └── universal.yml
├── README.md
└── roles
    └── cloudalchemy.prometheus
```

## 二、如何使用

- 1.选择一台Linux或Mac主机安装python3并安装ansible
```
#ubuntu
apt-get install ansible

#centos
yum -y install ansible

#macos
brew install ansible #没有装brew包管理器的自行百度安装一下
```

- 2.将本机的ssh-key全部复制进所有主机中
```
ssh-copy-id -i root@<host-ip>
```

- 3.克隆本项目
```
git clone https://github.com/Leif160519/ansible-linux
```

- 4.修改inventory下的主机hostname和IP地址
```
[dist]
[dist:children] # 发行版 {{{
dist.debian
dist.redhat
# }}}

[dist.debian:children] # debian 系 {{{
dist.ubuntu
dist.debian9
dist.debian10
# }}}

[dist.redhat:children] # redhat子类 {{{1
dist.centos

[dist.centos:children] # centos子类 {{{2
dist.centos6
dist.centos7

[ dist.centos6] # {{{3
# }}}3

[dist.centos7] # {{{3
gitlab-server
# }}}3
# }}}2
# }}}1

[dist.ubuntu:children] # ubuntu子类 {{{1
dist.ubuntu.lts

[dist.ubuntu.lts:children] # ubuntu发行版子类 {{{2
dist.u1604
dist.u1804
dist.u2004

[dist.u1604] # {{{3
# }}}3

[dist.u1804] # {{{3
# }}}3

[dist.u2004] # {{{3
prometheus-server
ansible-server
jenkins-server
nexus-server
# }}}3
# }}}2
# }}}1

[dist.debian9] # {{{
# }}}

[dist.debian10] # {{{
# }}}
```

- 5.ansible配置文件配置忽略组语法错误
```
vi /etc/ansible/ansible.cfg

[defaults]
force_valid_group_names = ignore
···

```
- 6.开始刷入
```
# all machine(prometheus.yml auto install node_exporter)
ansible-playbook -u root -i inventory/ playbooks/universal.yml

# prometheus-server(以下顺序不能颠倒)
# 1.pull submodle
git submodule update --init --recursive
# 2.install prometheus
ansible-playbool -u root -i inventory/ playbooks/prometheus.yml -t prometheus
# 3.install alertmanager
ansible-playbook -u root -i inventory/ playbooks/prometheus.yml -t alertmanager
# 4.install blackbox_exporter
ansible-playbook -u root -i inventory/ playbooks/prometheus.yml -t blackbox
# 5.config prometheus and start prometheus service
ansible-playbook -u root -i inventory/ playbooks/prometheus.yml -t admin
```

## 三、特定情况
- 1.安装某些软件
```
ansible-playbook -u root -i inventory/ playbooks/install.yml -t [ubuntu | install]
```

- 2.在某些机器上指定playbook
```
ansible-playbook -u root -i inventory/ playbooks/install.yml -l 'jenkins-server nexus-server'
```

- 3.监控主机安装prometheus
执行`prometheus.yml`之后别忘了执行一下`node_exporter.yml`，否则`9090`不能显示监控数据

- 4.被监控主机安装node_exporter
需在`node_export.yml`文件中将`delegate_to`后面的`prometheus`主机名按照实际情况修改之后再执行

- 5.安装node_exporter时报错解决办法
在某些情况下，执行带有`delegate_to`（任务委派）的playbook时候，会报错：
```
failed: [centos-7 -> 192.168.0.108] (item=  - job_name: 'node') => {"ansible_loop_var": "item", "changed": false, "item": "  - job_name: 'node'", "module_stderr": "Shared connection to 192.168.0.108 closed.\r\n", "module_stdout": "/bin/sh: 1: /usr/bin/python: not found\r\n", "msg": "The module failed to execute correctly, you probably need to set the interpreter.\nSee stdout/stderr for the exact error", "rc": 127}

failed: [debian-10 -> 192.168.0.108] (item=  - job_name: 'node') => {"ansible_loop_var": "item", "changed": false, "item": "  - job_name: 'node'", "module_stderr": "Shared connection to 192.168.0.108 closed.\r\n", "module_stdout": "/bin/sh: 1: /usr/bin/python3.7: not found\r\n", "msg": "The module failed to execute correctly, you probably need to set the interpreter.\nSee stdout/stderr for the exact error", "rc": 127}
```

原因是ansible未检测到python环境，也就是说你在Linux终端打`python`是提示无此命令的，所以解决办法是，强制ansible使用python3环境，在执行命令后面添加`-e ansible_python_interpreter=/usr/bin/python3`参数即可：
```
ansible-playbook -u root -i inventory playbooks/node_exporter.yml  -l 'jenkins-server' -e ansible_python_interpreter=/usr/bin/python3
```

## 四、说明
- 1.prometheus自带三条规则，分别为"分区剩余空间不足2%","分区剩余空间使用预计不足4h"和"ping有丢包"
- 2.项目中的部分文件已经配置了在vim下的自动折叠功能，关于vim的具体配置请参照互联网或使用如下命令刷入`ansible-playbook -u root -i inventory playbooks/config`
