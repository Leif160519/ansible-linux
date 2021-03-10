## 一、说明
本项目源自：[centos-script](https://github.com/Leif160519/centos-script) | [ubuntu-script](https://github.com/Leif160519/ubuntu-script)

针对待执行脚本的主机数量众多的情况下，建议采用ansible刷入的方式统一配置这些机器，可以大大减少人工成本与时间成本

由于本项目中使用众多systemctl特性，故墙裂推荐使用ubuntu 16.04 ，Debian 9 和Centos 7 及以上版本！！！

### 已知的问题(截止2021-02-01)
- ansible中的service模块(systemd版本:245.4)与内核版本为5.8的linux不兼容，会报`FAILED! => {"changed": false, "msg": "Service is in unknown state", "status": {}}`，建议内核版本5.8基础上升级systemd版本至245.7及以上或降级Linux内核版本,详情参看:[Service is in unknown state #71528](https://github.com/ansible/ansible/issues/71528) | [ansible fails with systemd 245.4](https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1899232)
- 当执行ntp.yml时，若远程机器是ubuntu20.04的系统请将ansible版本升级至2.9.8以上或使用2.10(使用pip3而不是apt安装)，详情参看:[Problems on Ubuntu 20.04 #86](https://github.com/geerlingguy/ansible-role-ntp/issues/86)

项目目录结构
```
ansible-linux
├── files
│   ├── docker
│   ├── loki
│   │   ├── config
│   │   └── service
│   ├── network
│   ├── prometheus
│   │   ├── alert
│   │   │   └── rules
│   │   ├── exporter
│   │   ├── scrape
│   │   │   └── file_sd
│   │   └── service
│   └── repository
├── inventory
├── playbooks
│   └── files -> ../files
└── roles
    ├── ahuffman.resolv
    ├── cloudalchemy.prometheus
    └── geerlingguy.ntp
```

## 二、如何使用

- 1.选择一台Linux或Mac主机安装python3并安装ansible
```
#ubuntu
apt-get install ansible

#centos
yum -y install ansible

#macos
brew install ansible

# python
pip3 install ansible
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
> all: 所有机器
> dist：根据系统版本进行分类

- 5.ansible配置文件(使用pip3安装的ansible不会生成配置文件，可手动创建并配置)
```
vi /etc/ansible/ansible.cfg

[defaults]
force_valid_group_names = ignore     # 忽略语法错误
roles_path = ansible/roles           # 指定roles绝对路径
host_key_checking = False            # 禁用检测host key，即首次连接不会提示输入`yes`
private_key_file = /root/.ssh/id_rsa # 指定ansible用于ssh连接的私钥绝对路径
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
- 2.项目中的部分文件已经配置了在vim下的自动折叠功能(依据标志),其他折叠方式如下：

```
1. manual //手工定义折叠
2. indent //用缩进表示折叠
3. expr　 //用表达式来定义折叠
4. syntax //用语法高亮来定义折叠
5. diff   //对没有更改的文本进行折叠
6. marker //用标志折叠
```

在vim的配置文件中设置`set foldmethod=marker`或者通过ansible刷入即可：
```
ansible-playbook -u root -i inventory playbooks/vim -e username=<username>
```

## 五、补充内容
### 5.1 配置vim
- [Vim 配置入门](http://www.ruanyifeng.com/blog/2018/09/vimrc.html)
- [Vim轻量高效插件管理神器vim-plug介绍-Vim插件(9)](https://vimjc.com/vim-plug.html)
- [Airline & Themes](https://www.bookstack.cn/read/learn-vim/plugins-airline.md)
- [在vim中配置最新YouCompleteMe代码自动补全插件](https://blog.csdn.net/qq_28584889/article/details/97131637)
- [vi代码智能提示功能及相关配置](https://www.cnblogs.com/jxhd1/p/7806626.html)

### 5.2 配置zsh
- [oh-my-fishy-zsh配置](https://leif.fun/articles/2020/09/02/1599028639385.html)
- [iterm2下实现FBI WARNING](https://leif.fun/articles/2019/09/06/1567751175266.html)
